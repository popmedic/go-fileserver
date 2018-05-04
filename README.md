#go-fileserver

> A simple file server done in go, with a neat iOS client.

[![Build Status](https://travis-ci.org/popmedic/go-fileserver.svg?branch=master)](https://travis-ci.org/popmedic/go-fileserver)
[![codecov](https://codecov.io/gh/popmedic/go-fileserver/branch/master/graph/badge.svg)](https://codecov.io/gh/popmedic/go-fileserver)

## Objective

Create a simple file server in go with complete deployment in bash.  The file server servers content as a RESTful HTTP server over SSL/TSL.  The build scripts will:
- create self-signed certificates if they do not exist.
- generate server stubs from Swagger with `swagger-codegen` if they do not already exist.
- generating a configuration and user
- deploy the build into a Docker container
- run the Docker container locally

The client is just a cute little iOS app that will authenticate/authorize with the server, and if authorized to do so, show the files exposed by the server.

> This projects **server** requires the following on the build machine:
> - Go 1.9.x or greater
> - Docker

> The **client** build machine requires:
> - MacOs
> - Xcode 9.x with commandline tools

## Server

### Test

To test the Go server, run the test script with:

```
./test
```

additional arguments can be passed into the tests from the commandline, as is done in the TravisCI with:

```
./test  -race -coverprofile=coverage.txt -covermode=atomic
```

### Build

> Dependency: Tests pass

Building the server includes: creating certs if they do not exist; generating the server stubs from Swagger; adding a default admin user and config file; and building a docker image.  To run the build process:

```
./build.sh
```

### Run

> Dependency: Tests pass, Build succeeds

To run the build locally:

```
./run.sh
```

This will run the docker exposing port `8443`.  You can test the REST API's by using https://localhost:8443 with the correct JSON from Postman or CURL or ...

## Client

The client is a iOS app, and as such can be built in Xcode.