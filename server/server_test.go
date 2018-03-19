package server

import (
	"testing"

	"github.com/popmedic/go-fileserver/server/context"
)

func TestServerRun(t *testing.T) {
	if err := Run(&context.Context{}); nil != err {
		t.Error(err)
	}
}
