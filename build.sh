#!/usr/bin/env bash
set -o errexit
## Build the project
# test first!
source test.sh
# artifact directory
ARTIFACT_DIR="artifact"
# build directory
BUILD_DIR="${ARTIFACT_DIR}/build"
# go build environments
GOOS=linux 
GOARCH=amd64 

mkdir -p "${BUILD_DIR}"

echo "*> Building ${APP_NAME}"
source create_certs.sh
source gen_swagger_svr.sh
source build_fileserver.sh
source build_docker.sh
echo "*> *** Build successful ***"