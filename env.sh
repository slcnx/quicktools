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
CG="echo -en \\033[1;32m"
CR="echo -en \\033[1;31m"
CE="\033[m"

green() {
    ${CG}$1${CE}
}
red() {
    ${CR}$1${CE}
}

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
        echo -n "  OK  "
    elif [ $2 = "failure" -o $2 = "1"  ] ;then
        ${SETCOLOR_FAILURE}
        echo -n "FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n "WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo
}


function b64() {
        echo -n $1 | base64
}

function message_digest() {
        select opt in $(openssl help 2>&1 |  sed -n '/Message Digest/,/^$/p' | awk 'NR>1'); do
                break
        done

        openssl $opt $1
}
#message_digest /etc/hosts


passwd_6() {
#root@mykernel:~# openssl passwd -6 123456
#$6$ol1lAd.TOFrEh1aN$6YV7uTUJL9F6XpkOiwhBCTVza/BQPpN3hYwRDCfO4AkNoAq3WqzPqLsBPGPktbjb5BFj6oAkclFczKjmj.GTh0
# /etc/shadow中的用户对应的密码
        openssl passwd -6 $1
        openssl passwd -6 $1 -salt 123123
}
#passwd_6 123456


rand() {
        openssl rand -base64 12
        # 每1个占8位，每个base64占6位，所以结果长度 12*8/6 除不尽有==, 除尽了就不会有==
        #6的倍数就不会有==号
        openssl rand -base64 13

        # 每1个占8位，每个hex占4位，所以结果长度 12*8/4
        # hex编码
        openssl rand -hex 12
}
#rand

# 生成rsa私钥
genrsa() {
        select opt in -aes128 -aes192 -aes256 -aria128 -aria192 -aria256 -camellia128 -camellia192-camellia256 -des -des3 -idea  noenc; do
                break
        done
        # man 1 openssl
        # Pass Phrase Options
        # pass:password password是实际密码


        # 2048
        if [ "$opt" == "noenc" ]; then
        # 不enc
                color "不加密的私钥 /tmp/private.key" 0
                openssl genrsa -out /tmp/private.key 2048
        else
        # enc
                color "123456 加密的私钥 /tmp/enc-private.key" 0
                openssl genrsa $opt  -passout pass:123456 -out /tmp/enc-private.key 2048
        # decrypt
                color "解密私钥 /tmp/enc-private.key to /tmp/private.key" 0
                openssl rsa -in /tmp/enc-private.key -out /tmp/private.key
        fi

        # 从私钥抽取公钥
        color "抽取公钥  /tmp/private.key to /tmp/private.key.pub" 0
        openssl rsa -in /tmp/private.key -pubout -out /tmp/private.key.pub
}

#genrsa


# CA openssl 搭建私有ca