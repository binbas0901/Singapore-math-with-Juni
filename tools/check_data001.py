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
import struct
import sys
from tempfile import TemporaryDirectory

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "curriculum/fixtures/u07"
SCHEMA = ROOT / "schemas/v1/content.schema.json"
STAGES = ["neutralRetry", "representationHint", "guidedAction", "reteach"]
HELP_REASONS = {
    "representationHint": {"taskHint"},
    "guidedAction": {"guidedAction"},
    "reteach": {"taskHint", "guidedAction"},
}
GUIDED_ACTION_TEXT = "Move {knownPart} counters to a bowl and count what is left."


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
    if catalog["unitId"] == "p1-numbers-to-10" and "U07" in catalog["lessonSlots"]:
        validate_u07_dependencies(catalog, targets)
    return targets


def validate_u07_dependencies(catalog, targets):
    split = lookup(targets, "split-to-10")
    require(split["conceptId"] == "P1-ADD-01-C01" and split["objectiveId"] == "P1-ADD-01" and
            split["bounds"] == {"min": 0, "max": 10}, "prerequisite", "U07 split target")
    dependencies = [row for row in catalog["dependencies"] if row.get("forTargetId") == split["id"]]
    require(all(row["kind"] == "readiness" for row in dependencies),
            "prerequisite", "L016 has no component mastery prerequisites")
    probes = {row["probeTargetId"]: (set(row["quantities"]), set(row["representations"]))
              for row in dependencies}
    require(probes == {"count-to-10": ({6, 7, 8}, {"counters"}),
                       "match-to-10": ({6, 7, 8}, {"counters", "numeral"})},
            "prerequisite", "U07 count and match probes")
    for target_id, concept in (("count-to-10", "P1-NUM-01-C01"), ("match-to-10", "P1-NUM-02-C01")):
        require(targets[target_id]["conceptId"] == concept, "prerequisite", target_id)
    advisory = {(row["beforeLessonId"], row["afterLessonId"]) for row in catalog["dependencies"]
                if row["kind"] == "advisory" and "U07" in (row["beforeLessonId"], row["afterLessonId"])}
    require(advisory == {("U06", "U07"), ("U07", "U08")}, "prerequisite", "U07 advisory order")


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


def validate_question_keys(items):
    signatures = {}
    for item in items:
        # Supported static missing-part shape. Prose, difficulty and version labels do not change it.
        signature = (item["familyId"], item["whole"], item["knownPart"])
        require(signatures.setdefault(signature, item["exposureKey"]) == item["exposureKey"],
                "freshness", f"same missing-part question with different keys: {item['id']}")


def candidate_deliveries(activity):
    return index([activity, *activity.get("replacementDeliveries", [])], "itemId")


