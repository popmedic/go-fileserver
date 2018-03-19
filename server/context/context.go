package context

import (
	"io/ioutil"

	"github.com/popmedic/go-logger/log"
)

// Context for use with the server
type Context struct {
	Exit func(int)

	Key  []byte
	Cert []byte
	Spec []byte
}

// NewContext creates a new Context using the file paths keyPath, certPath, specPath
// setting Key, Cert, Spec respectively, using exit for Exit.
func NewContext(keyPath, certPath, specPath string, exit func(int)) *Context {
	return &Context{
		Exit: exit,
		Key:  mustReadFile(exit, keyPath),
		Cert: mustReadFile(exit, certPath),
		Spec: mustReadFile(exit, specPath),
	}
}

// MustReadFile will read in a file from path,
// or exit the application calling exitFunc
func mustReadFile(exitFunc func(int), path string) []byte {
	b, e := ioutil.ReadFile(path)
	if nil != e {
		log.Fatal(exitFunc, e)
	}
	return b
}
