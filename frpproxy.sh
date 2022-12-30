#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2022-12-29
#FileName：             frpproxy.sh
#URL:                   http://blog.mykernel.cn
#Description：          curl -sSLf https://gitee.com/slcnx/tools/raw/master/frpproxy.sh |     sed 's/\r//g' | bash -s --  --local-port 3000 --remote-port 3001 --server-addr huaweicloud.mykernel.cn --bind-port 7000 --dashboard-port 7001 --dashboard-user admin --dashboard-pwd 0vkT8HCw7ChBbFPR
#Copyright (C):        2022 All rights reserved
#********************************************************************
# --local 3000 --remote 3001
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/parse_cmd.sh |     sed 's/\r//g')
CONFIG='
key,             argument,         opt_is_empty,                 desc
  -l|--local-port , LOCALPORT           ,0,         本地的端口, 3000 or 3000-3020 or 3000,4000
  -r|--remote-port, REMOTEPORT          ,0,       远程的端口, 3000 or 3000-3020 or 5000,6000
  -s|--server-addr,  SERVERADDR         ,0,        服务程序的ip/domain huaweicloud.mykernel.cn
  -b|--bind-port  ,  BINDPORT           ,0,        服务器绑定端口, 7000
  --dashboard-port,   DASHBOARDPORT     ,0,        7001
  --dashboard-user,   DASHBOARDUSER     ,0,        admin
  --dashboard-pwd ,   DASHBOARDUSERPWD  ,0,        123456
  --suffix ,            NAME            ,1,        指定随机后缀, 可选，默认随机
  --token  ,            TOKEN           ,1,        指定token, 可选，默认随机
'
parse_cmd $@
# 输出结果
: ${LOCALPORT:=3000}
: ${REMOTEPORT:=3001}
#
: ${BINDPORT:=7000}
SERVERADDRPORT=$(echo $SERVERADDR:$BINDPORT)

: ${DASHBOARDPORT:=7001}
: ${DASHBOARDUSER:=admin}
: ${DASHBOARDUSERPWD:=admin}



: ${NAME:=$(openssl rand -base64 3)} # 3 * 8 / 6 = 4 位
: ${TOKEN:=$(openssl rand -hex 6)} # 6 * 8 / 4 = 12 位

cat <<EOF
########################### start ###########################
#server: $SERVERADDR install

docker run --restart always -d --name frps.$NAME --net host slcnx/frp:latest frps --bind_port $BINDPORT --dashboard_port $DASHBOARDPORT --dashboard_user $DASHBOARDUSER --dashboard_pwd $DASHBOARDUSERPWD --disable_log_color --token $TOKEN --tls_only
systemctl enable docker


#client:
EOF

case $LOCALPORT in
*-*)
  start_num=${LOCALPORT%-*}
  end=${LOCALPORT#*-}
  for port in $(seq $start_num $end); do
      NAME=$(openssl rand -base64 3) # 3 * 8 / 6 = 4 位
      echo "docker run --restart always -d  --name frpc.$NAME --net host slcnx/frp:latest frpc tcp --local_port $port   --remote_port $port --server_addr$SERVERADDR --token $TOKEN --uc --ue --tls_enable  --proxy_name frpc.$NAME"
  done
  ;;
*)
  if [[ $LOCALPORT =~ .*,.* ]] || [[ $REMOTEPORT =~ .*,.* ]]; then
    # 多个本地端口
    localports=($(echo $LOCALPORT | xargs -d, -n1))
    localports_len=${#localports[@]}
    remoteports=($(echo $REMOTEPORT | xargs -d, -n1))
    remoteports_len=${#remoteports[@]}
    if [ $localports_len -ne $remoteports_len ]; then
      echo "$LOCALPORT $REMOTEPORT 格式不对，应该是一一对应. 300,400 --> 300,600"
      exit
    fi


    for i in $(seq 0 $[$localports_len-1]); do
      echo "docker run --restart always -d  --name frpc.$NAME --net host slcnx/frp:latest frpc tcp --local_port ${localports[$i]}   --remote_port ${remoteports[$i]} --server_addr $SERVERADDRPORT --token $TOKEN --uc --ue--tls_enable  --proxy_name frpc.$NAME"
    done
  else
    echo "docker run --restart always -d  --name frpc.$NAME --net host slcnx/frp:latest frpc tcp --local_port $LOCALPORT   --remote_port $REMOTEPORT --server_addr $SERVERADDRPORT --token $TOKEN --uc --ue --tls_enable  --proxy_name frpc.$NAME"
  fi

  ;;
esac


cat <<EOF

User --> [$SERVERADDR:$REMOTEPORT] --> [client:$LOCALPORT]

访问 $SERVERADDR:$REMOTEPORT 就可以到达 client的 $LOCALPORT
EOF
