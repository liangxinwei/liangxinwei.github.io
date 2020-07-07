---
title: JavaScript高级程序设计笔记五：对象的属性
date: 2018-11-18 11:02:45
categories: 前端
toc: true
---

ECMAScript 有两种属性：数据属性和访问器属性。

## 1、数据属性

数据属性包含一个数据值的位置。在这个位置可以读取和写入值。数据属性有4个描述其行为的特性。
* [Configurable]：表示能否通过 delete 删除属性从而重新定义属性，或者能否把属性修改为访问器属性。默认值为true。
* [Enumerable]：表示能否通过 for-i 循环返回属性。对于直接在变量上定义的属性，默认值是 true。
* [Writable]：表示能否修改属性的值，默认值为true。
* [value]：包含这个属性的数据值。读取属性值的时候，从这个位置读；写入属性值的时候，把新值保存在这个位置。这个特性的默认值为 undefined。

要修改属性默认的特性，必须使用 ECMAScript 的 Object.defineProperty() 方法。这个方法接收三个参数：属性所在的对象、属性的名字和一个描述符对象。其中，描述符（descriptor）对象的属性必须是：configurable、 enumerable、 writable 和 value。设置其中的一或多个值，可以修改对应的特性值。
```
const obj = {};
// 设置 a 只读，一旦设置 configurable 就不能再修改了
Object.defineProperty(obj, 'a', {
    configurable: false,
    value: 123
});
// obj: {a: 123}
delete a.a                          // false
a.a = 345                           // 345, obj: {a: 123}
Object.defineProperty(a, 'a', {
    configurable: true,
    value: 222
})
// 抛出错误：VM3638:1 Uncaught TypeError: Cannot redefine property: a at Function.defineProperty
```

## 2、对象的访问器属性

访问器属性不包含数据值，他们包含一对儿 getter 和 setter 函数（都不是必需的）。在读取访问器属性时，会调用 getter 函数，这个函数负责返回有效的值；在写入访问器属性时，会调用 setter 函数并传入新值，这个函数负责决定如何处理数据。访问器属性有如下4个特性：
* [Configurable]：表示能否通过 delete 删除属性从而重新定义属性，能否修改属性的特性，或者能否把属性修改为数据属性。对于直接在对象上定义的属性，这个特性的默认值为 true。
* [Enumerable]：表示能否通过for-in循环返回属性。对于直接在对象上定义的属性，这个特性的默认值为true。
* [get]：在读取属性时调用的函数。默认值为 undefined。
* [set]：在写入属性时调用的函数。默认值为 undefined。

访问器属性不能直接定义，必须使用 object.defineProperty() 来定义。请看下面的例子：
```
var book = {
    _year: 2004,
    edition: 1
};
Object.defineProperty(book, "year", {
    get() {
        return this._year;
    },
    set(newValue) (
        if(newValue > 2004) {
            this._year = newValue;
            this.edition = newValue - 2004;
        }
    )
});
book.year = 2005;
alert(book.edition); // 2
```