def validate_delivery(delivery, item, assistance, disclosures):
    last_by_branch = {}
    for ref in delivery["assistanceIds"]:
        step = lookup(assistance, ref)
        require(step["itemId"] == item["id"], "assistance", f"{ref} applies to a different item")
        branch = step["branch"].get("code", "")
        rank = STAGES.index(step["stage"])
        require(rank > last_by_branch.get(branch, -1), "assistance", item["id"])
        last_by_branch[branch] = rank
    for ref in delivery.get("feedbackDisclosureIds", []):
        disclosure = lookup(disclosures, ref)
        require(disclosure["reason"] == "solutionFeedback" and
                disclosure["exposureKeys"] == [item["exposureKey"]], "exposure", ref)


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
    validate_question_keys(items.values())
    for workspace in workspaces.values():
        workspace_state(workspace)
    for sheet in worksheets.values():
        index(sheet["items"], "itemId")
        for slot in index(sheet["items"]).values():
            lookup(items, slot["itemId"])
            regions = index(slot["regions"])
            require(sum(row["role"] == "answer" for row in regions.values()) == 1,
                    "worksheet", slot["id"])
    for activity in activities.values():
        if activity["kind"] == "assessment":
            candidates = [activity["itemId"], *activity["replacementItemIds"]]
            require(len({lookup(items, ref)["exposureKey"] for ref in candidates}) == len(candidates),
                    "freshness", "assessment candidates share an exposure key")
    for disclosure in disclosures.values():
        require(set(disclosure["exposureKeys"]) <= keys, "reference", disclosure["id"])
        require(("feedback" in disclosure["channels"]) == (disclosure["reason"] == "solutionFeedback"),
                "exposure", f"feedback channel conflicts with disclosure reason: {disclosure['id']}")
    for step in assistance.values():
        item = lookup(items, step["itemId"])
        rows = [lookup(disclosures, ref) for ref in step["disclosureIds"]]
        stage = step["stage"]
        if stage == "neutralRetry":
            require(not rows, "exposure", step["id"])
            continue
        task_rows = [row for row in rows if row["reason"] != "workedExample"]
        require(task_rows and all(row["reason"] in HELP_REASONS[stage] and
                                 row["exposureKeys"] == [item["exposureKey"]] for row in task_rows) and
                (stage == "reteach" or len(rows) == len(task_rows)), "exposure", step["id"])
        if stage == "guidedAction":
            require(step["text"] == GUIDED_ACTION_TEXT,
                    "assistance", "guided action requires the candidate's knownPart template")
    seen_keys = set()
    readiness_targets = set()
    used_workspaces = set()
    timeline_ids = set()
    for activity in activities.values():
        kind = activity["kind"]
        if kind == "readiness":
            for_target = activity["forTargetId"]
            require(for_target in lesson["targetIds"], "prerequisite", for_target)
            probes = {row["probeTargetId"]: row for row in catalog["dependencies"]
                      if row["kind"] == "readiness" and row["forTargetId"] == for_target}
            for target_id in activity["targetIds"]:
                target = lookup(targets, target_id)
                require(target_id in lesson["targetIds"] and
                        all(bounds(target, n) for n in activity["quantities"]), "bounds", target_id)
                probe = lookup(probes, target_id)
                require(set(activity["quantities"]) == set(probe["quantities"]),
                        "prerequisite", f"readiness quantities for {target_id}")
                readiness_targets.add((for_target, target_id))
            continue
        item = lookup(items, activity["itemId"])
        activity_keys = set()
        expected_reason = "workedExample" if kind == "observe" else "guidedAction"
        for ref in activity.get("disclosureIds", []):
            disclosure = lookup(disclosures, ref)
            require(disclosure["reason"] == expected_reason, "exposure", ref)
            activity_keys.update(disclosure["exposureKeys"])
        seen_keys.update(activity_keys)
        if kind in {"observe", "guidedPractice"}:
            require(item["exposureKey"] in activity_keys, "exposure", activity["id"])
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
        deliveries = candidate_deliveries(activity)
        require(set(deliveries) == {item["id"], *alternatives}, "assistance", "candidate coverage")
        eligible_keys = seen_keys.copy()
        for candidate_id, delivery in deliveries.items():
            candidate = lookup(items, candidate_id)
            validate_delivery(delivery, candidate, assistance, disclosures)
            if kind == "assessment":
                key = candidate["exposureKey"]
                require(key not in eligible_keys, "freshness", candidate_id)
                eligible_keys.add(key)
                require(all(candidate[field] == item[field] for field in
                            ("targetId", "familyId", "familyVersion", "demandId",
                             "modelRequirement", "modelOptions")), "demand", candidate_id)
            # A worked example in reteach may add exposure beyond the active item.
            refs = [ref for step_id in delivery["assistanceIds"]
                    for ref in assistance[step_id]["disclosureIds"]]
            keys_disclosed = {key for ref in refs + delivery.get("feedbackDisclosureIds", [])
                              for key in disclosures[ref]["exposureKeys"]}
            if kind == "assessment":
                other_keys = {items[other]["exposureKey"] for other in deliveries if other != candidate_id}
                require(not other_keys & keys_disclosed, "freshness",
                        "delivery exposes another candidate with the current item")
            seen_keys.update(keys_disclosed)
    if lesson["unitId"] == "p1-numbers-to-10" and lesson["id"] == "U07":
        require(readiness_targets == {("split-to-10", "count-to-10"), ("split-to-10", "match-to-10")},
                "prerequisite", "U07 readiness activities")
        check_u07_projection(lesson)
        timeline = lookup(activities, "observe")["timeline"]
        clip = lookup(clips, timeline["clipId"])
        require(" ".join(chapter["text"] for chapter in timeline["chapters"]) == clip["transcript"],
                "timeline", "U07 manual captions and narration transcript differ")


