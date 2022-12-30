# tools

#### 介绍
国内加速工具

#### 软件架构
软件架构说明


#### 安装教程
```
git clone https://gitee.com/slcnx/tools
```

#### 使用说明

写脚本需要有颜色输出
```
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/env.sh | sed 's/\r//g')

green 123
red 123


color 123 1
color 123 0

```

写脚本需要参数解析
```
source <(curl -sSLf https://gitee.com/slcnx/tools/raw/master/parse_cmd.sh |     sed 's/\r//g')
CONFIG='
key,             argument,         opt_is_empty,                 desc
  -l|--local-port , LOCALPORT           ,0,         本地的端口, 3000 or 3000-3020 or 3000,4000
  -r|--remote-port, REMOTEPORT          ,0,       远程的端口, 3000 or 3000-3020 or 5000,6000
  -s|--server-addr,  SERVERADDR         ,0,        服务程序的ip/domain huaweicloud.mykernel.cn
  -b|--bind-port  ,  BINDPORT           ,0,        服务器绑定端口, 7000
  --dashboard-port,   DASHBOARDPORT     ,0,        7001
  --dashboard-user,   DASHBOARDUSER     ,0,        admin
  --dashboard-pwd ,   DASHBOARDUSERPWD  ,0,        123456
  --suffix ,            NAME            ,1,        指定随机后缀, 可选，默认随机
  --token  ,            TOKEN           ,1,        指定token, 可选，默认随机
'
parse_cmd $@

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
