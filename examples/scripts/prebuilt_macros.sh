#!/bin/bash
set -e

if [[ $1 == zip ]]; then
    find .spm.pods/* -type d -name ".prebuilt" -exec zip -r cache/prebuilt_macros.zip {} \;
elif [[ $1 == unzip ]]; then
    unzip -o cache/prebuilt_macros.zip
fi
