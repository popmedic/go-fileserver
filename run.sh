#!/usr/bin/env bash

source build.sh

echo "*> Running ${APP_NAME}"
docker run --rm go-fileserver:latest \
-cert_path "${INSTALL_DIR}/${CERT_FILE}" \
-key_path "${INSTALL_DIR}/${KEY_FILE}" \
-spec_path "${INSTALL_DIR}/${SWAGGER_FILE}"
