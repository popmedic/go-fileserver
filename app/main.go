package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

var certPath string
var keyPath string

func init() {
	d, e := filepath.Abs(filepath.Dir(os.Args[0]))
	if nil != e {
		panic("UNABLE TO DETERMINE WORKING DIRECTORY")
	}
	flag.StringVar(&certPath, "cert_path", filepath.Join(d, "certs", "cert.pem"), "path to the certificate file")
	flag.StringVar(&keyPath, "key_path", filepath.Join(d, "certs", "key.pem"), "path to the private key file")
}

func main() {
	flag.Parse()

	fmt.Println("Cert path:", certPath)
	fmt.Println("Private key path:", keyPath)

	b, e := ioutil.ReadFile(certPath)
	if nil != e {
		fmt.Println(e)
		os.Exit(1)
	}
	fmt.Println("Cert:\n", string(b))

	b, e = ioutil.ReadFile(keyPath)
	if nil != e {
		fmt.Println(e)
		os.Exit(1)
	}
	fmt.Println("Key:\n", string(b))
}
