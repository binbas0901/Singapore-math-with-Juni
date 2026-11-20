#!/usr/bin/env python3
"""Validate the draft DATA-001 package and run its U07 contract fixtures."""
import argparse
from collections import Counter
from copy import deepcopy
from graphlib import CycleError, TopologicalSorter
from hashlib import sha256
import json
from pathlib import Path
import shutil
import sys
from tempfile import TemporaryDirectory
import wave

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "curriculum/fixtures/u07"
SCHEMA = ROOT / "schemas/v1/content.schema.json"
STAGES = ["neutralRetry", "representationHint", "guidedAction", "reteach"]


class ContractError(ValueError):
    pass


def require(condition, code, detail):
    if not condition:
        raise ContractError(f"{code}: {detail}")


def unique_pairs(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, "json", f"duplicate property {key}")
        result[key] = value
    return result


def read(path):
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_pairs)


def validator_for(schema, kind):
    return Draft202012Validator({
        "$defs": schema["$defs"], "$ref": f"#/$defs/{kind}"
    })


def validate(schema, document, kind):
    error = next(validator_for(schema, kind).iter_errors(document), None)
    if error:
        raise ContractError(f"schema: {kind} {error.json_path}: {error.message}")


def index(rows, key="id"):
    result = {}
    for row in rows:
        value = row[key]
        require(value not in result, "duplicate", value)
        result[value] = row
    return result


def lookup(table, key):
    require(key in table, "reference", key)
    return table[key]


def bounds(target, value):
    return target["bounds"]["min"] <= value <= target["bounds"]["max"]


def validate_catalog(catalog):
    objectives = index(catalog["objectives"])
    targets = index(catalog["targets"])
    graphs = {kind: TopologicalSorter() for kind in ("advisory", "readiness", "componentMastery")}
    edges = set()
    for target in targets.values():
        lookup(objectives, target["objectiveId"])
        require(bounds(target, target["bounds"]["min"]), "bounds", target["id"])
    for dependency in catalog["dependencies"]:
        kind = dependency["kind"]
        if kind == "advisory":
            start, end = dependency["beforeLessonId"], dependency["afterLessonId"]
            require({start, end} <= set(catalog["lessonSlots"]), "reference", "advisory slot")
        else:
            end = dependency["forTargetId"]
            start = dependency["probeTargetId" if kind == "readiness" else "componentTargetId"]
            lookup(targets, end)
            prerequisite = lookup(targets, start)
            if kind == "readiness":
                require(all(bounds(prerequisite, n) for n in dependency["quantities"]) and
                        set(dependency["representations"]) <= set(prerequisite["representations"]),
                        "bounds", f"readiness probe {start}")
        require((kind, start, end) not in edges, "duplicate", f"{kind} {start} → {end}")
        edges.add((kind, start, end))
        graphs[kind].add(end, start)
    for kind, graph in graphs.items():
        try:
            tuple(graph.static_order())
        except CycleError as error:
            raise ContractError(f"cycle: {kind} {error.args[1]}") from error
    return targets


def workspace_state(workspace):
    regions = index(workspace["regions"])
    positions = {key: row["regionId"] for key, row in index(workspace["counters"]).items()}
    require(len(positions) == workspace["whole"], "conservation", workspace["id"])
    require(set(positions.values()) <= regions.keys(), "reference", "counter region")
    return positions


def fold(workspace, cues, at_ms):
    positions = workspace_state(workspace)
    regions = index(workspace["regions"])
    active = completed = None
    for cue in cues:
        if cue["atMs"] > at_ms:
            break
        payload = cue["payload"]
        if payload["kind"] == "presentation":
            continue
        action = payload["action"]
        kind = action["kind"]
        require(kind in workspace["legalActions"], "action", kind)
        if kind == "moveCounter":
            counter, source, dest = action["counterId"], action["fromRegionId"], action["toRegionId"]
            lookup(regions, source)
            lookup(regions, dest)
            require(source != dest and lookup(positions, counter) == source and active is None,
                    "action", f"illegal move for {counter}")
            positions[counter] = dest
        elif kind == "linkBond":
            part_a, part_b = action["partARegionId"], action["partBRegionId"]
            lookup(regions, part_a)
            lookup(regions, part_b)
            counts = Counter(positions.values())
            require(active is None and part_a != part_b and
                    action["partA"] == counts[part_a] and action["partB"] == counts[part_b] and
                    action["partA"] + action["partB"] == action["whole"] == len(positions),
                    "bond", "parts must be disjoint and exhaust the whole")
            active = action
        else:
            require(active is not None, "action", "clear requires an active bond")
            completed, active = active, None
    return dict(positions=positions, active=active, completed=completed)


