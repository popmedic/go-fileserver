#!/usr/bin/env bash

source build.sh

if [ ! -z EXPOSE_PATH ]; then EXPOSE_PATH="/media/Media"; fi
if [ ! -z BIND_PATH ]; then BIND_PATH="/Volumes/Media"; fi

echo -e "*> Running ${APP_NAME} -verbose \\"
echo -e "*>             -cert_path=\"${INSTALL_DIR}/${CERT_FILE}\" \\"
echo -e "*>             -key_path=\"${INSTALL_DIR}/${KEY_FILE}\" \\"
echo -e "*>             -spec_path=\"${INSTALL_DIR}/${SWAGGER_FILE}\" \\"
echo -e "*>             -config_path=\"${INSTALL_DIR}/${CONFIG_PATH}\" \\"
echo -e "*>             -users_path=\"${INSTALL_DIR}/users.json\" \\"
echo -e "*>             -expose_path=\"${EXPOSE_PATH}\""
docker run --rm \
-p 8443:8443 \
--mount type=bind,source=${BIND_PATH},destination=${EXPOSE_PATH},consistency=cached \
go-fileserver:latest \
-verbose \
-cert_path "${INSTALL_DIR}/${CERT_FILE}" \
-key_path "${INSTALL_DIR}/${KEY_FILE}" \
-spec_path "${INSTALL_DIR}/${SWAGGER_FILE}" \
-config_path "${INSTALL_DIR}/${CONFIG_PATH}" \
-users_path "${INSTALL_DIR}/users.json" \
-expose_path "${EXPOSE_PATH}"
