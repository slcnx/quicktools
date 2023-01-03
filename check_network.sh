#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2023-01-03 01:40:42
#FileName：             check_network.sh
#URL:                   http://blog.mykernel.cn
#Description：          curl -sSLf https://gitee.com/slcnx/tools/raw/master/check_network.sh | sed 's/\r//g' | bash 
#Copyright (C):        2023 All rights reserved
#********************************************************************
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/env.sh | sed 's/\r//g')

echo "------------- $(green start) ---------------"
date
color "显示时间" $?

echo "------------- $(green start) ---------------"
ping -c 3 www.baidu.com
color "测试网络连通性" $?

echo "------------- $(green start) ---------------"
hostname
color "显示主机名" $?


echo "------------- $(green start) ---------------"
{
set -e
cat /etc/resolv.conf
route -n
ip a l dev eth0
}
color "显示dns, route, ip" $?


echo "------------- $(green start) ---------------"
tail /etc/sysctl.conf
color "显示kernel params" $?


echo "------------- $(green start) ---------------"
crontab -l
color "显示crontab" $?



echo "------------- $(green start) ---------------"
lsof -Pnp $(ps -ef  | awk '/ssh/{print $2}' | paste -d, -s) | grep -E 'LISTEN|ESTABLISHED'
color "显示ssh相关的端口" $?

echo "------------- $(green start) ---------------"
alias
color "显示alias" $?