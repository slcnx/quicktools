#!/bin/bash
#
#********************************************************************
#Author:                songliangcheng
#QQ:                    2192383945
#Date:                  2022-11-12
#FileName：             install-kat.sh
#URL:                   http://blog.mykernel.cn
#Description：          安装 knative(kn-func, kn-admin), kustomize, kubectl, argocd, tekton CLIs...
#Copyright (C):        2022 All rights reserved
#********************************************************************
HTTPS_PROXY="${1}"
case $1 in
http://*)
        export https_proxy=$1
        ;;
*)
        echo "
        $0 HTTPS_PROXY
                example: $0 http://192.168.0.109:808
        "
        exit
        ;;
esac

curl -sSfL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker.gpg]  https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker-ce.list
apt update
apt install docker-ce -y
docker version

wget https://github.com/knative/client/releases/download/knative-v1.8.1/kn-linux-amd64
install kn-linux-amd64 /usr/local/bin/kn
kn version

wget https://github.com/knative-sandbox/kn-plugin-admin/releases/download/knative-v1.8.0/kn-admin-linux-amd64
install kn-admin-linux-amd64  /usr/local/bin/kn-admin
kn admin version

wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_amd64.tar.gz
tar xvf kustomize_v4.5.7_linux_amd64.tar.gz
install kustomize /usr/local/bin/
kustomize version

wget https://github.com/knative/func/releases/download/knative-v1.8.0/func_linux_amd64
install func_linux_amd64 /usr/local/bin/func
install func_linux_amd64 /usr/local/bin/kn-func
kn func version

wget https://dl.k8s.io/v1.25.3/kubernetes-client-linux-amd64.tar.gz
tar xvf kubernetes-client-linux-amd64.tar.gz
install kubernetes/client/bin/* /usr/local/bin/
kubectl version


wget https://github.com/argoproj/argo-cd/releases/download/v2.5.2/argocd-linux-amd64
install argocd-linux-amd64 /usr/local/bin/argocd
argocd version

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
bash get_helm.sh
helm version

wget https://github.com/tektoncd/cli/releases/download/v0.26.1/tektoncd-cli-0.26.1_Linux-64bit.deb
dpkg -i tektoncd-cli-0.26.1_Linux-64bit.deb
tkn version
