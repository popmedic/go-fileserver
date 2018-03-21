package config

import (
	"encoding/json"
	"io"
)

// Config type for this project
type Config map[string]string

// NewConfig creates a new config object
func NewConfig() *Config {
	c := make(Config)
	return &c
}

// LoadFromReader loads the Config from the reader (JSON)
func (c *Config) LoadFromReader(r io.Reader) error {
	return json.NewDecoder(r).Decode(c)
}

// GetParam returns the param
func (c *Config) GetParam(param string) string {
	return (*c)[param]
}

// SetParam sets the param
func (c *Config) SetParam(param, value string) {
	(*c)[param] = value
}
