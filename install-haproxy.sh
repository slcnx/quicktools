source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/parse_cmd.sh | sed 's/\r//g')
CONFIG='
                 key,             argument,         opt_is_empty,                 desc
  --admin-port  , ADMINPORT ,0,9999
  --admin-user  , ADMINUSER ,0, admin
  --admin-pass  , ADMINPASS ,0, 123456
  --ip          , BINDIP    ,0, 172.20.0.248:80
  --web1        , WEB1      ,0, 172.20.0.201:80
  --web2        , WEB2      ,0, 172.20.0.202:80
'
parse_cmd $@
# 输出结果
echo ""
: ${ADMINPORT:=9999}
: ${ADMINUSER:=admin}
: ${ADMINPASS:=123456}
: ${BINDIP:=172.20.0.248:80}
: ${WEB1:=172.20.0.200:80}
: ${WEB2:=172.20.0.201:80}

sysctl -w net.ipv4.ip_nonlocal_bind=1
apt update
apt install haproxy -y

tee /etc/haproxy/haproxy.cfg <<EOF
global
maxconn 100000
chroot /usr/local/haproxy
stats socket /var/lib/haproxy/haproxy.sock1 mode 600 level admin process 1 # 非交互完成服务器热上线和下线
user haproxy
group haproxy
daemon
#---
nbproc 1   #默认单进程启动
cpu-map 1 1 # 1 work -> 1号cpu
#--
pidfile /var/lib/haproxy/haproxy.pid
log 127.0.0.1 local3 info
defaults
option http-keep-alive
option forwardfor
option redispatch
maxconn 100000
mode http
timeout connect 10s
timeout client 1m
timeout server 30m
listen stats    #启动web监控
  bind-process 1
  bind :$ADMINPORT
  stats enable
  stats hide-version
  stats uri /haproxy
  stats realm HAPorxy\Stats\Page
  stats auth $ADMINUSER:$ADMINPASS
  stats admin if TRUE
listen http
  bind $BINDIP
  mode http
  server web1 $WEB1  inter 3s fall 3 rise 5
  server web2 $WEB2  inter 3s fall 3 rise 5
EOF

systemctl restart haproxy
systemctl enable haproxy
