#!/usr/bin/env bash
set -o errexit
## Build the project

# application name
APP_NAME="go-fileserver"
# artifact directory
ARTIFACT_DIR="artifact"
# build directory
BUILD_DIR="${ARTIFACT_DIR}/build"

mkdir -p "${BUILD_DIR}"

echo "*> Building ${APP_NAME}"
source create_certs.sh
source build_fileserver.sh
source build_docker.sh
