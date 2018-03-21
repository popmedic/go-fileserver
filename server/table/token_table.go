package table

import (
	"encoding/json"
	"errors"
	"os"
	"sync"

	"github.com/popmedic/go-logger/log"
)

type TokenTable struct {
	table map[string]string
	path  string

	lock   sync.Mutex
	rwlock sync.RWMutex
}

func NewTokenTable(path string) (*TokenTable, error) {
	table := &TokenTable{
		path:   path,
		rwlock: sync.RWMutex{},
	}
	if err := table.load(); nil != err {
		return nil, err
	}
	return table, nil
}

func (table *TokenTable) All() map[string]string {
	m := make(map[string]string)
	for k, v := range table.table {
		m[k] = v
	}
	return m
}

func (table *TokenTable) Get(key string) string {
	table.rwlock.RLock()
	v := table.table[key]
	table.rwlock.RUnlock()

	return v
}

func (table *TokenTable) Set(key string, claim string) {
	table.rwlock.Lock()
	table.table[key] = claim
	if err := table.save(); nil != err {
		log.Error(err)
	}
	table.rwlock.Unlock()
}

func (table *TokenTable) Delete(key string) {
	table.rwlock.Lock()
	delete(table.table, key)
	if err := table.save(); nil != err {
		log.Error(err)
	}
	table.rwlock.Unlock()
}

func (table *TokenTable) load() error {
	table.table = make(map[string]string)
	f, err := os.Open(table.path)
	if nil != err {
		return err
	}
	err = json.NewDecoder(f).Decode(&table.table)
	if e := f.Close(); nil != e {
		if nil != err {
			return errors.New("errors: " + err.Error() + " and " + e.Error())
		}
		err = e
	}
	return err
}

func (table *TokenTable) save() error {
	f, err := os.Create(table.path)
	if nil != err {
		return err
	}
	err = json.NewEncoder(f).Encode(&table.table)
	if e := f.Close(); nil != e {
		if nil != err {
			err = errors.New("errors: " + err.Error() + " and " + e.Error())
			return err
		}
		err = e
	}
	return err
}

func (t *TokenTable) String() string {
	b, err := json.MarshalIndent(t.table, "", "  ")
	if nil != err {
		return ""
	}
	return string(b)
}
