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

# 获取flag对应的值
function getflag() {
   local flag=$(echo "$1" | base64 | tr -d '[0-9+/=]')
   echo ${!flag}
}
#getflag "-d"

# 获取flag对应的变量名
function getflagvar() {
   local flag=$(echo "$1" | base64 | tr -d '[0-9+/=]')
   echo ${flag}
}
#getflagvar "-d"

# 检查变量是否为空
function check_empty() {
  local flag=0
  for var in $@; do
    if [ -z ${!var} ]; then
      echo $var is empty
      flag=1
    fi
  done
  if [ $flag -eq 1 ]; then
    echo "请按帮助调用"
    set -- -h
    parse_cmd $@
    exit
  fi
}
#check_empty YOURPROXYADDRESS YOURPROXYPORT  INTERFACE


# 长选项
function pl() {
    local key=${1##--}
    suffix=":"
    [ $has_arg -eq 0 ] && suffix=""
    LONG=${LONG}${key}${suffix},
    echo $LONG
}

# 短选项
function ps() {
    local key=${1##-}
    suffix=":"
    [ $has_arg -eq 0 ] && suffix=""
    SHORT=${SHORT}${key}${suffix}
    echo $SHORT
}


# 解析命令行
function parse_cmd() {
eval set -- $*

declare -A array
IFS=$'\n'

LONG=""
SHORT=""
while read line; do
  key=$(echo $line | awk -F, '{print $1}' | sed 's/^[[:space:]]\+//' | sed 's/[[:space:]]\+$//')
  value=$(echo $line | awk -F, '{print $2}' | sed 's/^[[:space:]]\+//' | sed 's/[[:space:]]\+$//')
  opt_is_empty=$(echo $line | awk -F, '{print $3}' | sed 's/^[[:space:]]\+//' | sed 's/[[:space:]]\+$//' )
  desc=$(echo $line | awk -F, '{print $4}' | sed 's/^[[:space:]]\+//' | sed 's/[[:space:]]\+$//' )
  if [ "$key" == "key" ]; then
    continue
  fi

  if [ -z "$key" ]; then
    continue
  fi

  has_arg=1
  if [ -z "$value" ]; then
    has_arg=0
  fi


  if [ -z "$value" ]; then
    # 需要一个变量.
    # key -> -d
    # key -> --delete-it
    # key -> -d|--delete-it
    # base64 字符集，[A-Za-z0-9+/]
    value=$(getflagvar "$key")
    array[$key]="${value}"/"$has_arg"/"$opt_is_empty"
  else
    array[$key]="${value}"/"$has_arg"/"$opt_is_empty"
  fi
  case $key in
  key)
    continue
    ;;
  *\|*)
    # 有短长选项 -d|--delete-it
    short=${key%|*}
    SHORT=$(ps $short)
    long=${key#*|}
    LONG=$(pl $long)
    ;;
  --*)
    # 1个长选项 , 先匹配长，后匹配短 --delete-it
    LONG=$(pl $key $value)
    ;;
  -*)
    # 1个短选项 -d
    SHORT=$(ps $key $value)
    ;;
  esac
done <<< "$CONFIG"
#echo  短和长
#echo $SHORT
#echo $LONG
#echo  映射
#echo ${!array[@]}
#echo ${array[@]}




OPTS=`getopt -o h${SHORT} --long help,${LONG} -- "$@"`
eval set -- "$OPTS"
#echo $OPTS

casestrings=""
casestrings+='while true; do case "$1" in '
for key in ${!array[@]}; do
  #-h|--help
  #echo k: $key
  # _empty
  #echo v: ${array[$key]}
  v=$( echo ${array[$key]} | awk -F'/' '{print $1}' )
  has_arg=$( echo ${array[$key]} | awk -F'/' '{print $2}' )
  opt_is_empty=$( echo ${array[$key]} | awk -F'/' '{print $3}' )
  if [ $has_arg -eq 0 ]; then
    # 默认为0
    eval ${v}=0
    # 无参数, 存在选项就为1
    casestrings+=" $key) ${v}=1; shift ;;"
  else
    casestrings+=" $key) ${v}=\$2;  shift 2 ;;"
  fi

done
casestrings+=" --)  shift; break ;;"
function gethelp() {
   echo "$CONFIG" | awk -F, '{gsub(/[ \t]+/, "", $1);gsub(/[ \t]+/, "", $2);gsub(/[ \t]+/, "", $3);gsub(/[ \t]+/, "", $4);printf "%20s, %20s, %20s, %20s\n",$1,$2,$3,$4}' | sed '1d' | sed '$d'
}
casestrings+="
-h|--help)  shift; gethelp ;exit 1 ;;
"
casestrings+='esac; done'

#echo $casestrings
eval "$casestrings"
#echo $STATE $IFACE $ROUTEID $PRIORITY $ADDR


# 要求v不为空
FLAG=0
for key in ${!array[@]}; do
  v=$( echo ${array[$key]} | awk -F'/' '{print $1}' )
  has_arg=$( echo ${array[$key]} | awk -F'/' '{print $2}' )
  opt_is_empty=$( echo ${array[$key]} | awk -F'/' '{print $3}' )
  if [ -z "$v" ]; then
    continue
  fi
  #$IFACE is empty
  if [ -z "${!v}" -a $opt_is_empty -eq 0 ]; then
    echo "${key} must have argument"
    FLAG=1
  fi
done

if [ $FLAG -eq 1 ]; then
  echo "-h|--help 可以获取帮助"
  exit
fi
}

#使用方法
#source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/parse_cmd.sh |     sed 's/\r//g')
#CONFIG='
#                 key,             argument,         opt_is_empty,                 desc
#          -s|--state,                STATE,                    0,        MASTER|BACKUP
#          -i|--iface,                IFACE,                    0,                 eth0
#          --route-id,              ROUTEID,                    0,                1-255
#                  -p,             PRIORITY,                    0,                0-100
#              --addr,                 ADDR,                    0,      192.168.1.10/24
#                  -d,                     ,                    1,       是否删除？
#'
#parse_cmd $@
## 输出结果
#echo $STATE $IFACE $ROUTEID $PRIORITY $ADDR $OUTPUT
# getflag -d 获取 -d flag的状态 1有。默认0没有。

# 当opt_is_empty打开时，可以强制要求变量非空
# check_empty STATE IFACE  ROUTEID  PRIORITY ADDR