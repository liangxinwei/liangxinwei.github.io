---
title: 浏览器/iframe 全屏、退出全屏
date: 2018-08-15 18:56:06
categories: 前端
---

外面的 html 文件 index.html：
```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <title>fullScreen</title>
    <style>
        body {
            margin: 0;
        }
    </style>
</head>

<body>
    <iframe allowfullscreen src="iframe.html" frameborder="0" style="width: 500px;height: 500px;background:#aaa"></iframe>
</body>

</html>
```
里面嵌套的 iframe.html 文件：
```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
</head>

<body>
    <h1>iframe</h1>
    <button id="button">全屏</button>
    <script>
        // 判断是否允许全屏
        var fullscreenEnabled =
            document.fullscreenEnabled ||
            document.mozFullScreenEnabled ||
            document.webkitFullscreenEnabled ||
            document.msFullscreenEnabled;
        // 全屏
        function launchFullscreen(element) {
            if (element.requestFullscreen) {
                element.requestFullscreen();
            } else if (element.mozRequestFullScreen) {
                element.mozRequestFullScreen();
            } else if (element.msRequestFullscreen) {
                element.msRequestFullscreen();
            } else if (element.webkitRequestFullscreen) {
                element.webkitRequestFullScreen();
            }
        }
        // 退出全屏
        function exitFullscreen() {
            if (document.exitFullscreen) {
                document.exitFullscreen();
            } else if (document.msExitFullscreen) {
                document.msExitFullscreen();
            } else if (document.mozCancelFullScreen) {
                document.mozCancelFullScreen();
            } else if (document.webkitExitFullscreen) {
                document.webkitExitFullscreen();
            }
        }
        var btn = document.querySelector('#button');
        if (fullscreenEnabled) {
            btn.addEventListener('click', function () {
                var fullscreenElement =
                    document.fullscreenElement ||
                    document.mozFullScreenElement ||
                    document.webkitFullscreenElement;
                if (fullscreenElement) {
                    exitFullscreen();
                    btn.innerHTML = '全屏';
                } else {
                    launchFullscreen(document.documentElement);
                    btn.innerHTML = '退出全屏';
                }
            }, false);
        }
        // 监听全屏事件
        document.addEventListener('webkitfullscreenchange', function fullscreenChange() {
            if (document.fullscreenEnabled ||
                document.webkitIsFullScreen ||
                document.mozFullScreen ||
                document.msFullscreenElement) {
                console.log('enter fullscreen');
            } else {
                console.log('exit fullscreen');
            }
        }, false);
    </script>
</body>

</html>
```
