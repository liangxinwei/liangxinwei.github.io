---
title: JavaScript 高级程序设计笔记一：简介、script 标签
date: 2018-09-30 19:02:45
categories: 前端
toc: true
---

一个完整的JavaScript实现应该由下列三个不同的部分组成：

**1. 核心（ECMAScript）**

由ECMA-262定义的ECMAScript与Web浏览器没有依赖关系，Web浏览器只是ECMAScript实现可能的宿主环境之一（其他如Node、Adobe Flash），宿主环境不仅提供基本的ECMAScript实现，同时也会提供该语言的扩展，以便与环境之间对接交互。它规定了这门语言的下列组成部分：语法、类型、语句、关键字、保留字、操作符、对象。

**2. 文档对象模型（DOM）**

文档对象模型（DOM，Document Object Model）是针对 XML 但经过扩展用于HTML的应用程序编程接口（API，Application Programming Interface）。DOM 把整个页面映射为一个多层节点结构。HTML和XML页面中的每个组成部分都是某种类型的节点，这些节点又包含着不同类型的数据。通过DOM创建的这个表示文档的树结构，开发人员获得了控制页面内容和结构的主动权。

DOM级别：

DOM1级（DOM Level 1）由两个模块组成：DOM Core（规定了如何映射基于XML的文档结构）和DOM HTML（在 Core 的基础上加以扩展，添加了针对HTML的对象和方法）。

DOM2级扩充了鼠标和用户界面事件、范围、遍历等细分模块，而且通过对象接口增加了对CSS的支持。

DOM3级引入了以统一方式加载和保存文档的方法------在DOM加载和保存（DOM Load and Save）模块中定义；新增了验证文档的方法——在DOM验证（DOM Validation）模块中定义。

**3. 浏览器对象模型（BOM）**

浏览器对象模型（BOM，Browser Object Model）只处理浏览器窗口和框架，如 window， location， navigator， screen， 对 cookies 的支持、像 XMLHttpRequest 这样的自定义对象。


**script 标签的属性：**

1. async：表示应该立即下载脚本，但不应该妨碍页面中的其他操作，比如下载其他资源或等待加载其他脚本，一定在页面的Load事件前执行，但可能会在DOMContentLoaded事件触发之前或之后执行。
2. charset：代码的字符集
3. defer：告诉浏览器立即下载，但是延迟执行（遇到</html>标签之后再执行），HTML5规范要求脚本按照他们出现的先后顺序执行（先于DOMContentLoaded事件），
4. ~~language：用于表示编写代码使用的脚本语言，已弃用~~
5. src：表示包含要执行外部代码的文件
6. type：可以看成是 language 的替代属性看，
