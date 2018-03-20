package server

import (
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"github.com/popmedic/go-fileserver/server/config"
	"github.com/popmedic/go-fileserver/server/context"
	"github.com/popmedic/go-logger/log"
)

func showConfig(ctx *context.Context) {
	log.Info("Cert path:", ctx.CertPath)
	log.Info("Private key path:", ctx.KeyPath)
	log.Info("Swagger spec path:", ctx.SpecPath)
	b, err := json.MarshalIndent(ctx.Config, "> ", "  ")
	if nil != err {
		log.Fatal(ctx.Exit, err)
	}
	log.Info("Config:\n> ", string(b))
}

func parseDuration(s string) time.Duration {
	d, err := time.ParseDuration(s)
	if nil != err {
		return time.Duration(0)
	}
	return d
}

func parseInt(s string) int {
	i, err := strconv.ParseInt(s, 10, 0)
	if nil != err {
		return 0
	}
	return int(i)
}

func newServerWithConfig(c config.IConfig) *http.Server {
	return &http.Server{
		Addr:              c.GetParam(context.ConfigAddrParam),
		ReadTimeout:       parseDuration(c.GetParam(context.ConfigReadTimeoutParam)),
		ReadHeaderTimeout: parseDuration(c.GetParam(context.ConfigReadHeaderTimeoutParam)),
		WriteTimeout:      parseDuration(c.GetParam(context.ConfigWriteTimeoutParam)),
		IdleTimeout:       parseDuration(c.GetParam(context.ConfigIdleTimeoutParam)),
		MaxHeaderBytes:    parseInt(c.GetParam(context.ConfigMaxHeaderBytesParam)),
	}
}

// Run starts up the server
func Run(ctx *context.Context) error {
	showConfig(ctx)

	mux := http.NewServeMux()
	mux.Handle(
		"/",
		http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			// w.Write([]byte("hello"))
			if err := json.NewEncoder(w).Encode("Hello world from my https server!"); nil != err {
				log.Errorf("ERROR in base impl: %q", err.Error())
			}
		}),
	)
	s := newServerWithConfig(ctx.Config)
	s.Handler = mux

	err := s.ListenAndServeTLS(ctx.CertPath, ctx.KeyPath)
	if err != nil {
		log.Fatal(ctx.Exit, "ListenAndServe: ", err)
	}
	return nil
}
