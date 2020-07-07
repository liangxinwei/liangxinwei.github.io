---
title: CSS世界笔记一：流、元素与基本尺寸
date: 2020-06-26 08:52:28
categories: css
toc: true
---

## 块级元素

块级元素对应的英文是 block-level element，常见的块级元素有 `<div>、<li>和<table>` 等。需要注意是，块级元素和 `display` 为 `block` 的元素”不是一个概念。例如，`<li>`元 素默认的 `display` 值是 `list-item`，`<table>`元素默认的 `display` 值是 `table`，但是它们 均是块级元素，因为它们都符合块级元素的基本特征，也就是一个水平流上只能单独显示一 个元素，多个块级元素则换行显示。正是由于块级元素具有换行特性，因此理论上它都可以配合 clear 属性来清除浮动 带来的影响。例如:
```css
.clear:after {
    content: '';
    display: table; // 也可以是 block，或者是 list-item
    clear: both;
}
```

## 深藏不露的 width:auto
width 的默认值是 auto，它至少包含了以下 4 种不同的宽度表现:
1. 充分利用可用空间。比方说，<div>、<p>这些元素的宽度默认是 100%于父级容器的。
2. 收缩与包裹。典型代表就是浮动、绝对定位、inline-block 元素或 table 元素， 英文称为 shrink-to-fit，CSS3 中的 fit-content 指的就是这种宽度表现。
3. 收缩到最小。这个最容易出现在 table-layout 为 auto 的表格中，如下图3-4：
![图3-4 table-layout:auto的表格的一柱擎天现象](/images/f9ac8a81e75af.png)
4. 超出容器限制。除非有明确的 width 相关设置，否则上面 3 种情况尺寸都不会主动超过父级容器宽度的，但是存在一些特殊情况。例如，内容很长的连续的英文和数字，或者内联元素被设置了 white-space:nowrap，则表现为“恰似一江春水向东流，流到断崖也不回头”。例如，看一下下面的 CSS 代码:
```css
.father {
    width: 150px;
    background-color: #cd0000;
    white-space: nowrap;
}
.child {
    display: inline-block;
    background-color: #f0f3f9;
}
```
![图3-5 nowrap 不换行超出容器限制](/images/5869b0247becb.png)
子元素既保持了 inline-block 元素的收缩特性，又同时让内容宽度最大，直接无视父级容器的宽度限制。这种现象后来有了专门的属性值描述，这个属性值叫作 max-content。

## 关于 height:100%
对于 height 属性，如果父元素height 为 auto，只要子元素在文档流中，其百分比值完全就被忽略了。例如，某小白想要在页面插入一个<div>，然后满屏显示背景图，就写了如下 CSS：
```css
div {
    width: 100%; /* 这是多余的 */
    height: 100%; /* 这是无效的 */
    background: #d9d9d9;
}
```
然后他发现这个<div>高度永远是 0，哪怕其父级<body>塞满了内容也是如此。事实上，他需要如下设置才行：
```css
html, body {
    height: 100%;
}
```
并且仅仅设置<body>也是不行的，因为此时的<body>也没有具体的高度值：
```css
body {
    /* 子元素 height:100%依旧无效 */
}
```
如何让元素支持 height:100%效果？
1. 设定显式的高度值
2. 使用绝对定位。例如：
```css
div {
    height: 100%;
    position: absolute;
}
```
此时的 height:100% 就会有计算值，即使祖先元素的 height 计算为 auto 也是如此。 需要注意的是，绝对定位元素的百分比计算和非绝对定位元素的百分比计算是有区别的，区别 在于绝对定位的宽高百分比计算是相对于 padding box 的，也就是说会把 padding 大小值计算 在内，但是，非绝对定位元素则是相对于 content box 计算的，如下示例：

HTML
```html
<div class="box">
  <div class="child">高度100px</div>
</div>
<div class="box rel">
  <div class="child">高度160px</div>
</div>
```

CSS
```css
.box {
  height: 160px;
  padding: 30px;
  box-sizing: border-box;
  background-color: #beceeb;
}
.child {
  height: 100%;
  background: #cd0000;
}
.rel {
  position: relative;
}
.rel > .child {
  width: 100%;
  position: absolute;
}
```
效果图
![图3-25 绝对定位和非绝对定位元素百分比值计算区别](/images/WX20200628-094934.png)

## 任意高度元素的展开收起动画技术
很多时候，我们展 开的元素内容是动态的，换句话说高度是不固定的，因此，height 使用的值是默认的 auto， 应该都知道的 auto 是个关键字值，并非数值，正如 height:100%的 100%无法和 auto 相计 算一样，从 0px 到 auto 也是无法计算的，因此无法形成过渡或动画效果。

HTML
```html
<input id="check" type="checkbox">
<p>个人觉得，...</p>
<div class="element">
  <p>display:table-cell其他...</p>
</div>
<label for="check" class="check-in">更多↓</label>
<label for="check" class="check-out">收起↑</label>
```

CSS
```css
.element {
  max-height: 0;
  overflow: hidden;
  transition: max-height .25s;
}
:checked ~ .element {
  max-height: 666px;
}
```

[点此链接查看效果](https://demo.cssworld.cn/3/3-2.php)

其中展开后的 max-height 值，我们只需要设定为保证比展开内容高度大的值就可以，因为 max-height 值比 height 计算值大的时候，元素的高度就是 height 属性的计算高度，在本交互中，也就是 height:auto 时候的高度值。于是，一个高度 不定的任意元素的展开动画效果就实现了。但是，使用此方法也有一点要注意，即虽然说从适用范围讲，max-height 值越大使用场景越多，但是，如果 max-height 值太大，在收起的时候可能会有**效果延迟**的问题，比方说，我们展开的元素高度是 100px，而 max-height 是 1000px，动画时间 是 250ms，假设我们动画函数是线性的，则前 225ms 我们是看不到收起效果的，因为 max-height 从 1000px 到 100px 变化这段时间，元素不会有区域被隐藏，会给人动画延迟 225ms 的感觉，相信这不是你想看到的。因此，建议 max-height 使用足够安全的最小值，这样，收起时即使有延迟，也会因为时间很短，很难被用户察觉，并不会影响体验。