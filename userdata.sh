#!/bin/bash
# Install Kubernetes
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
#Run Prometheus
docker run -d -p 9090:9090 prom/prometheus
#Run Grafana
mkdir -p /var/lib/grafana
docker run -d -v /var/lib/grafana --name grafana-storage busybox:latest
docker run -d -p 3000:3000 --name=grafana --volumes-from grafana-storage grafana/grafana
