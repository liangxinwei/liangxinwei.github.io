---
title: Git 更改提交信息
date: 2020-05-26 10:01:01
categories: git
---
如果提交消息中包含不明确、不正确或敏感的信息，您可以在本地修改它，然后将含有新消息的新提交推送到 GitHub。


## 提交尚未推送上线
1. 在命令行上，导航到包含要修改的提交的仓库。
2. 键入 `git commit --amend -m "new commit message"`，然后按 Enter 键。
    
## 提交已经推送上线
按上面两步操作完之后，
3. 使用 `push --force` 命令强制推送经修改的旧提交
```
git push --force [origin] [branch]   # 多个账户下如：git push github master
```

## 修改多个提交或旧提交的消息
如果需要修改多个提交或旧提交的消息，您可以使用交互式变基，然后强制推送以更改提交历史记录。

1. 在命令行上，导航到包含要修改的提交的仓库。
2. 使用 `git rebase -i HEAD~n` 命令在默认文本编辑器中显示最近 n 个提交的列表。
```
git rebase -i HEAD~3 # 显示当前分支上最后 3 次提交的列表
```
此列表将类似于以下内容：
```
pick e499d89 Delete CNAME
pick 0c39034 Better README
pick f7fde4a Change the commit message but push the same commit.

# Rebase 9fdb3bd..f7fde4a onto 9fdb3bd
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```
3. 在要更改的每个提交消息的前面，用 `reword` 替换 `pick`。
```
pick e499d89 Delete CNAME
reword 0c39034 Better README
reword f7fde4a Change the commit message but push the same commit.
```
4. 保存并关闭提交列表文件
5. 在每个生成的提交文件中，键入新的提交消息，保存文件，然后关闭它。
6. 强制推送修改后的提交。
```
git push --force
```

### 其他
有几个命令需要注意一下：
- p, pick = use commit
- r, reword = use commit, but edit the commit message
- e, edit = use commit, but stop for amending
- s, squash = use commit, but meld into previous commit
- f, fixup = like “squash”, but discard this commit’s log message
- x, exec = run command (the rest of the line) using shell
- d, drop = remove commit

## 参考
1. [更改提交消息 - GitHub 帮助](https://help.github.com/cn/github/committing-changes-to-your-project/changing-a-commit-message#amending-older-or-multiple-commit-messages)
