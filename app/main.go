package main

import (
	"flag"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/popmedic/go-logger/log"
)

var certPath string
var keyPath string
var swaggerPath string

func init() {
	d, e := filepath.Abs(filepath.Dir(os.Args[0]))
	if nil != e {
		panic("UNABLE TO DETERMINE WORKING DIRECTORY")
	}

	flag.StringVar(
		&certPath,
		"cert_path",
		filepath.Join(d, "certs", "cert.pem"),
		"path to the certificate file",
	)
	flag.StringVar(
		&keyPath,
		"key_path",
		filepath.Join(d, "certs", "key.pem"),
		"path to the private key file",
	)
	flag.StringVar(
		&swaggerPath,
		"swagger_path",
		filepath.Join(d, "swagger", "go-fileserver.yaml"),
		"path to the swagger spec yaml file",
	)
}

func mustReadFile(path string) []byte {
	b, e := ioutil.ReadFile(path)
	if nil != e {
		log.Fatal(os.Exit, e)
	}
	return b
}

func main() {
	flag.Parse()

	log.Info("Cert path:", certPath)
	log.Info("Private key path:", keyPath)
	log.Info("Swagger path:", swaggerPath)

	b := mustReadFile(certPath)
	log.Debug("Cert:\n", string(b))

	b = mustReadFile(keyPath)
	log.Debug("Key:\n", string(b))

	b = mustReadFile(swaggerPath)
	log.Debug("Swagger:\n", string(b))
}
