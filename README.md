# tools

#### 介绍


#### 软件架构
软件架构说明


#### 安装教程
```bash
git clone https://gitee.com/slcnx/tools
```

#### 使用说明
##### 一键安装docker
```bash
set +m;shopt -s lastpipe; curl -sSLf https://gitee.com/slcnx/tools/raw/master/install-docker.sh | sed 's/\r//g' | script="$(</dev/stdin)"; eval "$script"
```



##### docker添加代理

```bash
# 添加代理
curl -sSLf https://gitee.com/slcnx/tools/raw/master/add-docker-proxy.sh |  sed 's/\r//g' | bash -xs -- -a 192.168.13.103:33000
systemctl show --property=Environment docker

# 删除代理
curl -sSLf https://gitee.com/slcnx/tools/raw/master/add-docker-proxy.sh |  sed 's/\r//g' | bash -xs -- -d
```


##### 写脚本需要有颜色输出
```bash
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/env.sh | sed 's/\r//g')

green 123
red 123


color 123 1
color 123 0

```

#####  写脚本需要参数解析
https://slcnx.github.io/parse_cmd/

##### 给系统添加代理
```bash
# 添加代理  
curl -sSLf https://gitee.com/slcnx/tools/raw/master/addosproxy.sh |     sed 's/\r//g' | bash -s -- --proxy-addr 192.168.13.103 --proxy-port 33000 -i eth0
# 删除代理   
curl -sSLf https://gitee.com/slcnx/tools/raw/master/addosproxy.sh |     sed 's/\r//g' | bash -s -- -d
```

##### 生成内网穿透的命令
如果我的本地3000端口需要暴露到公网使用
我们准备一个公网主机 huaweicloud.mykernel.cn，并安装docker服务，安全组/防火墙打开3001端口，执行以下命令就可以得到公网主机执行的命令。本地内网主机执行的命令。

```bash
# 单端口暴露
curl -sSLf https://gitee.com/slcnx/tools/raw/master/frpproxy.sh |     sed 's/\r//g' | bash -s --  --local-port 3000 --remote-port 3001 --server-addr huaweicloud.mykernel.cn --bind-port 7000 --dashboard-port 7001 --dashboard-user admin --dashboard-pwd 0vkT8HCw7ChBbFPR

# 多端口暴露 端口1对1对应
curl -sSLf https://gitee.com/slcnx/tools/raw/master/frpproxy.sh |     sed 's/\r//g' | bash -s --  --local-port 3000,3306 --remote-port 3001,3306 --server-addr huaweicloud.mykernel.cn --bind-port 7000 --dashboard-port 7001 --dashboard-user admin --dashboard-pwd 0vkT8HCw7ChBbFPR
```

##### 安装haproxy应用
服务器会自动绑定在IP 172.16.59.177 上， 这个IP一般是VIP，这里就算不配置keepalived也会监控，会自动启动 net.ipv4.ip_nonlocal_bind 内核参数。

```bash
# 仅定义入口和后端 
curl -sSLf https://gitee.com/slcnx/tools/raw/master/install-haproxy.sh | sed 's/\r//g' | bash -s -- --ip 172.16.59.177:80 --web1 172.16.59.100:80 --web2 172.16.59.143:80

# 定义管理的账号和密码
curl -sSLf https://gitee.com/slcnx/tools/raw/master/install-haproxy.sh | sed 's/\r//g' | bash -s -- --ip 172.16.59.177:80 --web1 172.16.59.100:80 --web2 172.16.59.143:80 --admin-port 9999  --admin-user admin  --admin-pass admin
```
##### 安装keepalived应用
```bash
# MASTER
curl -sSLf https://gitee.com/slcnx/tools/raw/master/install-keepalived.sh | sed 's/\r//g' | bash -s -- -s MASTER -i eth0 --route-id 200 -p 100 --addr 172.16.59.177/24

# BACKUP
curl -sSLf https://gitee.com/slcnx/tools/raw/master/install-keepalived.sh | sed 's/\r//g' | bash -s -- -s BACKUP -i eth0 --route-id 200 -p 80 --addr 172.16.59.177/24
```


#### 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request


#### 特技

1.  使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md
2.  Gitee 官方博客 [blog.gitee.com](https://blog.gitee.com)
3.  你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解 Gitee 上的优秀开源项目
4.  [GVP](https://gitee.com/gvp) 全称是 Gitee 最有价值开源项目，是综合评定出的优秀开源项目
5.  Gitee 官方提供的使用手册 [https://gitee.com/help](https://gitee.com/help)
6.  Gitee 封面人物是一档用来展示 Gitee 会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
