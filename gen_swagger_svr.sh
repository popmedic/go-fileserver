# Build for swagger

SWAGGER_DIR="swagger"
SWAGGER_NAME=${APP_NAME}
SWAGGER_FILE="${SWAGGER_DIR}/${SWAGGER_NAME}.yaml"

echo -e "*> Generating swagger server from ${SWAGGER_FILE} (configuration only)"
