#!/bin/bash

### Expose a CRC cluster so external/remote clients can access it
### See: https://www.redhat.com/en/blog/accessing-codeready-containers-on-a-remote-server

if ! which haproxy &> /dev/null ; then
  echo "haproxy is not installed. Run: sudo dnf -y install haproxy policycoreutils-python-utils"
  exit 1
fi

echo "====="
echo "Setting up the firewall"

sudo systemctl start firewalld
sudo firewall-cmd --add-service=http
sudo firewall-cmd --add-service=https
sudo firewall-cmd --add-port=6443/tcp

CRC_EXE="$(which crc)"
SERVER_IP="$(hostname -I | awk '{print $1}')"
CRC_IP="$(${CRC_EXE} ip)"

echo CRC_EXE=$CRC_EXE
echo SERVER_IP=$SERVER_IP
echo CRC_IP=$CRC_IP

echo "====="
echo "Setting up haproxy"

cat << EOF > /tmp/haproxy.cfg.crc
global
        maxconn 4000

defaults
        log global
        mode http
        timeout connect 30s
        timeout client 1m
        timeout server 1m

frontend fe-api
        bind ${SERVER_IP}:6443
        mode tcp
        option tcplog
        default_backend be-api

frontend fe-https
        bind ${SERVER_IP}:443
        mode tcp
        option tcplog
        default_backend be-https

frontend fe-http
        bind ${SERVER_IP}:80
        mode http
        option httplog
        default_backend be-http

backend be-api
        balance roundrobin
        mode tcp
        option ssl-hello-chk
        server webserver1 ${CRC_IP}:6443

backend be-https
        balance roundrobin
        mode tcp
        option ssl-hello-chk
        server webserver1 ${CRC_IP}:443

backend be-http
        balance roundrobin
        mode http
        option ssl-hello-chk
        server webserver1 ${CRC_IP}:80
EOF

sudo cp /tmp/haproxy.cfg.crc /etc/haproxy/haproxy.cfg
sudo systemctl restart haproxy

echo "====="
echo "Client machines need to have their /etc/hosts refer to the following:"
echo
echo "${SERVER_IP}  apps-crc.testing api.crc.testing console-openshift-console.apps-crc.testing default-route-openshift-image-registry.apps-crc.testing oauth-openshift.apps-crc.testing"

echo
