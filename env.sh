#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2022-12-28
#FileName：             env.sh
#URL:                   http://blog.mykernel.cn
#Description：         source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/env.sh | sed 's/\r//g')
#Copyright (C):        2022 All rights reserved
#********************************************************************
source /etc/os-release

is_ubuntu() {
  if [ "$ID" = "ubuntu" ]; then
     return 0
  fi
  return 1
}

# ${CB}蓝色${CE}
# ${CR}红色色${CE}
CB="echo -en \\033[1;32m"
CR="echo -en \\033[1;31m"
CE="\033[m"



# color "这是成功的消息" 0
# color "这是失败的消息" 1
color () {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "
    elif [ $2 = "failure" -o $2 = "1"  ] ;then
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo
}


