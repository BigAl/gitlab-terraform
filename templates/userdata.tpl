#!/bin/bash -ex
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

apt-get update
echo "Installing nfs-common"
apt-get install -y nfs-common

echo "nameserver 169.254.169.253" > /etc/resolv.conf
echo "Creating gitlab-data mount point"
mkdir -p ${mount_point}
echo "${fs_id}.efs.${region}.amazonaws.com:/ /gitlab-data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
mount ${mount_point}

echo "Creating gitlab.rb"

cat >> /etc/gitlab/gitlab.rb <<EOF
external_url 'http://${external_url}'
postgresql['enable'] = false
gitlab_rails['db_adapter'] = "postgresql"
gitlab_rails['db_encoding'] = "utf8"
gitlab_rails['db_database'] = "${db_database}"
gitlab_rails['db_username'] = "${db_username}"
gitlab_rails['db_password'] = "${db_password}"
gitlab_rails['db_host'] = "`echo ${db_host} |cut -d: -f1`"
gitlab_rails['db_port'] = ${db_port}
gitlab_rails['redis_host'] = "${redis_host}"
gitlab_rails['redis_port'] = ${redis_port}
git_data_dirs({"default" => "/gitlab-data/git-data"})
user['home'] = '/gitlab-data/gitlab/'
gitlab_rails['uploads_directory'] = '/gitlab-data/uploads'
gitlab_rails['shared_path'] = '/gitlab-data/shared'
gitlab_rails['registry_path'] = "/gitlab-data/shared/registry"
gitlab_rails['lfs_storage_path'] = '/gitlab-data/lfs-objects'
postgres_exporter['enable'] = false
redis_exporter['enable'] = false
redis['enable'] = false
EOF

echo "Executing gitlab-ctl reconfigure"

gitlab-ctl reconfigure
