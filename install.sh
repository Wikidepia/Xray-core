#!/usr/bin/env bash

set -e -o pipefail

wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz -O /tmp/go.tar.gz
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

if [ -d /usr/local/go ]; then
  export PATH="$PATH:/usr/local/go/bin"
fi

CGO_ENABLED=1 go build -o /usr/bin/xray -trimpath -ldflags "-s -w -buildid=" ./main

sudo mkdir -p /etc/xray
sudo cp $PWD/config.json /etc/xray
sudo cp $PWD/xray.service /etc/systemd/system
sudo systemctl daemon-reload