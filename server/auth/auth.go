package auth

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/popmedic/go-fileserver/server/respond"
	"github.com/popmedic/go-logger/log"
)

type GetSetDeleter interface {
	All() map[string]string
	Get(key string) string
	Set(key string, claim string)
	Delete(key string)
}

type Auth struct {
	next    http.Handler
	persist GetSetDeleter
	claims  map[string]string
}

func NewAuth(next http.Handler, persist GetSetDeleter, claims map[string]string) *Auth {
	return &Auth{
		next:    next,
		persist: persist,
		claims:  claims,
	}
}

func (a *Auth) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	token := "unknown"
	tokenClaim := ""
	claimKey := strings.ToLower(r.Method) + r.URL.Path
	claim, ok := a.claims[claimKey]
	if !ok {
		claimKey = "*"
		claim = a.claims[claimKey]
	}
	if len(claim) > 0 {
		token = r.Header.Get("Authorization")
		if token == "" {
			respond.Unauthenticated(w, "no \"Authorization\" header - ")
			return
		}
		if !strings.HasPrefix(token, "Bearer ") {
			respond.Unauthenticated(w, "bad \"Authorization\" header (missing \"Bearer \" prefix) - ")
			return
		}
		token = strings.TrimPrefix(token, "Bearer ")
		tokenClaim = a.persist.Get(token)
		if tokenClaim == "0" {
			respond.Unauthenticated(w, "\"Authorization: Bearer \" token "+
				token+" does not exist or is set to claim 0 - ")
			return
		}
		if tokenClaim < claim {
			tag := fmt.Sprintf("token %q with claim %q can not access %q at claim %q - ",
				token, tokenClaim, claimKey, claim)
			respond.Unauthorized(w, tag)
			return
		}
	}
	log.Debugf("Authorized/Authenticated %q with claim %q to %q at claim %q",
		token, tokenClaim, claimKey, claim)
	a.next.ServeHTTP(w, r)
}
