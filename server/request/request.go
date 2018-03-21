package request

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
)

func JSONMarshalBody(r *http.Request) (m map[string]interface{}, err error) {
	m = make(map[string]interface{})
	if nil != r.Body {
		defer func(c io.Closer) {
			if err := c.Close(); nil != err {
				m = nil
				err = errors.New("unable to close request body - " + err.Error())
				return
			}
		}(r.Body)

		err = json.NewDecoder(r.Body).Decode(&m)
		if nil != err {
			m = nil
			err = errors.New("unable to json decode request body - " + err.Error())
			return
		}
	}
	return
}

func ReadQuery(r *http.Request) map[string][]string {
	return r.URL.Query()
}
