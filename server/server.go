package server

import (
	"encoding/json"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/popmedic/go-fileserver/server/auth"

	"github.com/popmedic/go-fileserver/server/config"
	"github.com/popmedic/go-fileserver/server/context"
	"github.com/popmedic/go-fileserver/server/request"
	"github.com/popmedic/go-fileserver/server/respond"
	"github.com/popmedic/go-logger/log"
)

type Server struct {
	ctx      *context.Context
	acl      map[string]string
	handlers map[string]http.Handler
}

func NewServer(ctx *context.Context) *Server {
	s := &Server{
		ctx: ctx,
	}
	s.acl = map[string]string{
		"*":           "1",
		"get/auth":    "2",
		"post/auth":   "",
		"put/auth":    "2",
		"delete/auth": "2",
	}
	s.handlers = map[string]http.Handler{
		"/": http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			switch r.Method {
			case http.MethodGet:
				s.getPathHandler(w, r)
			default:
				w.WriteHeader(http.StatusNotImplemented)
			}
		}),
		"/auth": http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			switch r.Method {
			case http.MethodGet:
				s.getAuthHandler(w, r)
			case http.MethodPut:
				s.putAuthHandler(w, r)
			case http.MethodPost:
				s.postAuthHandler(w, r)
			case http.MethodDelete:
				s.deleteAuthHandler(w, r)
			default:
				w.WriteHeader(http.StatusNotImplemented)
			}
		}),
	}
	return s
}

func (svr *Server) getPathHandler(w http.ResponseWriter, r *http.Request) {
	f, err := os.Open(svr.ctx.PrependExposed(r.URL.Path))
	if nil != err {
		if err == os.ErrNotExist {
			respond.ErrorWithStatus(w, "getPathHandler Open not exist: ", err, http.StatusNotFound)
			return
		}
		respond.Error(w, "getPathHandler Open: ", err)
		return
	}
	defer f.Close()

	fi, err := f.Stat()
	if nil != err {
		respond.Error(w, "getPathHandler Stat: ", err)
		return
	}
	if fi.IsDir() {
		fis, err := f.Readdir(-1)
		if nil != err {
			respond.Error(w, "getPathHandler Readdir: ", err)
			return
		}
		fs := make([]string, len(fis))
		for i, fi := range fis {
			fs[i] = urlEscapePath(filepath.Join(r.URL.Path, fi.Name()))
		}
		w.Header().Set("Content-Type", "application/json")
		respond.OK(w, fs)
		return
	}
	http.ServeContent(w, r, svr.ctx.PrependExposed(r.URL.Path), fi.ModTime(), f)
}

func urlEscapePath(p string) string {
	ss := strings.Split(p, string(os.PathSeparator))
	for i, s := range ss {
		ss[i] = url.PathEscape(s)
	}
	return strings.Join(ss, string(os.PathSeparator))
}

func (svr *Server) getAuthHandler(w http.ResponseWriter, r *http.Request) {
	type resp []struct {
		key   string
		value string
	}

	respond.OK(w, respond.MapToRespMap(svr.ctx.StagedUsers.All()))
}

func (svr *Server) putAuthHandler(w http.ResponseWriter, r *http.Request) {
	body, err := request.JSONMarshalBody(r)
	if nil != err {
		respond.Error(w, "putAuthHandler: JSONMarshal request - ", err)
	}
	if v, ok := body["key"]; ok {
		if key, ok := v.(string); ok {
			svr.ctx.StagedUsers.Delete(key)

			claim := "1"
			if val, ok := body["claim"]; ok {
				if c, ok := val.(string); ok {
					claim = c
				}
			}
			svr.ctx.Users.Set(key, claim)
		}
	}
	respond.OK(w, respond.MapToRespMap(svr.ctx.StagedUsers.All()))
}

func (svr *Server) postAuthHandler(w http.ResponseWriter, r *http.Request) {
	body, err := request.JSONMarshalBody(r)
	if nil != err {
		respond.Error(w, "postAuthHandler: JSONMarshal request - ", err)
	}
	if v, ok := body["key"]; ok {
		if key, ok := v.(string); ok {
			svr.ctx.StagedUsers.Set(key, "")
		}
	}
	respond.OK(w, body)
}

func (svr *Server) deleteAuthHandler(w http.ResponseWriter, r *http.Request) {
	q := request.ReadQuery(r)
	if keys, ok := q["key"]; ok {
		for _, key := range keys {
			svr.ctx.Users.Delete(key)
		}
	}
	respond.OK(w, map[string]interface{}{})
}

func (svr *Server) createMux(ctx *context.Context) *http.ServeMux {
	m := http.NewServeMux()
	for pattern, handler := range svr.handlers {
		m.Handle(pattern, handler)
	}
	return m
}

func (svr *Server) middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			log.Debug("req:", r.URL.Path)

			next.ServeHTTP(w, r)
		},
	)
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
func (svr *Server) Run() error {
	svr.showConfig()

	s := newServerWithConfig(svr.ctx.Config)
	m := svr.createMux(svr.ctx)
	s.Handler = auth.NewAuth(svr.middleware(m), svr.ctx.Users, svr.acl)

	return s.ListenAndServeTLS(svr.ctx.CertPath, svr.ctx.KeyPath)
}

func (svr *Server) showConfig() {
	log.Info("Cert path:", svr.ctx.CertPath)
	log.Info("Private key path:", svr.ctx.KeyPath)
	log.Info("Swagger spec path:", svr.ctx.SpecPath)
	log.Info("Config path:", svr.ctx.ConfigPath)
	log.Info("Users path:", svr.ctx.UsersPath)
	log.Info("Expose path:", svr.ctx.ExposePath)
	b, err := json.MarshalIndent(svr.ctx.Config, "", "  ")
	if nil != err {
		log.Fatal(svr.ctx.Exit, err)
	}
	log.Debug("Config:\n", string(b))

	log.Debug("Users:\n", svr.ctx.Users)

	b, err = json.MarshalIndent(svr.acl, "", "  ")
	if nil != err {
		log.Fatal(svr.ctx.Exit, err)
	}
	log.Debug("ACL:\n", string(b))
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
