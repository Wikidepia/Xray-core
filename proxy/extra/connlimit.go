package extra

import (
	"sync"
	"time"

	mapset "github.com/deckarep/golang-set/v2"
)

var connLimitSet map[string]mapset.Set[string]
var connLimitLock sync.RWMutex

func init() {
	connLimitSet = make(map[string]mapset.Set[string])
	go func() {
		// Clear expired connections every minute
		for {
			time.Sleep(time.Minute)
			connLimitLock.Lock()
			for _, v := range connLimitSet {
				v.Clear()
			}
			connLimitLock.Unlock()
		}
	}()
}

func AddConnection(user string, source string) {
	connLimitLock.Lock()
	defer connLimitLock.Unlock()
	if _, ok := connLimitSet[user]; !ok {
		connLimitSet[user] = mapset.NewSetWithSize[string](10)
	}
	connLimitSet[user].Add(source)
}

func RemoveIP(source string) {
	connLimitLock.Lock()
	defer connLimitLock.Unlock()
	for _, v := range connLimitSet {
		if v.ContainsOne(source) {
			v.Remove(source)
			return
		}
	}
}

func LenUser(user string) (numElements int) {
	connLimitLock.RLock()
	defer connLimitLock.RUnlock()
	if _, ok := connLimitSet[user]; !ok {
		numElements = 0
		return
	}
	numElements = connLimitSet[user].Cardinality()
	return
}