def validate_timeline(timeline, clip, workspace, item):
    require(timeline["clipVersion"] == clip["version"], "reference", "clip version")
    chapters = index(timeline["chapters"])
    chapter_times = [row["atMs"] for row in chapters.values()]
    cues = timeline["cues"]
    index(cues)
    order = [(row["atMs"], row["order"]) for row in cues]
    require(order == sorted(set(order)) and order[-1][0] <= clip["durationMs"],
            "timeline", "cue order or duration")
    require(chapter_times == sorted(set(chapter_times)) and chapter_times[0] == 0 and
            chapter_times[-1] == order[-1][0], "timeline", "manual chapter boundaries")
    caption_ids = []
    for cue in cues:
        payload = cue["payload"]
        if payload["kind"] == "presentation":
            update = payload["update"]
            if update["kind"] == "caption":
                chapter = lookup(chapters, update["chapterId"])
                require(chapter["atMs"] == cue["atMs"], "timeline", "caption boundary")
                caption_ids.append(chapter["id"])
            else:
                lookup(index(workspace["regions"]), update["regionId"])
    require(caption_ids == list(chapters), "timeline", "manual caption coverage")
    final = fold(workspace, cues, clip["durationMs"])
    completed = final["completed"]
    require(final["positions"] == workspace_state(workspace) and final["active"] is None and
            completed is not None and
            (completed["whole"], completed["partA"], completed["partB"]) ==
            (item["whole"], item["knownPart"], item["expectedAnswer"]),
            "bond", "expected linked partition and recombination")


