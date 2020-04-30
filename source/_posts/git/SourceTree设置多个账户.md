---
title: SourceTree设置多个账户
date: 2020-04-26 11:42:19
categories: git
---

## 需求
一台电脑同时登录两个账号：公司的 gitlab 账号，自己的 github 账号，提交的时候，分别提交对应的账号。

## 取消git全局设置
```
git config --global --unset user.name
git config --global --unset user.email
```

## SSH配置
1、生成 *gitlab* id_rsa 私钥、id_rsa.pub 公钥
```
cd ~/.ssh
ssh-keygen -t rsa -C "公司邮箱"
```
2、生成 *github* id_rsa 私钥、id_rsa.pub 公钥
```
cd ~/.ssh
ssh-keygen -t rsa -C "github邮箱"  # 之后会提示输入文件名，我的是 id_rsa_github.pub
```
3、github 添加公钥 id_rsa_github.pub（你命名的文件名）

4、添加 ssh key
```
# 使用 -K 可以将私钥添加到钥匙串，不用每次开机后还要再次输入这条命令了
ssh-add -K ~/.ssh/id_rsa
ssh-add -K ~/.ssh/id_rsa_github

# 可以在添加前使用下面命令删除所有的key
ssh-add -D

# 最后可以通过下面命令，查看key的设置
ssh-add -l
```
5、设置 ssh config 文件
```
cd ~/.ssh/
vim config
```
输入以下内容：
```
# gitlab
Host gitlab
HostName xxx.xxx.xxx（公司的 gitlab 域名，如 git.spacebox.fun）
User git
IdentityFile ~/.ssh/id_rsa

# github
Host github
HostName github.com
User git
IdentityFile ~/.ssh/id_rsa_github
```

**通过如上设置，即可设置多账户。接下来，就可以愉快的玩耍啦～**


### 如何新建 git 项目
```
mkdir project && cd project
git init
git config user.name "***"
git config user.email "***"
# $giturl 代表的是项目的 git clone 的 url 地址，github 即为上面设置的 Host
git remote add github $giturl
```
### 如何克隆 git 项目
```
# git clone，github 即为上面设置的 Host
git clone *** --origin github
```
### 如何设置在 SourceTree 已经存在的项目中

1、打开右上角设置
![项目设置](/images/WX20200426-121200@2x.png)
2、设置新的 origin
![origin](/images/WX20200426-121304@2x.png)
3、设置 username
![username](/images/WX20200426-121341@2x.png)
4、点击右边的刷新，通过新的 origin 拉取/提交
![拉取/提交](/images/WX20200426-121701@2x.png)

## 参考
1. [一个客户端设置多个github账号 - tmyam's blog](https://tmyam.github.io/blog/2014/05/07/duo-githubzhang-hu-she-zhi/)
2. [Git多账号登陆](https://blog.csdn.net/wzy_1988/article/details/19967465)
3. [Git - git-clone Documentation](https://git-scm.com/docs/git-clone/)
