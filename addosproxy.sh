#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2022-12-30
#FileName：             addosproxy.sh
#URL:                   http://blog.mykernel.cn
#Description：
# 添加代理  curl -sSLf https://gitee.com/slcnx/tools/raw/master/addosproxy.sh |     sed 's/\r//g' | bash -s -- --proxy-addr 192.168.13.103 --proxy-port 33000 -i eth0
# 删除代理   curl -sSLf https://gitee.com/slcnx/tools/raw/master/addosproxy.sh |     sed 's/\r//g' | bash -s -- -d
#Copyright (C):        2022 All rights reserved
#********************************************************************
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/parse_cmd.sh |     sed 's/\r//g')
CONFIG='
key,             argument,         opt_is_empty,                 desc
  -p|--proxy-addr,         YOURPROXYADDRESS,   1,
  --proxy-port    ,        YOURPROXYPORT  ,    1,
  -i|--interface  ,         INTERFACE     ,    1 ,         出口接口，不代理
  -d  ,                                   ,    1 ,         删除代理
'

parse_cmd $@
# 输出结果
# -d
deleteflag=$(getflag "-d")


if [ $deleteflag -eq 1 ]; then
 sed -i -e '/proxy/d' -e '/PROXY/d' /etc/environment
 rm -f /etc/profile.d/environment.sh
 echo "已经清理代理环境, 需要重载shell"
 exit
fi


check_empty YOURPROXYADDRESS YOURPROXYPORT  INTERFACE
YOUR_ACTUAL_IP=$( ip addr show dev $INTERFACE | grep "global $INTERFACE" | tr -s ' ' | cut -d' ' -f3)
LOCALNET=$(ipcalc $YOUR_ACTUAL_IP -n | awk '/Network/{print $2}')
tee -a /etc/environment <<EOF
export http_proxy="$YOURPROXYADDRESS:$YOURPROXYPORT"
export https_proxy="$YOURPROXYADDRESS:$YOURPROXYPORT"
export ftp_proxy="$YOURPROXYADDRESS:$YOURPROXYPORT"
export no_proxy="localhost,127.0.0.1,.svc.cluster.local,$LOCALNET"

export HTTP_PROXY="$YOURPROXYADDRESS:$YOURPROXYPORT"
export HTTPS_PROXY="$YOURPROXYADDRESS:$YOURPROXYPORT"
export FTP_PROXY="$YOURPROXYADDRESS:$YOURPROXYPORT"
export NO_PROXY="localhost,127.0.0.1,.svc.cluster.local,$LOCALNET"
EOF
echo 'source /etc/environment' > /etc/profile.d/environment.sh
echo "已经添加代理环境, 需要重载shell"
