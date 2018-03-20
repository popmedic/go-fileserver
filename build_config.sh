## Builds a config file if config.json is not in root of project

CONFIG_DIR="."
CONFIG_NAME="config.json"
CONFIG_PATH="${CONFIG_DIR}/${CONFIG_NAME}"

CONFIG_ADDR=":https"
CONFIG_READ_TIMEOUT="0ns"
CONFIG_READ_HEADER_TIMEOUT="30s"
CONFIG_WRITE_TIMEOUT="2m"
CONFIG_IDLE_TIMEOUT="0ns"
CONFIG_MAX_HEADER_BYTES="1048576"

mkdir -p "${DOCKER_DIR}/${CONFIG_DIR}"

if [ -f "${CONFIG_FILE}" ]
then 
cp  "${CONFIG_FILE}" "${DOCKER_DIR}/${CONFIG_DIR}/"
else
echo -e "{
    \"Addr\":\"${CONFIG_ADDR}\",
    \"ReadTimeout\":\"${CONFIG_READ_TIMEOUT}\",
    \"ReadHeaderTimeout\":\"${CONFIG_READ_HEADER_TIMEOUT}\",
    \"WriteTimeout\":\"${CONFIG_WRITE_TIMEOUT}\",
    \"IdleTimeout\":\"${CONFIG_IDLE_TIMEOUT}\",
    \"MaxHeaderBytes\":\"${CONFIG_MAX_HEADER_BYTES}\"
}" > "${DOCKER_DIR}/${CONFIG_PATH}"
fi
