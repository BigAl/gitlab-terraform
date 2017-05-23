#!/bin/bash

apt-get update
echo "Installing nfs-common"
apt-get install -y nfs-common
echo "Creating gitlab-data mount"
mkdir -p /gitlab-data
echo "${fs_id}.efs.${region}.amazonaws.com:/ /gitlab-data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
