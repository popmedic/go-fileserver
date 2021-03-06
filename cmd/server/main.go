package main

import (
	"flag"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/popmedic/go-fileserver/server"
	"github.com/popmedic/go-fileserver/server/context"
	"github.com/popmedic/go-logger/log"
)

var certPath string
var keyPath string
var specPath string
var configPath string
var usersPath string
var exposePath string
var verbose bool

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
	flag.StringVar(
		&configPath,
		"config_path",
		filepath.Join(d, "config.json"),
		"path to the config json file",
	)
	flag.StringVar(
		&usersPath,
		"users_path",
		filepath.Join(d, "users.json"),
		"path to the users json file",
	)
	flag.StringVar(
		&exposePath,
		"expose_path",
		filepath.Join(d, "expose"),
		"path to expose",
	)
	flag.BoolVar(
		&verbose,
		"verbose",
		false,
		"if set will log debug statements",
	)
}

func main() {
	flag.Parse()

	if !verbose {
		log.GetDebug().SetWriter(ioutil.Discard)
	}
	ctx := context.NewContext(keyPath, certPath, specPath, configPath, usersPath, exposePath, os.Exit)
	s := server.NewServer(ctx)
	err := s.Run()
	if err != nil {
		log.Fatal(ctx.Exit, "ListenAndServe: ", err)
	}
}
