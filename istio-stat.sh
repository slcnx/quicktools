#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2022-12-01
#FileName：             stat.sh
#URL:                   http://blog.mykernel.cn
#Description：          A test toy
#Copyright (C):        2022 All rights reserved
#********************************************************************
set -e


# select command
function sc() {
cmds=(
"istioctl pc listener   $1"
"istioctl pc listener   $1 --port 8080"
"istioctl pc listener   $1 --port 8080 -o yaml"
"istioctl pc route   $1 --name http.8080 -o yaml"
"istioctl pc cluster   $1 --fqdn 'outbound|8080||demoappv10.default.svc.cluster.local' -o yaml"
"istioctl pc endpoint   $1 --cluster 'outbound|8080||demoappv10.default.svc.cluster.local'"
)

PS3="enter cmd: "
select cmd in "${cmds[@]}"; do
  echo $PS1 $cmd
  $cmd
  read -p "quit? " quit
  if [[ $quit =~ y|yes|q|quit ]]; then
    break
  fi
done
}

# select pod
function sp() {
pods=(
$(istioctl proxy-status   | awk 'NR>1{print $1}')
)

PS3="enter a pod: "
select pod in "${pods[@]}"; do
  echo $pod
  sc $pod
done
}


sp