def validate_lesson(lesson, catalog, targets, clips):
    require(lesson["unitId"] == catalog["unitId"] and lesson["id"] in catalog["lessonSlots"],
            "reference", "lesson unit or slot")
    workspaces = index(lesson["workspaces"])
    items = index(lesson["items"])
    worksheets = index(lesson["worksheets"])
    assistance = index(lesson["assistance"])
    disclosures = index(lesson["disclosures"])
    activities = index(lesson["activities"])
    keys = {item["exposureKey"] for item in items.values()}
    for target_id in lesson["targetIds"]:
        lookup(targets, target_id)
    for item in items.values():
        target = lookup(targets, item["targetId"])
        whole, known, answer = item["whole"], item["knownPart"], item["expectedAnswer"]
        require(item["targetId"] in lesson["targetIds"] and
                all(bounds(target, value) for value in (whole, known, answer)) and
                known + answer == whole and item["acceptableAnswers"] == [answer] and
                set(item["modelOptions"]) <= set(target["representations"]), "answer", item["id"])
    for workspace in workspaces.values():
        workspace_state(workspace)
    for sheet in worksheets.values():
        for slot in index(sheet["items"]).values():
            lookup(items, slot["itemId"])
            regions = index(slot["regions"])
            require(sum(row["role"] == "answer" for row in regions.values()) == 1,
                    "worksheet", slot["id"])
    for disclosure in disclosures.values():
        require(set(disclosure["exposureKeys"]) <= keys, "reference", disclosure["id"])
    for step in assistance.values():
        for disclosure_id in step["disclosureIds"]:
            lookup(disclosures, disclosure_id)
        require(bool(step["disclosureIds"]) == (step["stage"] != "neutralRetry"),
                "exposure", step["id"])
    seen_keys = set()
    used_workspaces = set()
    timeline_ids = set()
    for activity in activities.values():
        kind = activity["kind"]
        if kind == "readiness":
            for target_id in activity["targetIds"]:
                target = lookup(targets, target_id)
                require(target_id in lesson["targetIds"] and
                        all(bounds(target, n) for n in activity["quantities"]), "bounds", target_id)
            continue
        item = lookup(items, activity["itemId"])
        for ref in activity.get("disclosureIds", []):
            seen_keys.update(lookup(disclosures, ref)["exposureKeys"])
        for ref in activity.get("feedbackDisclosureIds", []):
            disclosure = lookup(disclosures, ref)
            require(disclosure["reason"] == "solutionFeedback" and
                    item["exposureKey"] in disclosure["exposureKeys"], "exposure", ref)
        if kind in {"observe", "guidedPractice"}:
            require(item["exposureKey"] in seen_keys, "exposure", activity["id"])
            workspace_id = activity["workspaceId"]
            workspace = lookup(workspaces, workspace_id)
            require(workspace_id not in used_workspaces and workspace["whole"] == item["whole"] and
                    bool(workspace["inputModes"]) == (kind == "guidedPractice"),
                    "workspace", workspace_id)
            used_workspaces.add(workspace_id)
        if kind == "observe":
            timeline = activity["timeline"]
            require(timeline["id"] not in timeline_ids, "duplicate", timeline["id"])
            timeline_ids.add(timeline["id"])
            validate_timeline(timeline, lookup(clips, timeline["clipId"]), workspace, item)
            continue
        sheet = lookup(worksheets, activity["worksheetId"])
        alternatives = activity.get("replacementItemIds", [])
        require({item["id"], *alternatives} <= {slot["itemId"] for slot in sheet["items"]},
                "worksheet", activity["id"])
        last_by_branch = {}
        help_keys = set()
        for ref in activity["assistanceIds"]:
            step = lookup(assistance, ref)
            branch = step["branch"].get("code", "")
            rank = STAGES.index(step["stage"])
            require(rank > last_by_branch.get(branch, -1), "assistance", activity["id"])
            last_by_branch[branch] = rank
            for disclosure_id in step["disclosureIds"]:
                help_keys.update(disclosures[disclosure_id]["exposureKeys"])
        if kind == "assessment":
            eligible_keys = set(seen_keys)
            feedback_keys = {key for ref in activity["feedbackDisclosureIds"]
                             for key in disclosures[ref]["exposureKeys"]}
            require(all(lookup(items, ref)["exposureKey"] not in help_keys | feedback_keys
                        for ref in alternatives), "freshness", "replacement exposed during help or feedback")
            for candidate in [item, *(lookup(items, ref) for ref in alternatives)]:
                require(candidate["exposureKey"] not in eligible_keys, "freshness", candidate["id"])
                eligible_keys.add(candidate["exposureKey"])
                require(all(candidate[field] == item[field] for field in
                            ("targetId", "familyId", "familyVersion", "demandId",
                             "modelRequirement", "modelOptions")), "demand", candidate["id"])
            seen_keys.update(help_keys | feedback_keys)


def validate_package(schema, root):
    manifest = read(root / "manifest.json")
    validate(schema, manifest, "manifest")
    require(manifest["minEngineVersion"] <= 1, "version", "unsupported engine version")
    files = index(manifest["files"], "path")
    require(len({path.casefold() for path in files}) == len(files), "file", "case collision")
    require(sum(row["bytes"] for row in files.values()) <= 64 * 1024 * 1024,
            "file", "draft package size limit")
    for relative, row in files.items():
        path = root / relative
        require(not any(parent.is_symlink() for parent in (path, *path.parents)
                        if parent != root and root in parent.parents) and path.is_file(),
                "file", relative)
        require(path.stat().st_size == row["bytes"] and
                sha256(path.read_bytes()).hexdigest() == row["sha256"], "integrity", relative)

    def load_file(relative, kind):
        require(lookup(files, relative)["type"] == kind, "file", relative)
        document = read(root / relative)
        validate(schema, document, kind)
        return document

    catalog = load_file(manifest["catalogFile"], "catalog")
    targets = validate_catalog(catalog)
    clips = index(manifest["clips"])
    for clip in clips.values():
        require(lookup(files, clip["file"])["type"] == "audio" and
                clip["locale"] == manifest["locale"], "file", clip["id"])
        require(manifest["usage"] == "developmentFixture" or
                clip["rights"]["status"] == "cleared", "rights", clip["id"])
        if clip["rights"]["status"] == "fixturePlaceholder":
            with wave.open(str(root / clip["file"]), "rb") as wav:
                require(1000 * wav.getnframes() == clip["durationMs"] * wav.getframerate(),
                        "timeline", "placeholder duration")
    lessons = {}
    for lesson_id, row in index(manifest["lessons"]).items():
        lesson = load_file(row["file"], "lesson")
        require(lesson["id"] == lesson_id, "reference", lesson_id)
        validate_lesson(lesson, catalog, targets, clips)
        lessons[lesson_id] = lesson
    referenced = {manifest["catalogFile"], *(row["file"] for row in manifest["lessons"]),
                  *(clip["file"] for clip in clips.values())}
    require(set(files) == referenced, "file", "unreferenced file records")
    return manifest, catalog, lessons


