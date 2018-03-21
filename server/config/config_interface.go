package config

// IConfig is an interface for configuration.
type IConfig interface {
	// GetParam returns the param
	GetParam(param string) string
	// SetParam sets the param
	SetParam(param, value string)
}
