## Build the go fileserver

# directory for build binary
BIN_DIR="${BUILD_DIR}/bin"
# application's main
APP_MAIN="app/main.go"
# path to application
APP_PATH="${BIN_DIR}/${APP_NAME}"

mkdir -p "${BIN_DIR}"

echo -e "*> Building ${APP_NAME}(${APP_PATH}) with main: ${APP_MAIN}"
GOOS=linux GOARCH=amd64 go build -o "${APP_PATH}" "${APP_MAIN}"
