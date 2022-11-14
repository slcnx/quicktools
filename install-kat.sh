#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2022-11-12
#FileName：             install-kat.sh
#URL:                   http://blog.mykernel.cn
#Description：          * 安装 knative(kn-func, kn-admin), kustomize, kubectl, argocd, tekton CLIs...
#Copyright (C):        2022 All rights reserved
#********************************************************************
CS="echo -en \\033[1;32m"
CF="echo -en \\033[1;31m"
CE="\033[m"
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

HTTPS_PROXY="${1}"

case $1 in
http://*)
        export https_proxy=$1
        ;;
*)
        echo "
        `${CF}运行ERROR${CE}`
        $0 HTTPS_PROXY
                example: $0 http://192.168.0.109:808
                curl -sfL https://gitee.com/slcnx/tools/raw/master/install-kat.sh | sed  's/\r//' |  bash -s -- http://192.168.0.109:808
        "
        exit
        ;;
esac



source /etc/os-release
if [ $ID = "centos" ]; then
  is_centos=1
else
  is_centos=0
fi


if ! which docker &>/dev/null; then
    if [ $is_centos -eq 0 ]; then
        curl -sSfL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker.gpg]  https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker-ce.list
        apt update
        apt install docker-ce -y
    else
       yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
       yum install -y yum-utils device-mapper-persistent-data lvm2
       yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
       sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
       yum makecache fast
       yum install docker-ce
    fi
fi
color "* 安装docker-ce" 0
docker version

if ! which kn &>/dev/null; then
wget https://github.com/knative/client/releases/download/knative-v1.8.1/kn-linux-amd64
install kn-linux-amd64 /usr/local/bin/kn
fi
color "* 安装kn" 0
kn version

if ! which kn-admin &>/dev/null; then
wget https://github.com/knative-sandbox/kn-plugin-admin/releases/download/knative-v1.8.0/kn-admin-linux-amd64
install kn-admin-linux-amd64  /usr/local/bin/kn-admin
fi
color "* 安装kn-admin" 0
kn admin version

if ! which kustomize &>/dev/null; then
wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_amd64.tar.gz
tar xvf kustomize_v4.5.7_linux_amd64.tar.gz
install kustomize /usr/local/bin/
fi
color "* 安装kustomize" 0
kustomize version

if ! which kn-func &>/dev/null; then
wget https://github.com/knative/func/releases/download/knative-v1.8.0/func_linux_amd64
install func_linux_amd64 /usr/local/bin/func
install func_linux_amd64 /usr/local/bin/kn-func
fi
color "* 安装knfunc" 0
kn func version


if ! which kubectl &>/dev/null; then
wget https://dl.k8s.io/v1.25.3/kubernetes-client-linux-amd64.tar.gz
tar xvf kubernetes-client-linux-amd64.tar.gz
install kubernetes/client/bin/* /usr/local/bin/
fi
color "* 安装kubectl" 0
kubectl version

if ! [ -f ~/.kube/config ]; then
        chmod 400 ~/.kube/config || color "* 安装kubeconfig" 1; exit
fi
color "* 安装kubeconfig" 0

if ! which argocd &>/dev/null; then
wget https://github.com/argoproj/argo-cd/releases/download/v2.5.2/argocd-linux-amd64
install argocd-linux-amd64 /usr/local/bin/argocd
fi
color "* 安装argocd" 0
argocd version

if ! which helm &>/dev/null; then
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
bash get_helm.sh
fi
color "* 安装helm" 0
helm version

if ! which tkn &>/dev/null; then
wget https://github.com/tektoncd/cli/releases/download/v0.26.1/tektoncd-cli-0.26.1_Linux-64bit.deb
dpkg -i tektoncd-cli-0.26.1_Linux-64bit.deb
fi
color "* 安装tkn" 0
tkn version -n tekton-pipelines

if ! which istioctl &>/dev/null; then
curl -L https://istio.io/downloadIstio | sh -
install istio-*/bin/istioctl /usr/local/bin/
fi
color "* 安装istioctl" 0
istioctl version

kn completion bash > /etc/profile.d/kn.sh && color "安装命令行补全kn" 0 || color "未安装命令行补全kn" 1
kn admin completion bash > /etc/profile.d/kn-admin.sh && color "安装命令行补全kn admin" 0|| color "未安装命令行补全kn admin" 1
kn func completion bash > /etc/profile.d/kn-func.sh && color "安装命令行补全kn func" 0 || color "未安装命令行补全kn func" 1
kustomize completion bash > /etc/profile.d/completion.sh && color "安装命令行补全kustomize" 0 || color "未安装命令行补全kustomize" 1
kubectl  completion bash > /etc/profile.d/kubectl.sh && color "安装命令行补全kubectl" 0 || color "未安装命令行补全kubectl" 1
argocd  completion bash > /etc/profile.d/argocd.sh && color "安装命令行补全argocd" 0 || color "未安装命令行补全argocd" 1
helm  completion bash > /etc/profile.d/helm.sh && color "安装命令行补全helm" 0 || color "未安装命令行补全helm" 1
tkn completion bash > /etc/profile.d/tkn.sh && color "安装命令行补全tkn" 0 || color "未安装命令行补全tkn" 1
istioctl completion bash > /etc/profile.d/istioctl.sh && color "安装命令行补全istioctl" 0 || color "未安装命令行补全istioctl" 1
