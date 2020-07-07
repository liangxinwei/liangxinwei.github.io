---
title: 'fatal: Could not read from remote repository.的解决办法'
date: 2017-07-28 19:01:01
categories: git
toc: true
---

查看远端地址 `git remote –v`
查看配置 `git config --list`

```
 git add .  // 暂存所有的更改
 git checkout . // 丢弃所有的更改
 git status // 查看文件状态
 git commit -m "本次要提交的概要信息" // 提交
```

设置远端仓库地址 `git remote set-url origin 你的远端地址`

git remote add origin_new 新的地址

git remote –v查看

git push origin_new master重新推送

下面是设置用户名

Git config --global user.name "用户名"

git config --global user.email 邮箱地址

设置代理： `git config --global https.proxy http://127.0.0.1:1080`

取消设置代理：`git config --global --unset https.proxy`


取消git init操作时出现    **rm: cannot remove '.git': Is a directory**
是因为输入的命令是：    **rm -f .git**
解决办法：**rm -rf .git** 即删除整个.git目录

failed to push some refs to 'git@github.com:***.git' hint: Updates were rejected ···
使用git push origin master的时候出现一下错误：

解决办法： 
git push -f origin master或者git pull下

恢复不小心删除的 **git stash** 文件：
```
git fsck  //找到dangling的对象
git show id  //上面列出的每一条记录的最后一个字符串，按 enter 查看具体信息
git stash apply id
```

**git 回滚提交**
```
//reset将一个分支的末端指向另一个提交。这可以用来移除当前分支的一些提交, 让master分支向后回退了两个提交
git checkout master
git reset HEAD~2

//Revert撤销一个提交的同时会创建一个新的提交, 找出倒数第二个提交，然后创建一个新的提交来撤销这些更改，然后把这个提交加入项目中。
git revert HEAD~2 
```
错误：**Please enter a commit message to explain why this merge is necessary.** 解决办法：
1. （可选）按键盘字母 i 进入insert模式
2. （可选）修改最上面那行黄色合并信息
3. 按键盘左上角"Esc" （退出insert模式）
4. 输入":wq",按回车键即可（提交）

**gitignore notworking**：
```
git rm -r --cached .
git add .
git commit -m "fixed untracked files"
```
**git Failed to connect to www.google.com port 80: Timed out** 可能是因为设置了代理：

```
git config --global http.proxy			//查看代理
git config --global --unset http.proxy	//取消代理
```
**HTTP Basic access denied on Git**：

```
git config --global --unset credential.helper
git clone '···'
login username，password
```
**rebase 和 merge 区别**
```
git pull --rebase origin master
```
 rebase 选项告诉 Git 把你的提交移到同步了中央仓库修改后的 master 分支的顶部。rebase 操作过程是把本地提交一次一个地迁移到更新了的中央仓库master分支之上。这意味着可能要解决在迁移某个提交时出现的合并冲突，而不是解决包含了所有提交的大型合并时所出现的冲突。这样的方式让你尽可能保持每个提交的聚焦和项目历史的整洁。反过来，简化了哪里引入Bug的分析，如果有必要，回滚修改也可以做到对项目影响最小。
```
git pull origin master
```
如果没有 rebase， pull 操作仍然可以完成，但每次 pull 操作要同步中央仓库中别人修改时，提交历史会以一个多余的『合并提交』结尾。
合并玩冲突之后，`git rebase --continue`，Git 会继续一个一个地合并后面的提交，如其它的提交有冲突就重复这个过程。
如果你碰到了冲突，但发现搞不定，不要惊慌。只要执行下面这条命令，就可以回到你执行git pull --rebase命令前的样子：`git rebase --abort`
