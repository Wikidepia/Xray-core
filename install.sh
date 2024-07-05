#!/usr/bin/env bash

set -e -o pipefail

if [ -d /usr/local/go ]; then
  export PATH="$PATH:/usr/local/go/bin"
fi

CGO_ENABLED=1 go build -o /usr/bin/xray -trimpath -ldflags "-s -w -buildid=" ./main

sudo mkdir -p /etc/xray
sudo cp $PWD/config.json /etc/xray
sudo cp $PWD/xray.service /etc/systemd/system
sudo systemctl daemon-reload