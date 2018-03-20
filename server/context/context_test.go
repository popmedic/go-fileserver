package context

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/popmedic/go-fileserver/server/config"
	"github.com/popmedic/go-logger/log"
)

var path string

const (
	jsonPath    = "test_data/config.json"
	badJSONPath = "test_data/config-bad.json"
)

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
			paths[0],
			paths[1],
			paths[2],
			jsonPath,
			exitFunc,
		)
		if !success {
			t.Error("should have failed")
		}
	}
}

func isDefault(c config.IConfig) bool {
	return c.GetParam(ConfigAddrParam) == defaultConfigAddr &&
		c.GetParam(ConfigReadTimeoutParam) == defaultConfigReadTimeout &&
		c.GetParam(ConfigReadHeaderTimeoutParam) == defaultConfigReadHeaderTimeout &&
		c.GetParam(ConfigWriteTimeoutParam) == defaultConfigWriteTimeout &&
		c.GetParam(ConfigIdleTimeoutParam) == defaultConfigIdleTimeout &&
		c.GetParam(ConfigMaxHeaderBytesParam) == fmt.Sprintf("%d", http.DefaultMaxHeaderBytes)
}

func TestNewContextConfigDefaultOpenFile(t *testing.T) {
	success := false
	exitCode := 0
	exitFunc := func(i int) {
		exitCode = i
		success = true
	}

	c := NewContext(path, path, path, "*", exitFunc)
	if !isDefault(c.Config) {
		t.Error("config should be default", c.Config)
	}
}
func TestNewContextConfigFailureReadJSON(t *testing.T) {
	success := false
	exitCode := 0
	exitFunc := func(i int) {
		exitCode = i
		success = true
	}
	createBadJSONFile(jsonPath, badJSONPath, t)
	defer func(p string) {
		_ = os.Remove(p)
	}(badJSONPath)
	c := NewContext(path, path, path, badJSONPath, exitFunc)
	if !isDefault(c.Config) {
		t.Error("config should be default", c.Config)
	}
}

func TestNewContext(t *testing.T) {
	exitFunc := func(int) {
		t.Error("should not have failed:", path)
	}

	_ = NewContext(path, path, path, jsonPath, exitFunc)
}

func createBadJSONFile(src, dest string, t *testing.T) {
	b, err := ioutil.ReadFile(src)
	if nil != err {
		t.Fatal(err)
		return
	}
	b = []byte(strings.Replace(string(b), ",", "", -1))
	err = ioutil.WriteFile(dest, b, os.ModePerm)
	if nil != err {
		t.Fatal(err)
		return
	}
}
