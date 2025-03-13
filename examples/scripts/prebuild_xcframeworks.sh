#!/bin/bash
set -e

build_framework_slice() {
    local name="$1"
    local sdk="$2"
    set -o pipefail && xcodebuild \
        -project PrebuiltSources/PrebuiltSources.xcodeproj \
        -scheme "${name}" \
        -config Debug \
        -sdk ${sdk} \
        -derivedDataPath build \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        | xcbeautify
}

build_xcframework() {
    local name="$1"
    local output="$2"
    local output_nonzip="${output%.zip}"
    build_framework_slice "${name}" iphoneos
    build_framework_slice "${name}" iphonesimulator
    rm -rf "${output_nonzip}"
    xcodebuild -create-xcframework \
        -framework build/Build/Products/Debug-iphoneos/${name}.framework \
        -framework build/Build/Products/Debug-iphonesimulator/${name}.framework \
        -output "${output_nonzip}"
    if [[ "${output}" == *.zip ]]; then
        cd $(dirname "${output}") && zip -r $(basename "${output}") $(basename "${output_nonzip}") && cd -
        rm -rf "${output_nonzip}"
    fi
}

build_xcframework NetworkInterceptor LocalPackages/debug-kit/Frameworks/NetworkInterceptor.xcframework
build_xcframework NetworkLogger LocalPackages/debug-kit/Frameworks/NetworkLogger.xcframework.zip
