package server

import (
	"encoding/json"
	"net/http"
	"os"
	"path/filepath"
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
	log.Info("Config path:", ctx.ConfigPath)
	b, err := json.MarshalIndent(ctx.Config, "> ", "  ")
	if nil != err {
		log.Fatal(ctx.Exit, err)
	}
	log.Debug("Config:\n> ", string(b))
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

func respondOK(w http.ResponseWriter, obj interface{}) {
	respond(w, obj, http.StatusOK)
}

func respond(w http.ResponseWriter, obj interface{}, status int) {
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(obj)
}

func respondErrorWithStatus(w http.ResponseWriter, tag string, err error, status int) {
	msg := tag + err.Error()
	log.Error(msg)
	respond(w, map[string]string{"error": msg}, status)
}

func respondError(w http.ResponseWriter, tag string, err error) {
	respondErrorWithStatus(w, tag, err, http.StatusInternalServerError)
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

var handlers = []struct {
	pattern     string
	handlerFunc http.HandlerFunc
}{
	{
		pattern: "/",
		handlerFunc: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			switch r.Method {
			case http.MethodGet:
				getPathHandler(w, r)
			default:
				w.WriteHeader(http.StatusNotImplemented)
			}
		}),
	},
	{
		pattern: "/authorize",
		handlerFunc: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			switch r.Method {
			case http.MethodGet:
				getAuthorizeHandler(w, r)
			case http.MethodPut:
				putAuthorizeHandler(w, r)
			case http.MethodPost:
				postAuthorizeHandler(w, r)
			case http.MethodDelete:
				deleteAuthorizeHandler(w, r)
			default:
				w.WriteHeader(http.StatusNotImplemented)
			}
		}),
	},
}

func getPathHandler(w http.ResponseWriter, r *http.Request) {
	f, err := os.Open(r.URL.Path)
	if nil != err {
		if err == os.ErrNotExist {
			respondErrorWithStatus(w, "getPathHandler Open not exist: ", err, http.StatusNotFound)
			return
		}
		respondError(w, "getPathHandler Open: ", err)
		return
	}
	defer f.Close()

	fi, err := f.Stat()
	if nil != err {
		respondError(w, "getPathHandler Stat: ", err)
		return
	}
	if fi.IsDir() {
		fis, err := f.Readdir(-1)
		if nil != err {
			respondError(w, "getPathHandler Readdir: ", err)
			return
		}
		fs := make([]string, len(fis))
		for i, fi := range fis {
			fs[i] = filepath.Join(r.URL.Path, fi.Name())
		}
		respondOK(w, fs)
		return
	}
	http.ServeContent(w, r, r.URL.Path, fi.ModTime(), f)
}

func getAuthorizeHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusNotImplemented)
}

func putAuthorizeHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusNotImplemented)
}

func postAuthorizeHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusNotImplemented)
}

func deleteAuthorizeHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusNotImplemented)
}

func createMux(ctx *context.Context) *http.ServeMux {
	m := http.NewServeMux()
	for _, handler := range handlers {
		m.Handle(handler.pattern, handler.handlerFunc)
	}
	return m
}

func middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Debug("req:", r.URL.Path)
		next.ServeHTTP(w, r)
	})
}

// Run starts up the server
func Run(ctx *context.Context) error {
	showConfig(ctx)

	s := newServerWithConfig(ctx.Config)
	m := createMux(ctx)
	s.Handler = middleware(m)

	return s.ListenAndServeTLS(ctx.CertPath, ctx.KeyPath)
}
