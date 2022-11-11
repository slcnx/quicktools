#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2022-11-11
#FileName：             add-docker-proxy.sh
#URL:                   http://blog.mykernel.cn
#Description：          A test toy
#Copyright (C):        2022 All rights reserved
#********************************************************************

info() {
  echo "
  $0 OPTION
    1) $0 -a your_http_proxy_ip:port,
       example: $0 -a 192.168.13.103:33000

    2) $0 -d 删除代理
        example: curl -sfL https://gitee.com/slcnx/tools/raw/master/add-docker-proxy.sh | sed  's/\r//' |  bash -s -- -d
  "
  exit

}

case $1 in
-a)
  shift 1
  HTTP_PROXY=${1}
  [ -z "$HTTP_PROXY" ] && info
  mkdir -p /etc/systemd/system/docker.service.d
  cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://$HTTP_PROXY"
Environment="HTTPS_PROXY=http://$HTTP_PROXY"
Environment="NO_PROXY=127.0.0.1,localhost"
EOF
  systemctl daemon-reload
  systemctl restart docker
  ;;
-d)
  if [ -f /etc/systemd/system/docker.service.d/http-proxy.conf ]; then
    rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
    systemctl daemon-reload
    systemctl restart docker
  fi
  ;;
*)
  info
  ;;
esac

