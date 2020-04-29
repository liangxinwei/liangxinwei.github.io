---
title: JavaScript 高级程序设计笔记三：URI编码方法
date: 2018-11-06 11:02:45
categories: 前端
---

## UR编码方法
Global对象的`encodeURI()`和`encodeURIComponent()`方法可以对URI(Uniform Resource Identifiers，通用资源标识符)进行编码，以便发送给浏览器。有效的URI中不能包含某些字符，例如空格。而这两个URI编码方法就可以对URI进行编码，它们用特殊的UTF-8编码替换所有无效的字符，从而让浏览器能够接受和理解。其中， `encodeURI()`主要用于整个 URI (例如：http://www.wrox.com/illegal value. htm)，而 `encodeURIComponent()`主要用于对URI中的某一段(例如前面URL中的 illegal value.htm)进行编码。它们的主要区别在于，`encodeURI()`**不会对本身属于URL的特殊字符进行编码**，例如冒号正斜杠、问号和井字号；而`encodeURIComponent()`则会对它发现的任何非标准字符进行编码。来看下面的例子。
```
var uri = "http://www.wrox.com/illegal value.htm";
alert(encodeURI(uri));
// "http://www.wrox.com/illegal%20value.htm"
alert(encodeURIComponent(uri));
// "http%3A%2F%2Fwww.wrox.com%2Fillegal%20value.htm"
```
使用`encodeURI()`编码后的结果是除了空格之外的其他字符都原封不动，只有空格被替换成了 %20。而`encodeURIComponent()`方法则会使用对应的编码替换所有非字母数字字符。这也正是可以对整个URI使用`encodeURI()`，而只能对附加在现有URI后面的字符串使用`encodeURIComponent()`的原因所在。一般来说，我们使用`encodeURIComponent()`方法的时候要比使用`encodeURI()`更多，因为在实践中更常见的是对查询字符串参数而不是对基础URL进行编码。与`encodeURI()`和`encodeURIComponent()`方法对应的两个方法分别是`decodeURI()`和`decodeURIComponent()`.其中，`decodeURI()`只能对使用`encodeURI()`替换的字符进行解码。例如，它可将%20替换成一个空格，但不会对%23作任何处理，因为%23表示井字号（#），而井字号不是使用`encodeURI()`替换的。同样地， `decodeURIComponent()`能够解码使用`encodeURIComponent()`编码的所有字符。
