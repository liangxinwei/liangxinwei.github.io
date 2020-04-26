---
title: SourceTree设置多个账户
date: 2020-04-26 11:42:19
categories: git
---

## 需求
一台电脑同时登录两个账号：公司的 gitlab 账号，自己的 github 账号，提交的时候，分别提交对应的账号。

## 取消git全局设置
```
git config --global user.name "your_name"
git config --global user.email  "your_email"
```

## SSH配置
1、生成 id_rsa 私钥，id_rsa.pub 公钥（gitlab）
```
cd ~/.ssh
ssh-keygen -t rsa -C "公司邮箱"
```
2、生成 id_rsa 私钥，id_rsa.pub 公钥（github）
```
cd ~/.ssh
ssh-keygen -t rsa -C "github邮箱"  # 之后会提示输入文件名
```
3、github 添加公钥 id_rsa_two.pub（你命名的文件名）
4、添加 ssh key
```
# 使用-K可以将私钥添加到钥匙串，不用每次开机后还要再次输入这条命令了
ssh-add -K ~/.ssh/id_rsa
ssh-add -K ~/.ssh/id_rsa_two

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
# default
Host github
HostName github.com
User git
IdentityFile ~/.ssh/id_rsa

# two
Host gitlab
HostName 公司的 gitlab 域名
User git
IdentityFile ~/.ssh/id_rsa_two
```
6、在 sourcetree 项目中，打开右上角设置：
![打开项目设置](/images/WX20200426-121200@2x.png)
![设置新的 origin](/images/WX20200426-121304@2x.png)
![设置 username](/images/WX20200426-121341@2x.png)
![通过新的 origin 拉取/提交](/images/WX20200426-121701@2x.png)
