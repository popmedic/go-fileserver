## Build the go fileserver

# directory for build binary
BIN_DIR="${BUILD_DIR}/bin"
# application's main
APP_MAIN="cmd/server/main.go"
# path to application
APP_PATH="${BIN_DIR}/${APP_NAME}"

mkdir -p "${BIN_DIR}"

echo -e "*> Building ${APP_NAME}(${APP_PATH}) with main: ${APP_MAIN}"
GOOS=${GOOS} GOARCH=${GOARCH} go build -o "${APP_PATH}" "${APP_MAIN}"
