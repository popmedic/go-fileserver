#!/usr/bin/env bash

## Build the go fileserver

# directory for build binary
BIN_DIR="${BUILD_DIR}/bin"
# application name
APP_NAME="go-fileserver"
# application's main
APP_MAIN="app/main.go"
# path to application
APP_PATH="${BIN_DIR}/${APP_NAME}"

mkdir -p "${BIN_DIR}"


GOOS=linux GOARCH=amd64 go build -o "${APP_PATH}" "${APP_MAIN}"