def validate_pcm_clip(path, duration_ms):
    require(path.suffix.lower() == ".wav", "media", f"unsupported audio: {path.name}")
    wav = path.read_bytes()
    require(len(wav) >= 12 and wav[:4] == b"RIFF" and wav[8:12] == b"WAVE" and
            struct.unpack_from("<I", wav, 4)[0] == len(wav) - 8,
            "media", f"invalid RIFF/WAVE header or size: {path.name}")

    offset = 12
    block_align = data_size = None
    while offset < len(wav):
        require(offset + 8 <= len(wav), "media", f"incomplete WAV chunk header: {path.name}")
        chunk_id, size = struct.unpack_from("<4sI", wav, offset)
        start = offset + 8
        offset = start + size + (size % 2)
        require(offset <= len(wav), "media", f"WAV chunk exceeds RIFF size: {path.name}")
        if chunk_id == b"fmt ":
            require(block_align is None and size >= 16, "media", f"invalid PCM format chunk: {path.name}")
            encoding, channels, sample_rate, byte_rate, block_align, bits = struct.unpack_from(
                "<HHIIHH", wav, start)
            require(encoding == 1 and channels in {1, 2} and bits in {8, 16, 24, 32} and sample_rate > 0,
                    "media", f"unsupported PCM format: {path.name}")
            require(block_align == channels * (bits // 8) and byte_rate == sample_rate * block_align,
                    "media", f"inconsistent PCM byte rate or block alignment: {path.name}")
        elif chunk_id == b"data":
            require(block_align is not None and data_size is None and size % block_align == 0,
                    "media", f"invalid PCM data chunk or incomplete frames: {path.name}")
            data_size = size
    require(data_size is not None, "media", f"missing PCM data chunk: {path.name}")
    frames = data_size // block_align
    require(1000 * frames == duration_ms * sample_rate, "timeline", f"clip duration: {path.name}")


def validate_package(schema, root, education_review=None):
    manifest_path = root / "manifest.json"
    require(not root.is_symlink() and not manifest_path.is_symlink(), "file", "package symlink")
    manifest = read(manifest_path)
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

    paths = list(root.rglob("*"))
    require(all(not path.is_symlink() and (path.is_file() or path.is_dir()) for path in paths),
            "file", "non-regular package entries")
    require({path.relative_to(root).as_posix() for path in paths if path.is_file()}
            == {"manifest.json", *files}, "file", "package does not match manifest allowlist")

    def load_file(relative, kind):
        require(lookup(files, relative)["type"] == kind, "file", relative)
        document = read(root / relative)
        validate(schema, document, kind)
        return document

    catalog = load_file(manifest["catalogFile"], "catalog")
    targets = validate_catalog(catalog)
    check_inventory(catalog)
    clips = index(manifest["clips"])
    for clip in clips.values():
        require(lookup(files, clip["file"])["type"] == "audio" and
                clip["locale"] == manifest["locale"], "file", clip["id"])
        require(manifest["usage"] == "developmentFixture" or
                clip["rights"]["status"] == "cleared", "rights", clip["id"])
        validate_pcm_clip(root / clip["file"], clip["durationMs"])
    lessons = {}
    for lesson_id, row in index(manifest["lessons"]).items():
        lesson = load_file(row["file"], "lesson")
        require(lesson["id"] == lesson_id, "reference", lesson_id)
        validate_lesson(lesson, catalog, targets, clips)
        lessons[lesson_id] = lesson
    referenced = {manifest["catalogFile"], *(row["file"] for row in manifest["lessons"]),
                  *(clip["file"] for clip in clips.values())}
    require(set(files) == referenced, "file", "unreferenced file records")
    validate_question_keys(item for lesson in lessons.values() for item in lesson["items"])
    if manifest["usage"] == "bundled":
        validate_education_review(education_review, sha256(manifest_path.read_bytes()).hexdigest())
    return manifest, catalog, lessons


def validate_education_review(review, digest):
    require(isinstance(review, dict) and review.get("manifestSha256") == digest and
            isinstance(review.get("reviewRef"), str) and review["reviewRef"].strip(),
            "review", "independent Education approval must identify this manifest and its review record")


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
    delivery = candidate_deliveries(activity)[item["id"]]
    steps = index(lesson["assistance"])
    delivered_ids = submission["deliveredAssistanceIds"]
    require(set(delivered_ids) <= set(delivery["assistanceIds"]),
            "assistance", "delivery belongs to a different candidate or is unavailable")
    delivered_refs = {ref for step_id in delivered_ids for ref in steps[step_id]["disclosureIds"]}
    require(delivered_refs <= set(submission["exposureAtSubmit"]),
            "exposure", "delivered help missing from frozen exposure")
    disclosure_table = index(lesson["disclosures"])
    exposures = [lookup(disclosure_table, key) for key in submission["exposureAtSubmit"]]
    exposed = any(item["exposureKey"] in row["exposureKeys"] for row in exposures)
    require(not (exposed or submission["requestedMode"] == "guided" or
                 submission["deliveryMode"] == "practice") or
            submission["evidenceClass"] == "assisted", "evidence", "applicable disclosure or guided mode")
    require(submission["evidenceClass"] in {"assisted", submission["requestedMode"]},
            "evidence", "evidence mode mismatch")
    numeric_correct = submission["response"]["confirmedValue"] in item["acceptableAnswers"]
    require(submission["numericOutcome"] == ("correct" if numeric_correct else "incorrect"),
            "response", "numeric outcome differs from frozen answer")
    model = submission["model"]
    outcome = "pending"
    if model["status"] == "observed":
        require(model["representation"] in item["modelOptions"], "response", "model representation")
        correct_partition = (model["whole"] == item["whole"] and
                             sorted((model["partA"], model["partB"])) ==
                             sorted((item["knownPart"], item["expectedAnswer"])))
        outcome = "sufficient" if correct_partition else "incorrect"
    require(submission["modelOutcome"] == outcome, "response", "model outcome differs from frozen model")


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
    activities = index(lesson["activities"])
    observe = lookup(activities, "observe")
    guided_activity = lookup(activities, "try")
    assessment = lookup(activities, "check")
    require([row["kind"] for row in activities.values()] ==
            ["readiness", "observe", "guidedPractice", "assessment"] and
            (observe["kind"], guided_activity["kind"], assessment["kind"]) ==
            ("observe", "guidedPractice", "assessment") and assessment["mode"] == "independent",
            "projection", "accepted U07 phase order and independent check")
    require(guided_activity["worksheetId"] != assessment["worksheetId"],
            "worksheet", "U07 Try and Check require distinct worksheet IDs")
    require(set(lesson["targetIds"]) == {"count-to-10", "match-to-10", "split-to-10"},
            "prerequisite", "U07 target mapping")
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
    guided = lookup(index(lesson["workspaces"]), guided_activity["workspaceId"])
    items = index(lesson["items"])
    for activity, expected in ((observe, (6, 2)), (guided_activity, (7, 1)),
                               (assessment, (8, 3))):
        item = lookup(items, activity["itemId"])
        require((item["whole"], item["knownPart"]) == expected and item["targetId"] == "split-to-10",
                "projection", f"accepted U07 item for {activity['id']}")
    guided_actions = [
        dict(kind="moveCounter", counterId="C1", fromRegionId="tray", toRegionId="bowl"),
        dict(kind="linkBond", partARegionId="bowl", partBRegionId="tray",
             whole=7, partA=1, partB=6),
        dict(kind="clearBond"),
        dict(kind="moveCounter", counterId="C1", fromRegionId="bowl", toRegionId="tray"),
    ]
    guided_cues = [dict(atMs=at, payload=dict(kind="math", action=action))
                   for at, action in enumerate(guided_actions)]
    guided_state = fold(guided, guided_cues, 1)
    require(guided_state["active"] == guided_actions[1] and
            Counter(guided_state["positions"].values()) == {"bowl": 1, "tray": 6},
            "projection", "separate guided 7–1–6 workspace")
    cleared = fold(guided, guided_cues, 2)
    returned = fold(guided, guided_cues, 3)
    baseline = workspace_state(guided)
    require(cleared == dict(positions=guided_state["positions"], active=None, completed=guided_actions[1]) and
            returned == dict(positions=baseline, active=None, completed=guided_actions[1]) and
            set(baseline.values()) == {"tray"},
            "projection", "guided clear and return preserves the completed 7–1–6 bond")

    manual = [chapter["atMs"] for chapter in observe["timeline"]["chapters"]]
    require([Counter(fold(workspace, cues, at)["positions"].values())["bowl"] for at in manual]
            == [0, 1, 2, 2, 0], "projection", "manual chapters")


def patch_fixture(document, change):
    parent = document
    *parents, key = change["path"]
    for component in parents:
        parent = parent[component]
    if change.get("append"):
        parent[key].append(change["value"])
    else:
        parent[key] = change["value"]


def write_fixture_document(path, document):
    path.write_text(json.dumps(document, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def validate_package_case(schema, directory, case, documents):
    """Build temporary, hash-consistent packages for integrity and review probes."""
    root = Path(directory) / "package"
    shutil.copytree(FIXTURE / "package", root)
    manifest = deepcopy(documents["manifest"])
    if case.get("asBundle"):
        manifest["usage"] = "bundled"
        manifest["clips"][0]["rights"] = dict(status="cleared", provenance="Synthetic checker fixture only")
    path = root / "manifest.json"
    write_fixture_document(path, manifest)
    initial_digest = sha256(path.read_bytes()).hexdigest()
    for row in manifest["files"]:
        file = root / row["path"]
        if row["type"] in {"lesson", "catalog"} and case["document"] == row["type"]:
            write_fixture_document(file, documents[row["type"]])
        if row["path"] in case.get("replaceFiles", {}):
            file.write_text(case["replaceFiles"][row["path"]], encoding="utf-8")
        byte_patches = case.get("patchFileBytes", {}).get(row["path"], [])
        if byte_patches:
            data = bytearray(file.read_bytes())
            for patch in byte_patches:
                start = patch["offset"]
                replacement = bytes.fromhex(patch["hex"])
                end = start + len(replacement)
                require(0 <= start < end <= len(data), "fixture", f"invalid byte patch: {file.name}")
                data[start:end] = replacement
            file.write_bytes(data)
        if row["type"] == case["document"] or row["path"] in case.get("replaceFiles", {}) or byte_patches:
            data = file.read_bytes()
            row.update(bytes=len(data), sha256=sha256(data).hexdigest())
    if "removeFile" in case:
        (root / case["removeFile"]).unlink()
    if "extraFile" in case:
        (root / case["extraFile"]).write_text("unlisted", encoding="utf-8")
    write_fixture_document(path, manifest)
    review = None
    if case.get("asBundle") and not case.get("omitReview"):
        digest = sha256(path.read_bytes()).hexdigest() if case.get("repinReview") else initial_digest
        review = dict(manifestSha256=digest, reviewRef="synthetic-review-record-for-checker-only")
    validate_package(schema, root, review)


def check_synthetic_runtime_links(submission, records):
    """Illustrate the join against synthetic records; production lookup belongs to DATA-003."""
    for record in records:
        for field, expected in record.items():
            actual = submission
            for component in field.split("."):
                actual = actual[component]
            require(actual == expected, "runtimeLink", field)


def validate_fixture_case(schema, case, originals, submissions, digest, runtime_records):
    documents = deepcopy(originals)
    documents["submission"] = deepcopy(submissions[case.get("variant", "original")])
    kind = case["document"]
    document = documents[kind]
    for change in ([case] if "path" in case else []) + case.get("changes", []):
        patch_fixture(document, change)

    validate(schema, document, kind)
    if case.get("lessonChanges"):
        lesson = documents["lesson"]
        for change in case["lessonChanges"]:
            patch_fixture(lesson, change)
        validate(schema, lesson, "lesson")
        catalog = documents["catalog"]
        validate_lesson(lesson, catalog, validate_catalog(catalog), index(documents["manifest"]["clips"]))
    if kind == "manifest" or case.get("asBundle") or case.get("package"):
        with TemporaryDirectory() as directory:
            validate_package_case(schema, directory, case, documents)
    elif kind == "catalog":
        validate_catalog(document)
    elif kind == "lesson":
        catalog = documents["catalog"]
        validate_lesson(document, catalog, validate_catalog(catalog), index(documents["manifest"]["clips"]))
    elif kind == "submission":
        validate_submission(document, documents["manifest"], digest, {"U07": documents["lesson"]})
        if case.get("runtimeLinks"):
            check_synthetic_runtime_links(document, runtime_records)


def run_fixtures(schema):
    package = FIXTURE / "package"
    manifest, catalog, lessons = validate_package(schema, package)
    digest = sha256((package / "manifest.json").read_bytes()).hexdigest()
    submission = read(FIXTURE / "submission.json")
    validate(schema, submission, "submission")
    validate_submission(submission, manifest, digest, lessons)

    # Exercise a typed component dependency without making it a U07 prerequisite.
    component_example = deepcopy(catalog)
    component_example["dependencies"].append({
        "kind": "componentMastery", "forTargetId": "match-to-10",
        "componentTargetId": "count-to-10", "evidence": "priorOrConcurrentIndependent",
    })
    validate(schema, component_example, "catalog")
    validate_catalog(component_example)

    assisted = deepcopy(submission)
    assisted.update(response=dict(method="confirmedHandwriting", confirmedValue=5,
                                  inkRevisionId="synthetic-ink-1"),
                    model=dict(status="pending"), modelOutcome="pending",
                    deliveredAssistanceIds=["hint"], exposureAtSubmit=["check-hint"],
                    evidenceClass="assisted")
    replacement = deepcopy(submission)
    replacement.update(id="synthetic-replacement-submission", worksheetItemId="slot-replacement",
                       itemOccurrenceId="synthetic-replacement-1",
                       itemSnapshot=index(lessons["U07"]["items"])["replacement"],
                       model=dict(status="observed", representation="accessibleMarking",
                                  whole=9, partA=4, partB=5),
                       exposureAtSubmit=["check-guide"])
    activity = lookup(index(lessons["U07"]["activities"]), "check")
    delivery = candidate_deliveries(activity)
    steps = index(lessons["U07"]["assistance"])
    for candidate in (submission, replacement):
        item = candidate["itemSnapshot"]
        rule = delivery[item["id"]]
        guide = next(steps[ref] for ref in rule["assistanceIds"] if steps[ref]["stage"] == "guidedAction")
        require(guide["text"].format(knownPart=item["knownPart"]).startswith(
                    f"Move {item['knownPart']} counters"), "fixture", "candidate guide rendering")
        require(rule["feedbackDisclosureIds"] == [f"{item['id']}-feedback"],
                "fixture", "candidate feedback routing")
    validate_submission(submission, manifest, digest, lessons)  # Original remains frozen after later feedback.

    originals = dict(manifest=manifest, catalog=catalog, lesson=lessons["U07"])
    submissions = dict(original=submission, assisted=assisted, replacement=replacement)
    runtime_records = read(FIXTURE / "runtime-links.json")
    positives = sorted((FIXTURE / "valid").glob("*.json"))
    negatives = sorted((FIXTURE / "invalid").glob("*.json"))
    require(len(negatives) >= 23 and positives, "fixture", "missing regression cases")
    for path in positives:
        validate_fixture_case(schema, read(path), originals, submissions, digest, runtime_records)
        print(f"Accepted {path.stem}")
    for path in negatives:
        case = read(path)
        try:
            validate_fixture_case(schema, case, originals, submissions, digest, runtime_records)
        except ContractError as error:
            require(str(error).startswith(case["expected"] + ":"), "fixture", f"{path.name}: {error}")
            print(f"Rejected {path.stem} ({case['expected']})")
        else:
            raise ContractError(f"fixture: accepted {path.name}")
    print("PASS: schema, package, submission, CUR-002 anchors, U07 cue projection, "
          f"{len(positives)} positive and {len(negatives)} negative regression fixtures")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, help="validate this package instead of running U07 fixtures")
    parser.add_argument("--education-review", type=Path, help="external Education approval for a bundled manifest")
    parser.add_argument("--bundle-file-list", action="store_true",
                        help="emit the validated bundled package's relative allowlist, one path per line")
    args = parser.parse_args()
    if (args.education_review or args.bundle_file_list) and not args.package:
        parser.error("--education-review and --bundle-file-list require --package")
    try:
        schema = read(SCHEMA)
        Draft202012Validator.check_schema(schema)
        if args.package:
            review = read(args.education_review) if args.education_review else None
            manifest, _, _ = validate_package(schema, args.package, review)
            if args.bundle_file_list:
                require(manifest["usage"] == "bundled", "file", "allowlist emission requires bundled usage")
                print("manifest.json", *(row["path"] for row in manifest["files"]), sep="\n")
            else:
                print(f"PASS: {args.package}")
        else:
            run_fixtures(schema)
    except (ContractError, OSError, ValueError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
