package context

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"

	"github.com/popmedic/go-logger/log"
)

var path string

func TestSetup(t *testing.T) {
	// set the logging off
	log.SetOutput(ioutil.Discard)
	// set up a good file path, ourselves.
	b, err := filepath.Abs(os.Args[0])
	if nil != err {
		t.Error(err)
	}
	path = string(b)
}

func TestNewContextFailure(t *testing.T) {
	success := false
	exitFunc := func(int) {
		success = true
	}

	for _, paths := range [][3]string{
		[3]string{"*", "*", path},
		[3]string{"*", path, path},
		[3]string{path, "*", "*"},
		[3]string{"*", "*", "*"},
		[3]string{path, "*", path},
	} {
		_ = NewContext(
			string(paths[0]),
			string(paths[1]),
			string(paths[2]),
			exitFunc,
		)
		if !success {
			t.Error("should have failed")
		}
	}
}

func TestNewContextFile(t *testing.T) {
	exitFunc := func(int) {
		t.Error("should not have failed:", path)
	}

	_ = NewContext(path, path, path, exitFunc)
}
