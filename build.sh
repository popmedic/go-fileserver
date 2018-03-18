#!/usr/bin/env bash
set -o errexit
## Build the project

# artifact directory
ARTIFACT_DIR="artifact"
# build directory
BUILD_DIR="${ARTIFACT_DIR}/build"

mkdir -p "${BUILD_DIR}"


source build_fileserver.sh
source build_docker.sh