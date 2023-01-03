# tools

#### 介绍
国内加速工具

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

##### 写脚本需要有颜色输出
```bash
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/env.sh | sed 's/\r//g')

green 123
red 123


color 123 1
color 123 0

```

#####  写脚本需要参数解析
```bash
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/parse_cmd.sh |     sed 's/\r//g')
CONFIG='
key,             argument,         opt_is_empty,                 desc
  -l|--local-port , LOCALPORT           ,0,         本地的端口, 3000 or 3000,4000
  -r|--remote-port , REMOTEPORT         ,1,         远程的端口, 默认22
   -d  ,                                ,1,         是否删除？
   -v|--version,                        ,1,         版本号
'
parse_cmd $@


echo 获取LOCALPORT
echo $LOCALPORT
echo

echo 获取REMOTEPORT
: ${REMOTEPORT:=22}
echo $REMOTEPORT
echo

echo 获取 -d flag
deleteflag=$(getflag "-d")
echo $deleteflag
echo

echo 获取 -v flag
showversion=$(getflag "-v|--version")
echo $showversion
echo
```
- key 命令行可以传递的选项 
- argument 选项后是否需要接参数？ 有变量表示 选项需要接值，没有变量表示选项不需要接值。 
  - 存在选项参数时，获取选项的值：使用变量。 示例：bash d.sh -l 22
  - 不存在选项参数时， 获取选项对应的值，通过 命令获取变量的值 $(getflag "-d")  示例：bash d.sh -l 22 -d
- opt_is_empty 表示这个选项有没有必要传递，
  - 1 表示不需要传递选项; 
    - 当存在选项参数时，不传递选项，需要脚本给默认值。: ${REMOTEPORT:=22} 示例：bash d.sh -l 22 或  bash d.sh -l 22 -r 33
    - 当不存在选项参数时，不传递选项，默认0 示例: root@172:~# bash d.sh -l 22 或 bash d.sh -l 22  -d
  - 0 表示必须给选项，不给就会报错。  示例：bash d.sh
- desc 选项的描述 示例：bash d.sh -h

1. 不给选项，脚本会提示需要选项
```bash
root@172:~# bash d.sh
-l|--local-port must have argument
-h|--help 可以获取帮助
```

2. 给一个必给选项 -l 22
- 短选项
    ```bash
    root@172:~# bash d.sh  -l 22
    获取LOCALPORT
    22
    
    ```
    可以看出本地端口变量为22

- 长选项
```bash
root@172:~# bash d.sh  --local-port 33
获取LOCALPORT
33


```

3. 查看帮助
```bash
root@172:~# bash d.sh --help
                 key,             argument,         opt_is_empty,                 desc
     -l|--local-port,            LOCALPORT,                    0,                本地的端口
    -r|--remote-port,           REMOTEPORT,                    1,                远程的端口
                  -d,                     ,                    1,                是否删除？
        -v|--version,                     ,                    1,                  版本号

```
可以看出
有参数的：-l必给，-r|--remote-port 可选的。说明脚本需要给变量 REMOTEPORT 默认值。
无参数的：-d,-v可选的。说明脚本自动生成变量，存在为1。不存在为0

4. 查看-r的默认值。
```bash
root@172:~# bash d.sh  --local-port 44
获取LOCALPORT
44

获取REMOTEPORT
22

``` 

5. 给-r指定值
```bash
root@172:~# bash d.sh  --local-port 44 -r 55
获取LOCALPORT
44

获取REMOTEPORT
55

```

6. 查看不传递-d,-v选项时的值
```bash
root@172:~# bash d.sh  --local-port 44
获取LOCALPORT
44

获取REMOTEPORT
22

获取 -d flag
0

获取 -v flag
0

```
由于-l必给，所以我们传递一个值


7. 查看传递-d,-v选项的值
```bash
root@172:~# bash d.sh  --local-port 44  -d -v
获取LOCALPORT
44

获取REMOTEPORT
22

获取 -d flag
1

获取 -v flag
1

root@172:~# bash d.sh  --local-port 44  -d
获取LOCALPORT
44

获取REMOTEPORT
22

获取 -d flag
1

获取 -v flag
0

```

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
