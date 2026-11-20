#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 3 || ( "$1" != build && "$1" != test ) ]]; then
    echo "Usage: $0 {build|test} <iPad simulator UDID> <absolute DerivedData path>" >&2
    exit 64
fi

action=$1
simulator=$2
derived_data=$3
cd "$(dirname "$0")/.."

if [[ "$action" == test ]]; then
    xcrun swift test --package-path app/JuniCore --scratch-path "$derived_data/JuniCore"
fi

xcodebuild \
    -project app/Juni.xcodeproj \
    -scheme Juni \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=$simulator" \
    -derivedDataPath "$derived_data" \
    -disableAutomaticPackageResolution \
    -parallel-testing-enabled NO \
    CODE_SIGNING_ALLOWED=NO \
    "$action"
