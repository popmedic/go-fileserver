package respond

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/popmedic/go-logger/log"
)

func OK(w http.ResponseWriter, obj interface{}) {
	json.NewEncoder(w).Encode(obj)
}

func WithStatus(w http.ResponseWriter, obj interface{}, status int) {
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(obj)
}

func ErrorWithStatus(w http.ResponseWriter, tag string, err error, status int) {
	msg := tag + err.Error()
	log.Error(msg)
	WithStatus(w, map[string]string{"error": msg}, status)
}

func Error(w http.ResponseWriter, tag string, err error) {
	ErrorWithStatus(w, tag, err, http.StatusInternalServerError)
}

func Unauthorized(w http.ResponseWriter, tag string) {
	ErrorWithStatus(w, tag, errors.New("Unauthorized"), http.StatusForbidden)
}

func Unauthenticated(w http.ResponseWriter, tag string) {
	ErrorWithStatus(w, tag, errors.New("Unauthenticated"), http.StatusUnauthorized)
}

func MapToRespMap(m map[string]string) []struct {
	key   string
	value string
} {
	res := make([]struct {
		key   string
		value string
	}, len(m))
	var i = 0
	for k, v := range m {
		res[i] = struct {
			key   string
			value string
		}{
			key:   k,
			value: v,
		}
		i++
	}
	return res
}
