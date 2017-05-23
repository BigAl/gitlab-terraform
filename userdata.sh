#!/bin/bash

apt-get update
echo "Installing nfs-common"
apt-get install -y nfs-common
echo "Creating gitlab-data mount"
mkdir -p /gitlab-data
