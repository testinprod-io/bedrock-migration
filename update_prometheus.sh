#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y

if [[ -n "$1" ]]; then
    PROMETHEUS_ENDPOINT=$1
else
    echo "prometheus endpoint not set"
    exit 1
fi
# sanity check prometheus endpoint
RESPONSE=$(wget --spider --server-response "$PROMETHEUS_ENDPOINT" 2>&1)
STATUS_CODE=$(echo "$RESPONSE" | awk '/HTTP\/1.1/{print $2}')
if [[ "$STATUS_CODE" == "200" ]]; then
    echo "The URL is accessible (status code: $STATUS_CODE)"
else
    echo "prometheus endpoint sanity check failure (status code: $STATUS_CODE)"
    exit 1
fi

# install yq
ARCH="linux_amd64"
if [ ! -f "/usr/local/bin/yq" ]; then
    echo "Installing yq"
    sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_$ARCH
    sudo chmod a+x /usr/local/bin/yq
fi

# update prometheus yaml
PROMETHEUS_YAML="/home/ubuntu/op-erigon/cmd/prometheus/prometheus.yml"
if [ ! -f $PROMETHEUS_YAML ]; then
    echo "prometheus yaml not present"
    exit 1
fi

yq eval '.scrape_configs[0].static_configs[0].targets += ["'"$PROMETHEUS_ENDPOINT"'"]' $PROMETHEUS_YAML > $PROMETHEUS_YAML

