#!/bin/bash
set -e

prepare_simulator() {
    local runtime=$(xcrun simctl list runtimes | grep -o 'com.apple.CoreSimulator.SimRuntime.iOS-.*-.*' | tail -n 1)
    local device_type=com.apple.CoreSimulator.SimDeviceType.iPhone-15
    if ! xcrun simctl list devices | grep EX &> /dev/null; then
        echo Created device: $(xcrun simctl create EX ${device_type} ${runtime})
    fi
}

xcodebuild_exec() {
    local log_formatter="tee"
    if which xcbeautify &> /dev/null; then
        log_formatter="xcbeautify"
    elif bundle info xcpretty &> /dev/null; then
        log_formatter="bundle exec xcpretty"
    elif which xcpretty &> /dev/null; then
        log_formatter="xcpretty"
    fi

    mkdir -p .logs
    set -o pipefail && \
        xcodebuild \
        -workspace EX.xcworkspace \
        -scheme EX \
        -config Debug \
        -destination 'platform=iOS Simulator,name=EX' \
        -derivedDataPath DerivedData \
        ${XCODEBUILD_ACTION:-build} \
        CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
        | tee .logs/xcodebuild.txt | ${log_formatter}
}

prepare_simulator
xcodebuild_exec
