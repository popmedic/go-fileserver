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

source build_config.sh

echo -e "*> Building docker: ${DOCKER_FILE} with build directory: ${DOCKER_DIR}"
mkdir -p "${DOCKER_DIR}"
cp "${APP_PATH}" "${DOCKER_DIR}"
cp -r "${CERTS_DIR}" "${DOCKER_DIR}/${CERTS_DIR}"
cp -r "${SWAGGER_DIR}" "${DOCKER_DIR}/${SWAGGER_DIR}"
cp "${DOCKER_FILE}" "${DOCKER_DIR}"

pushd "${DOCKER_DIR}" >> /dev/null
docker build . \
--no-cache \
-t "${DOCKER_TAG}" \
--build-arg APP="${APP_NAME}" \
--build-arg INSTALL_DIR="${INSTALL_DIR}" \
--build-arg CERTS_DIR="${CERTS_DIR}" \
--build-arg SWAGGER_DIR="${SWAGGER_DIR}" \
--build-arg CONFIG_PATH="${CONFIG_PATH}"
popd >> /dev/null
