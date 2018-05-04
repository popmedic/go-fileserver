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
	jsonPath     = "test_data/config.json"
	usersPath    = "test_data/users.json"
	badJSONPath  = "test_data/config-bad.json"
	badUsersPath = "test_data/users-bad.json"
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
			usersPath,
			"",
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
	exitFunc := func(i int) {}

	c := NewContext(path, path, path, "*", usersPath, "", exitFunc)
	if !isDefault(c.Config) {
		t.Error("config should be default", c.Config)
	}
}
func TestNewContextConfigFailureReadJSON(t *testing.T) {
	exitFunc := func(i int) {}
	createBadJSONFile(jsonPath, badJSONPath, t)
	defer func(p string) {
		_ = os.Remove(p)
	}(badJSONPath)
	c := NewContext(path, path, path, badJSONPath, usersPath, "", exitFunc)
	if !isDefault(c.Config) {
		t.Error("config should be default", c.Config)
	}
}

func TestNewContextConfigFailureReadUsers(t *testing.T) {
	exitFunc := func(i int) {}
	createBadJSONFile(jsonPath, badUsersPath, t)
	defer func(p string) {
		_ = os.Remove(p)
	}(badUsersPath)
	c := NewContext(path, path, path, jsonPath, badUsersPath, "", exitFunc)
	if c.Users.Get(defaultKey) != defaultClaim {
		t.Errorf("should have created default user %q at level %q", defaultKey, defaultClaim)
	}
}

func TestNewContext(t *testing.T) {
	exitFunc := func(int) {
		t.Error("should not have failed:", path)
	}

	_ = NewContext(path, path, path, jsonPath, usersPath, "", exitFunc)
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

func TestPrependExposed(t *testing.T) {
	type row struct {
		exposed string
		given   string
		exp     string
	}
	tt := []row{
		row{
			exposed: "test/this",
			given:   "path/out",
			exp:     "test/this/path/out",
		},
		row{
			exposed: "/test/this",
			given:   "/path/out/",
			exp:     "/test/this/path/out",
		},
		row{
			exposed: "/test/this/",
			given:   "/path/out/",
			exp:     "/test/this/path/out",
		},
		row{
			exposed: "test/this/",
			given:   "/path/out/",
			exp:     "test/this/path/out",
		},
	}
	for _, r := range tt {
		ctx := &Context{ExposePath: r.exposed}
		testExposed(t, ctx.PrependExposed, "PrependExposed", r.given, r.exp)
	}
}

func TestTrimExposed(t *testing.T) {
	type row struct {
		exposed string
		given   string
		exp     string
	}
	tt := []row{
		row{
			exposed: "test/this",
			given:   "test/this/path/out",
			exp:     "/path/out",
		},
		row{
			exposed: "/test/this/",
			given:   "/test/this/path/out/",
			exp:     "/path/out",
		},
		row{
			exposed: "/test/this/",
			given:   "test/this/path/out/",
			exp:     "/path/out",
		},
		row{
			exposed: "test/this/",
			given:   "test/this///path/out/",
			exp:     "/path/out",
		},
		row{
			exposed: "/test/this/",
			given:   "/path/out/",
			exp:     "/path/out",
		},
	}
	for _, r := range tt {
		ctx := &Context{ExposePath: r.exposed}
		testExposed(t, ctx.TrimExposed, "TrimExposed", r.given, r.exp)
	}
}

func testExposed(t *testing.T, function func(string) string, name, given, exp string) {
	got := function(given)
	if got != exp {
		t.Errorf("%s: given %q expected %q got %q", name, given, exp, got)
	}
}
