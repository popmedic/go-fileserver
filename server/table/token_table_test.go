package table

import (
	"testing"
)

func TestTokenTable(t *testing.T) {
	table, err := NewTokenTable("test_data/token_table.json")
	if nil != err {
		t.Error(err)
		return
	}

	givenKey := "test"

	expClaim := ""
	if got := table.Get(givenKey); got != expClaim {
		t.Error("given key", givenKey, "got level", got, "expected", expClaim)
	}

	expClaim = "1"
	table.Set(givenKey, expClaim)
	if got := table.Get(givenKey); got != expClaim {
		t.Error("given key", givenKey, "got level", got, "expected", expClaim)
	}
	got := table.All()
	if len(got) != 2 || got["kevin"] != "1" || got["test"] != expClaim {
		t.Error("didn't get all right", got)
	}

	table.Delete(givenKey)
	expClaim = "" // after delete the expected level is 0
	if got := table.Get(givenKey); got != expClaim {
		t.Error("given key", givenKey, "got level", got, "expected", expClaim)
	}
}
