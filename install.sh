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
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 \
  -nodes -keyout /etc/xray/key.pem -out /etc/xray/cert.pem -subj "/CN=example.com" \
  -addext "subjectAltName=DNS:example.com,DNS:*.example.com,IP:10.0.0.1"

sudo cp $PWD/xray.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable xray
sudo systemctl start xray

sudo cp $PWD/nginx.default /etc/nginx/sites-available/default
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
