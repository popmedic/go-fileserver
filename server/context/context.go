package context

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/popmedic/go-fileserver/server/config"
	"github.com/popmedic/go-logger/log"
)

const (
	exitCodeReadFile = iota + 1
)

const (
	ConfigAddrParam                = "Addr"
	defaultConfigAddr              = ":https"
	ConfigReadTimeoutParam         = "ReadTimeout"
	defaultConfigReadTimeout       = "0"
	ConfigReadHeaderTimeoutParam   = "ReadHeaderTimeout"
	defaultConfigReadHeaderTimeout = "30s"
	ConfigWriteTimeoutParam        = "WriteTimeout"
	defaultConfigWriteTimeout      = "1m"
	ConfigIdleTimeoutParam         = "IdleTimeout"
	defaultConfigIdleTimeout       = "0"
	ConfigMaxHeaderBytesParam      = "MaxHeaderBytes"
)

// Context for use with the server
type Context struct {
	Exit       func(int)
	KeyPath    string
	CertPath   string
	SpecPath   string
	ConfigPath string

	Key    []byte
	Cert   []byte
	Spec   []byte
	Config config.IConfig
}

// NewContext creates a new Context using the file paths keyPath, certPath, specPath
// setting Key, Cert, Spec respectively, using exit for Exit.
func NewContext(keyPath, certPath, specPath, configPath string, exit func(int)) *Context {
	return &Context{
		Exit:       exit,
		KeyPath:    keyPath,
		CertPath:   certPath,
		SpecPath:   specPath,
		ConfigPath: configPath,
		Key:        mustReadFile(exit, keyPath),
		Cert:       mustReadFile(exit, certPath),
		Spec:       mustReadFile(exit, specPath),
		Config:     mustReadConfig(configPath),
	}
}

// MustReadFile will read in a file from path,
// or exit the application calling exitFunc
func mustReadFile(exitFunc func(int), path string) []byte {
	b, e := ioutil.ReadFile(path)
	if nil != e {
		log.Error(e)
		exitFunc(exitCodeReadFile)
		return nil
	}
	return b
}

func setDefaults(c config.IConfig) {
	c.SetParam(ConfigAddrParam, defaultConfigAddr)
	c.SetParam(ConfigReadTimeoutParam, defaultConfigReadTimeout)
	c.SetParam(ConfigReadHeaderTimeoutParam, defaultConfigReadHeaderTimeout)
	c.SetParam(ConfigWriteTimeoutParam, defaultConfigWriteTimeout)
	c.SetParam(ConfigIdleTimeoutParam, defaultConfigIdleTimeout)
	c.SetParam(ConfigMaxHeaderBytesParam, fmt.Sprintf("%d", http.DefaultMaxHeaderBytes))
}

func mustReadConfig(path string) config.IConfig {
	r, e := os.Open(path)
	if nil != e {
		log.Warn(e)
	}

	c := config.NewConfig()
	setDefaults(c)
	e = c.LoadFromReader(r)
	if nil != e {
		log.Warn(e)
	}

	return c
}
