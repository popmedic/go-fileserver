#!/usr/bin/env bash

source build.sh

echo -e "*> Running ${APP_NAME} \\"
echo -e "*>             -cert_path=\"${INSTALL_DIR}/${CERT_FILE}\" \\"
echo -e "*>             -key_path=\"${INSTALL_DIR}/${KEY_FILE}\" \\"
echo -e "*>             -spec_path=\"${INSTALL_DIR}/${SWAGGER_FILE}\" \\"
echo -e "*>             -config_path=\"${INSTALL_DIR}/${CONFIG_PATH}\" \\"
echo -e "*>             -users_path=\"${INSTALL_DIR}/users.json\""
docker run --rm \
-p 8443:8443 \
--mount type=bind,source=/Volumes/Media,destination=/media/Media,consistency=cached \
go-fileserver:latest \
-cert_path "${INSTALL_DIR}/${CERT_FILE}" \
-key_path "${INSTALL_DIR}/${KEY_FILE}" \
-spec_path "${INSTALL_DIR}/${SWAGGER_FILE}" \
-config_path "${INSTALL_DIR}/${CONFIG_PATH}" \
-users_path "${INSTALL_DIR}/users.json"
