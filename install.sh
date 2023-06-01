#!/bin/bash
set -e

sudo apt update && sudo apt upgrade

sudo apt install -y gcc g++ tmux jq

# install go
wget https://go.dev/dl/go1.19.6.linux-arm64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.6.linux-arm64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# setup export
cd 
git clone https://github.com/testinprod-io/op-geth
cd op-geth
git switch pcw109550/bedrock-db-migration
make geth

# setup import
cd 
git clone https://github.com/testinprod-io/op-erigon
cd op-erigon
git switch pcw109550/bedrock-db-migration
make erigon

