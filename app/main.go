package main

import (
	"flag"
	"os"
	"path/filepath"

	"github.com/popmedic/go-fileserver/server"
	"github.com/popmedic/go-fileserver/server/context"
	"github.com/popmedic/go-logger/log"
)

var certPath string
var keyPath string
var specPath string

func init() {
	d, e := filepath.Abs(filepath.Dir(os.Args[0]))
	if nil != e {
		log.Fatal(os.Exit, "UNABLE TO DETERMINE WORKING DIRECTORY")
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
		&specPath,
		"spec_path",
		filepath.Join(d, "swagger", "go-fileserver.yaml"),
		"path to the swagger spec yaml file",
	)
}

func main() {
	flag.Parse()

	log.Info("Cert path:", certPath)
	log.Info("Private key path:", keyPath)
	log.Info("Swagger spec path:", specPath)

	ctx := context.NewContext(keyPath, certPath, specPath, os.Exit)
	server.Run(ctx)
}
