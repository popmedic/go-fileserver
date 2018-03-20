#!/usr/bin/env bash
set -o errexit
## Test the application

# application name
APP_NAME="go-fileserver"

echo -e "**> Testing ${APP_NAME}"

go test ./... -cover
