#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2022-12-28
#FileName：             install-keepalived.sh
#URL:                   http://blog.mykernel.cn
#Description：          A test toy
#Copyright (C):        2022 All rights reserved
#********************************************************************

#使用方法
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/parse_cmd.sh | sed 's/\r//g')
CONFIG='
   key,             argument,         opt_is_empty,                 desc
  -s|--state ,STATE     ,0, MASTER|BACKUP,keepalived角色
  -i|--iface ,IFACE     ,0, eth0,外网接口
  --route-id ,ROUTEID   ,0, 1-255,路由id
  -p         ,PRIORITY  ,0, 0-100,优先级
  --addr     ,ADDR      ,0, 192.168.1.10/24,VIP地址
'
parse_cmd $@
# 输出结果
echo "$STATE $IFACE $ROUTEID $PRIORITY $ADDR $OUTPUT"

: ${STATE:-MASTER}
: ${IFACE:=eth0}
: ${ROUTEID:=239}
: ${PRIORITY:=100}
: ${ADDR:=172.16.59.199/24}

apt update
apt install keepalived haproxy -y
tee  /etc/keepalived/keepalived.conf << EOF
global_defs {
   notification_email {
     acassen
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
   vrrp_iptables
}
vrrp_script check_haproxy {
   script "/usr/bin/killall -0 haproxy"
   interval 1
   weight -30
   fall 2
   rise 2
   timeout 2
}
vrrp_instance VI_1 {
    state $STATE
    interface $IFACE
    virtual_router_id $ROUTEID
    #nopreempt
    priority $PRIORITY
    advert_int 1
    virtual_ipaddress {
        $ADDR  dev $IFACE label $IFACE:0
    }
EOF
if [ "$STATE" == "MASTER" ]; then
# master节点进程失效才降优先
tee -a  /etc/keepalived/keepalived.conf << EOF
   #notify_master "systemctl restart haproxy"
   #notify_backup "systemctl restart haproxy"
   track_script {
     check_haproxy
   }
}
EOF
else
# backup 节点进程失效, 就不降低优先了
tee -a  /etc/keepalived/keepalived.conf << EOF
   #notify_master "systemctl restart haproxy"
   #notify_backup "systemctl restart haproxy"
}
EOF
fi

systemctl restart keepalived
systemctl enable keepalived