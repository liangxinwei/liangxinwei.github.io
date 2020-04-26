#!/usr/bin/env bash

git add .
git commit -m "publish"
git pull github hexo
git push github hexo
hexo g -d
git checkout master
git add .
git commit -m "publish"
git pull github master --allow-unrelated-histories
git push github master
git checkout hexo
