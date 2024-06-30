package extra

import (
	"sync"

	mapset "github.com/deckarep/golang-set/v2"
)

var connLimitSet map[string]mapset.Set[string]
var connLimitLock sync.RWMutex

func init() {
	connLimitSet = make(map[string]mapset.Set[string])
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
