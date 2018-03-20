package config

import (
	"strings"
	"testing"
)

type row struct {
	key string
	val string
}

var tt []row

func TestSetup(t *testing.T) {
	tt = []row{
		{key: "1", val: "one"},
		{key: "2", val: "two"},
		{key: "3", val: "three"},
		{key: "one", val: "1"},
		{key: "two", val: "2"},
		{key: "three", val: "3"},
	}
}

func TestNewConfigFromReader(t *testing.T) {
	r := strings.NewReader(`{"1":"one","2":"two","3":"three","one":"1","two":"2","three":"3"}`)
	c := NewConfig()
	err := c.LoadFromReader(r)
	if nil != err {
		t.Fatal(err)
	}
	for _, r := range tt {
		if got := c.GetParam(r.key); got != r.val {
			t.Errorf("for key %q, expected %q, got %q", r.key, r.val, got)
		}
	}
}

func TestNewConfigFromReaderFailure(t *testing.T) {
	r := strings.NewReader(`{"1":"one","2":"two","3":"three","one":"1","two":"2","three":"3"`)
	c := NewConfig()
	err := c.LoadFromReader(r)
	if nil == err {
		t.Error("should have failed to read the json")
	}
}

func TestConfig(t *testing.T) {
	c := NewConfig()
	// error testing
	for _, r := range tt {
		if got := c.GetParamDefault(r.key, "def"); got != "def" {
			t.Errorf("for key %q, expected %q, got %q", r.key, "", got)
		}
	}
	// set up success
	for _, r := range tt {
		c.SetParam(r.key, r.val)
	}
	// test all where set
	for _, r := range tt {
		if got := c.GetParamDefault(r.key, "def"); got != r.val {
			t.Errorf("for key %q, expected %q, got %q", r.key, r.val, got)
		}
	}
}
