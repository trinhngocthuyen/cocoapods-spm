#!/bin/bash
set -e

if [[ $1 == zip ]]; then
    zip -r cache/prebuilt_macros.zip .spm.pods/macros/.prebuilt
elif [[ $1 == unzip ]]; then
    [[ ${CI} ]] && ARGS=(o) || ARGS=(n)
    unzip -${ARGS} cache/prebuilt_macros.zip
fi
