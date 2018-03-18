#!/usr/bin/env bash

# Build the Docker image

# directory for Docker building
DOCKER_DIR="${BUILD_DIR}/docker"
# docker file
DOCKER_FILE="docker/Dockerfile"
# docker tag version
if [ -z $VERSION ]; then DOCKER_VERSION="latest"; fi
# docker tag
if [ -z $DOCKER_TAG ]; then DOCKER_TAG="${APP_NAME}:${DOCKER_VERSION}"; fi
# docker installation directory
INSTALL_DIR=/var/popmedic

mkdir -p "${DOCKER_DIR}"
cp "${APP_PATH}" "${DOCKER_DIR}"
cp "${DOCKER_FILE}" "${DOCKER_DIR}"

pushd "${DOCKER_DIR}" >> /dev/null
docker build . \
-t "${DOCKER_TAG}" \
--build-arg APP="${APP_NAME}" \
--build-arg APP_DIR="${INSTALL_DIR}" 
popd >> /dev/null
