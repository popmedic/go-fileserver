package config

// IConfig is an interface for configuration.
type IConfig interface {
	// GetParam returns the param
	GetParam(param string) string
	// GetParam returns the param or dflt if the param does not exist
	GetParamDefault(param, dflt string) string
	// SetParam sets the param
	SetParam(param, value string)
}