def validate_submission(submission, manifest, digest, lessons):
    content = submission["content"]
    require(all(content[key] == manifest[key] for key in ("packageId", "contentVersion", "locale")) and
            content["manifestSha256"] == digest, "identity", "pinned content")
    lesson = lookup(lessons, submission["lessonId"])
    activity = lookup(index(lesson["activities"]), submission["activityId"])
    require(activity["kind"] in {"guidedPractice", "assessment"} and
            submission["worksheetId"] == activity["worksheetId"] and
            submission["requestedMode"] == activity.get("mode", "guided"), "identity", "activity")
    sheet = lookup(index(lesson["worksheets"]), submission["worksheetId"])
    slot = lookup(index(sheet["items"]), submission["worksheetItemId"])
    region = lookup(index(slot["regions"]), submission["answerRegionId"])
    item = lookup(index(lesson["items"]), slot["itemId"])
    require(submission["worksheetVersion"] == sheet["version"] and region["role"] == "answer" and
            submission["itemSnapshot"] == item and item["id"] in
            {activity["itemId"], *activity.get("replacementItemIds", [])}, "identity", "worksheet/item")
    exposures = [lookup(index(lesson["disclosures"]), key) for key in submission["exposureAtSubmit"]]
    exposed = any(item["exposureKey"] in row["exposureKeys"] for row in exposures)
    require(not (exposed or submission["requestedMode"] == "guided") or
            submission["evidenceClass"] == "assisted", "evidence", "applicable disclosure or guided mode")
    require(submission["evidenceClass"] in {"assisted", submission["requestedMode"]},
            "evidence", "evidence mode mismatch")
    model = submission["model"]
    if model["status"] == "observed":
        require(model["representation"] in item["modelOptions"], "response", "model representation")


def check_inventory(catalog):
    inventory = read(ROOT / "curriculum/p1/objectives.json")
    objectives = index(inventory["objectives"])
    concepts = index(inventory["concepts"])
    for objective in catalog["objectives"]:
        source = lookup(objectives, objective["id"])["source"]
        require((source["id"], source["page"], source["item"]) ==
                (objective["sourceId"], objective["page"], objective["item"]),
                "source", objective["id"])
    for target in catalog["targets"]:
        concept = lookup(concepts, target["conceptId"])
        require((concept["objective_id"], concept["classification"]) ==
                (target["objectiveId"], target["classification"]), "source", target["id"])


def check_u07_projection(lesson):
    observe = lookup(index(lesson["activities"]), "observe")
    workspace = lookup(index(lesson["workspaces"]), observe["workspaceId"])
    cues = observe["timeline"]["cues"]
    for at, expected_bowl in [(0, 0), (999, 0), (1000, 1), (1001, 1), (1999, 1),
                              (2000, 2), (2001, 2), (2999, 2), (3000, 2), (3001, 2),
                              (3999, 2), (4000, 0), (4001, 0), (5000, 0)]:
        state = fold(workspace, cues, at)
        counts = Counter(state["positions"].values())
        require((counts["tray"], counts["bowl"]) == (6 - expected_bowl, expected_bowl),
                "projection", str(at))
        require(bool(state["active"]) == (3000 <= at < 4000) and
                bool(state["completed"]) == (at >= 4000), "projection", str(at))
    active = fold(workspace, cues, 3000)["active"]
    require((active["partARegionId"], active["partBRegionId"]) == ("bowl", "tray"),
            "projection", "linked part roles")
    guided = lookup(index(lesson["workspaces"]), "try")
    guided_actions = [
        dict(kind="moveCounter", counterId="C1", fromRegionId="tray", toRegionId="bowl"),
        dict(kind="linkBond", partARegionId="bowl", partBRegionId="tray",
             whole=7, partA=1, partB=6),
    ]
    guided_cues = [dict(atMs=at, payload=dict(kind="math", action=action))
                   for at, action in enumerate(guided_actions)]
    guided_state = fold(guided, guided_cues, 1)
    fold(workspace, cues, 5000)
    require(guided_state["active"] == guided_actions[1] and
            Counter(guided_state["positions"].values()) == {"bowl": 1, "tray": 6} and
            guided_state == fold(guided, guided_cues, 1),
            "projection", "separate guided 7–1–6 workspace")

    manual = [chapter["atMs"] for chapter in observe["timeline"]["chapters"]]
    require([Counter(fold(workspace, cues, at)["positions"].values())["bowl"] for at in manual]
            == [0, 1, 2, 2, 0], "projection", "manual chapters")


