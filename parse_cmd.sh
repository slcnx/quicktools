#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2022-12-28
#FileName：             parse.sh
#URL:                   http://blog.mykernel.cn
#Description：          A test toy
#Copyright (C):        2022 All rights reserved
#********************************************************************
set -e
function pl() {
    local key=${1##--}
    suffix=":"
    [ $EMPTY -eq 1 ] && suffix=""
    LONG=${LONG}${key}${suffix},
    echo $LONG
}
function ps() {
    local key=${1##-}
    suffix=":"
    [ $EMPTY -eq 1 ] && suffix=""
    SHORT=${SHORT}${key}${suffix}
    echo $SHORT
}

function parse_cmd() {
eval set -- $*

declare -A array
IFS=$'\n'

LONG=""
SHORT=""
while read line; do
  key=$(echo $line | awk '{print $1}')
  value=$(echo $line | awk '{print $2}')
  if [ "$key" == "key" ]; then
    continue
  fi

  if [ -z "$key" ]; then
    continue
  fi

  EMPTY=0
  if [ -z "$value" ]; then
    EMPTY=1
  fi

  array[$key]="${value}"_"$EMPTY"
  case $key in
  key)
    continue
    ;;
  *\|*)
    # 有短长选项
    short=${key%|*}
    SHORT=$(ps $short)
    long=${key#*|}
    LONG=$(pl $long)
    ;;
  --*)
    # 1个长选项 , 先匹配长，后匹配短
    LONG=$(pl $key)
    ;;
  -*)
    # 1个短选项
    SHORT=$(ps $key)
    ;;
  esac
done <<< "$CONFIG"
#echo  短和长
#echo $SHORT
#echo $LONG
#echo  映射
#echo ${!array[@]}
#echo ${array[@]}
#echo $EMPTY




OPTS=`getopt -o h${SHORT} --long help,${LONG} -- "$@"`
eval set -- "$OPTS"

casestrings=""
casestrings+='while true; do case "$1" in '
for key in ${!array[@]}; do
  #-h|--help
  #echo k: $key
  # _empty
  #echo v: ${array[$key]}
  v=${array[$key]%_*}
  EMPTY=${array[$key]#*_}
  if [ $EMPTY -eq 1 ]; then
    casestrings+=" $key) shift ;;"
  else
    casestrings+=" $key) ${v}=\$2;  shift 2 ;;"
  fi
done
casestrings+=" --)  shift; break ;;"
casestrings+=" -h|--help)  shift; echo \"\$CONFIG\"; exit 1 ;;"
casestrings+='esac; done'

#echo $casestrings
eval "$casestrings"
#echo $STATE $IFACE $ROUTEID $PRIORITY $ADDR


# 要求v不为空
FLAG=0
for key in ${!array[@]}; do
  v=${array[$key]%_*}
  EMPTY=${array[$key]#*_}
  if [ -z "$v" ]; then
    continue
  fi
  if [ -z "${!v}" ]; then
    echo "${key} must have argument"
    FLAG=1
  fi
done
if [ $FLAG -eq 1 ]; then
  exit
fi
}

#使用方法
#source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/parse_cmd.sh |     sed 's/\r//g')
#CONFIG='
#  key        value      desc
#  -s|--state STATE      MASTER|BACKUP
#  -i|--iface IFACE      eth0
#  --route-id ROUTEID    1-255
#  -p         PRIORITY   0-100
#  --addr     ADDR       192.168.1.10/24
#'
#parse_cmd $@
## 输出结果
#echo $STATE $IFACE $ROUTEID $PRIORITY $ADDR $OUTPUT