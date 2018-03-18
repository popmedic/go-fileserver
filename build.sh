#!/usr/bin/env bash

## Build the project

# artifact directory
ARTIFACT_DIR="artifact"
# build directory
BUILD_DIR="${ARTIFACT_DIR}/build"

set +e

mkdir -p "${BUILD_DIR}"


source build_fileserver.sh
source build_docker.sh