def run_fixtures(schema):
    package = FIXTURE / "package"
    manifest, catalog, lessons = validate_package(schema, package)
    digest = sha256((package / "manifest.json").read_bytes()).hexdigest()
    submission = read(FIXTURE / "submission.json")
    validate(schema, submission, "submission")
    validate_submission(submission, manifest, digest, lessons)
    check_inventory(catalog)
    check_u07_projection(lessons["U07"])

    # Exercise a typed component dependency without making it a U07 prerequisite.
    component_example = deepcopy(catalog)
    component_example["dependencies"].append({
        "kind": "componentMastery", "forTargetId": "match-to-10",
        "componentTargetId": "count-to-10", "evidence": "priorOrConcurrentIndependent",
    })
    validate(schema, component_example, "catalog")
    validate_catalog(component_example)

    assisted = deepcopy(submission)
    assisted["response"] = {"method": "confirmedHandwriting", "confirmedValue": 5,
                            "inkRevisionId": "synthetic-ink-1"}
    assisted["model"] = {"status": "pending"}
    assisted["exposureAtSubmit"] = ["check-hint"]
    assisted["evidenceClass"] = "assisted"
    validate(schema, assisted, "submission")
    validate_submission(assisted, manifest, digest, lessons)
    clips = index(manifest["clips"])
    cases = sorted((FIXTURE / "invalid").glob("*.json"))
    require(bool(cases), "fixture", "no negative cases")
    for path in cases:
        case = read(path)
        kind = case["document"]
        document = deepcopy({"manifest": manifest, "catalog": catalog, "lesson": lessons["U07"],
                             "submission": submission}[kind])
        parent = document
        *parents, key = case["path"]
        for component in parents:
            parent = parent[component]
        if case.get("append"):
            parent[key].append(case["value"])
        else:
            parent[key] = case["value"]
        try:
            validate(schema, document, kind)
            if kind == "manifest":
                with TemporaryDirectory() as directory:
                    copy = Path(directory) / "package"
                    shutil.copytree(package, copy)
                    (copy / "manifest.json").write_text(json.dumps(document), encoding="utf-8")
                    if "removeFile" in case:
                        (copy / case["removeFile"]).unlink()
                    validate_package(schema, copy)
            elif kind == "catalog":
                validate_catalog(document)
            elif kind == "lesson":
                validate_lesson(document, catalog, validate_catalog(catalog), clips)
            elif kind == "submission":
                validate_submission(document, manifest, digest, lessons)
        except ContractError as error:
            require(str(error).startswith(case["expected"] + ":"), "fixture", f"{path.name}: {error}")
            print(f"Rejected {path.stem} ({case['expected']})")
        else:
            raise ContractError(f"fixture: accepted {path.name}")
    print(f"PASS: schema, package, submission, CUR-002 anchors, U07 cue projection, {len(cases)} negative fixtures")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, help="validate this package instead of running U07 fixtures")
    args = parser.parse_args()
    try:
        schema = read(SCHEMA)
        Draft202012Validator.check_schema(schema)
        if args.package:
            validate_package(schema, args.package)
            print(f"PASS: {args.package}")
        else:
            run_fixtures(schema)
    except (ContractError, OSError, ValueError, wave.Error) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
