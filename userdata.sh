#!/bin/bash
# Install Kubernetes
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
# Install node exporter to collect system metrics for Prometheus
apt-get install -y prometheus-node-exporter
#Create Prometheus Target node-exporter runs on port 9100
# Timeout raised to 30s due to docker prometheus issue
cat <<EOF > prometheus.yml
global:
  scrape_interval:     30s
  evaluation_interval: 30s
  scrape_timeout: 30s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus-grafana.siteminderlabs.com:9100']

EOF
#Run Prometheus
docker run -d -p 9090:9090 -v /prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
#Run Grafana
mkdir -p /var/lib/grafana
docker run -d -v /var/lib/grafana --name grafana-storage busybox:latest
docker run -d -p 3000:3000 --name=grafana --volumes-from grafana-storage grafana/grafana
