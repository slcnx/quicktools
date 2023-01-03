#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2023-01-03 11:08:58
#FileName：             set +m;shopt -s lastpipe; curl -sSLf https://gitee.com/slcnx/tools/raw/master/install-docker.sh | sed 's/\r//g' | script="$(</dev/stdin)"; eval "$script"
#URL:                   http://blog.mykernel.cn
#Description：          a test script
#Copyright (C):        2023 All rights reserved
#********************************************************************
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/env.sh | sed 's/\r//g')

: ${WORK_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"}
select opt in $(curl -sSLf https://download.docker.com/linux/static/stable/x86_64/ | sed -E -n 's/.*docker-([0-9.]+).tgz.*/\1/p' | sort -V );do
  echo $(green "获取到版本号: $opt")
  break
done
: ${version:=$opt}

wget https://download.docker.com/linux/static/stable/x86_64/docker-$version.tgz
mkdir -pv /usr/local/docker-$version/bin/
tar xvf docker-$version.tgz --strip-components=1 -C /usr/local/docker-$version/bin/

# /etc/docker/daemon.json
install -dv /etc/docker
tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "live-restore": true
}
EOF

curl -sSLf https://gitee.com/slcnx/post-precompile/raw/master/post-precompile.sh  |  sed 's/\r//g' | bash -xs -- -bvp /usr/local/docker-$version/ -s dockerd

 sed  -i '/EnvironmentFile/a Environment="PATH=/usr/local/docker/bin:/usr/local/docker/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' /etc/systemd/system/docker.service

systemctl daemon-reload
systemctl restart docker
systemctl enable docker

color "安装docker" 0

export PATH=/usr/local/docker/bin:$PATH
docker run --rm hello-world


cd $WORK_DIR
rm -f docker-$version.tgz.*
