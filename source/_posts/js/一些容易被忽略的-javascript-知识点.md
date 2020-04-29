---
title: 一些容易被忽略的 JavaScript 知识点
date: 2017-05-10 18:55:37
categories: 前端
---

## ReferenceError和TypeError

如果 RHS 查询在所有嵌套的作用域中遍寻不到所需的变量，引擎就会抛出 ReferenceError异常。如果 RHS 查询找到了一个变量，但是你尝试对这个变量的值进行不合理的操作，比如试图对一个非函数类型的值进行函数调用，或着引用 null 或 undefined 类型的值中的属性，那么引擎会抛出另外一种类型的异常，叫作 TypeError 。ReferenceError 同作用域判别失败相关，而 TypeError 则代表作用域判别成功了，但是对结果的操作是非法或不合理的。

## 立即执行函数表达式

由于函数被包含在一对 () 括号内部，因此成为了一个表达式，通过在末尾加上另外一个()可以立即执行这个函数，比如 (function foo(){ .. })() 。第一个()将函数变成表达式，第二个()执行了这个函数。

## let

let 关键字可以将变量绑定到所在的任意作用域中（通常是 { .. } 内部）。换句话说， let为其声明的变量隐式地了所在的块作用域。使用 let 进行的声明不会在块作用域中进行提升。声明的代码被运行之前，声明并不“存在” 。for 循环头部的let不仅将i绑定到了for循环的块中，事实上它将其重新绑定到了循环的每一个迭代中，确保使用上一个循环迭代结束时的值重新进行赋值。

## 提升

考虑以下代码：
```
a = 2;
var a;
console.log(a);// 2
```
考虑另外一段代码：
```
console.log(a);// undefined
var a = 2;
```
过程： 当你看到 var a = 2; 时，JavaScript 实际上会将其看成两个声明： var a; 和 a = 2; 。第一个定义声明是在编译阶段进行的。第二个赋值声明会被留在原地等待执行阶段。第一个代码片段会以如下形式进行处理：
```
var a;
a = 2;
console.log(a);
```
其中第一部分是编译，而第二部分是执行。第二个代码片段实际是按照以下流程处理的：
```
var a;
console.log(a);
a = 2;
```
这个过程就叫作提升。但是函数表达式却不会被提升。例如：
```
foo(); // 不是 ReferenceError, 而是 TypeError!
var foo = function bar() {
    // ...
};
```
这段程序中的变量标识符 foo() 被提升并分配给所在作用域（在这里是全局作用域） ，因此foo()不会导致 ReferenceError 。但是 foo 此时并没有赋值（如果它是一个函数声明而不是函数表达式，那么就会赋值） 。 foo() 由于对 undefined 值进行函数调用而导致非法操作，因此抛出 TypeError 异常。
同时也要记住，即使是具名的函数表达式，名称标识符在赋值之前也无法在所在作用域中使用：
```
foo(); // TypeError
bar(); // ReferenceError
var foo = function bar() {
    // ...
};
```
这个代码片段经过提升后，实际上会被理解为以下形式：
```
var foo;
foo(); // TypeError
bar(); // ReferenceError
foo = function() {
    var bar = ...self...
    // ...
}
```
函数声明和变量声明都会被提升。但是是函数会首先被提升，然后才是变量。考虑以下代码：
```
foo(); // 1
var foo;
function foo() {
    console.log(1);
}
foo = function() {
    console.log(2);
};
```
会输出 1 而不是 2 ！这个代码片段会被引擎理解为如下形式：
```
function foo() {
    console.log(1);
}
foo(); // 1
foo = function() {
    console.log(2);
};
```
注意， var foo 尽管出现在 function foo()... 的声明之前，但它是重复的声明（因此被忽略了） ，因为函数声明会被提升到普通变量之前。尽管重复的 var 声明会被忽略掉，但出现在后面的函数声明还是可以覆盖前面的。

## 作用域闭包

定义：当函数可以记住并访问所在的词法作用域时，就产生了闭包，即使函数是在当前词法作用域之外执行。下面这段代码清晰地展示了闭包：
```
function foo() {
    var a = 2;
    function bar() {
        console.log(a);
    }
    return bar;
}
var baz = foo();
baz(); // 2 —— 这就是闭包的效果。
```
bar() 显然可以被正常执行，但是它在自己定义的词法作用域以外的地方执行。看上去 foo() 的内容不会再被使用，所以很自然地会考虑对其进行回收。而闭包的“神奇”之处正是可以阻止这件事情的发生。事实上内部作用域依然存在，因此没有被回收。谁在使用这个内部作用域？原来是 bar() 本身在使用。拜 bar() 所声明的位置所赐，它拥有涵盖 foo() 内部作用域的闭包，使得该作用域能够一直存活，以供 bar() 在之后任何时间进行引用。bar() 依然持有对该作用域的引用，而这个引用就叫作闭包。

## typeof null = "object"

不同的对象在底层都表示为二进制，在 JavaScript 中二进制前三位都为 0 的话会被判断为  object 类型， null 的二进制表示是全 0， 自然前三位也是 0， 所以执行 typeof 时会返回“ object ” 。

## Array

使用 delete 运算符可以将单元从数组中删除，单元删除后，数组的 length 属性并不会发生变化
```
var a = [ ];
a[0] = 1;
//  此处没有设置 a[1] 单元
a[2] = 3;
a[1]; // undefined
a.length; // 3
```
上面的代码可以正常运行，但其中的 “ 空白单元 ” （ empty slot ）可能会导致出人意料的结果。另外：如果字符串键值能够被强制类型转换为十进制数字的话，它就会被当作数字索引来处理
```
var a = [ ];
a["13"] = 42;
a.length; // 14
```

## Number()

对于 . 运算符需要给予特别注意，因为它是一个有效的数字字符，会被优先识别为数字常量的一部分，然后才是对象属性访问运算符。
**true 转换为 1 ， false 转换为 0 。 undefined 转换为 NaN ， null 转换为 0。**
为了将值转换为相应的基本类型值，抽象操作 ToPrimitive 会首先（通过内部操作 DefaultValue）检查该值是否有 valueOf() 方法。如果有并且返回基本类型值，就使用该值进行强制类型转换。如果没有就使用 toString() 的返回值（如果存在）来进行强制类型转换。如果 valueOf() 和 toString() 均不返回基本类型值，会产生 TypeError 错误。使用 Object.create(null) 创建的对象 [[Prototype]] 属性为 null ，并且没有 valueOf() 和 toString() 方法，因此无法进行强制类型转换。看下面的例子：
```
//  无效语法：因为 . 被视为常量 42. 的一部分，所以没有. 属性访问运算符来调用 tofixed 方法
42.toFixed(3);    // SyntaxError
//  下面的语法都有效：
(42).toFixed(3);  // "42.000"
0.42.toFixed(3);  // "0.420"
42..toFixed(3);   // "42.000"
42 .toFixed(3);     // "42.000"

var a = {
valueOf: function(){
    return "42";
}
};
var b = {
    toString: function(){
        return "42";
    }
};
var c = [4,2];
c.toString = function(){
    return this.join(""); // "42"
};
Number(a); // 42
Number(b); // 42
Number(c); // 42
Number(""); // 0
Number([]); // 0
Number(["abc"]); // NaN
```

## Boolean

1. 假值 undefined,null,false,+0,-0,NaN,""。**假值列表以外的值都是真值**
2. 假值对象
```
var a = new Boolean(false);
var b = new Number(0);
var c = new String("");
var d = Boolean(a && b && c);
d; // true 说明 a 、 b 、 c 都为 true 
```
虽然 JavaScript  代码中会出现假值对象，但它实际上并不属于 JavaScript  语言的范畴。浏览器在某些特定情况下，在常规 JavaScript 语法基础上自己创建了一些外来值，这些就是 “ 假值对象 ” 。假值对象看起来和普通对象并无二致（都有属性，等等），但将它们强制类型转换为布尔值时结果为 false 。最常见的例子是 document.all ，它是一个类数组对象，包含了页面上的所有元素，由 DOM （而不是 JavaScript  引擎）提供给 JavaScript  程序使用。它以前曾是一个真正意义上的对象，布尔强制类型转换结果为 true ，不过现在它是一个假值对象。document.all 并不是一个标准用法，早就被废止了。

## 奇特的 ~ 运算符

**1. 类型转换**

它首先将值强制类型转换为 32 位数字，然后执行字位操作 “非” （对每一个字位进行反转）。这与`!`很相像，不仅将值强制类型转换为布尔值`<`，还对其做字位反转。对`~`还可以有另外一种诠释，源自早期的计算机科学和离散数学：`~`返回 2 的补码。`~x`大致等同于`-(x+1)`。
`~`和`indexOf()`一起可以将结果强制类型转换（实际上仅仅是转换）为真 /  假值：
```
var a = "Hello World";
~a.indexOf("lo"); // -4 <--  真值 !
if (~a.indexOf("lo")) { // true
    //  找到匹配！
}
~a.indexOf("ol"); // 0 <--  假值 !
!~a.indexOf("ol"); // true
if (!~a.indexOf("ol")) { // true
    //  没有找到匹配！
}
```
如果 indexOf(..) 返回 -1 ，`~`将其转换为假值 0，其他情况一律转换为真值。

**2. 字位截除**

使用 `~~` 来截除数字值的小数部分，以为这和`Math.floor(..)`的效果一样，实际上并非如此。`~~`中的第一个`~`执行`ToInt32`并反转字位，然后第二个`~`再进行一次字位反转，即将所有字位反转回原值，最后得到的仍然是`ToInt32`的结果。`~~`和`!!`很相似，它只适用于 32 位数字，更重要的是它对负数的处理与`Math.floor(..)`不同。
```
Math.floor(-49.6); // -50
~~-49.6; // -49
```
`~~x`能将值截除为一个 32 位整数，`x | 0`也可以，而且看起来还更简洁。出于对运算符优先级的考虑，我们可能更倾向于使用 `~~x` 。

## == 和 ===

常见的误区是：“ == 检查值是否相等， === 检查值和类型是否相等 ” 。听起来蛮有道理，然而还不够准确。
正确的解释是：“ == 允许在相等比较中进行强制类型转换，而 === 不允许。”
两种解释的区别：
根据第一种解释（不准确的版本）， === 似乎比 == 做的事情更多，因为它还要检查值的类型。第二种解释中 == 的工作量更大一些，因为如果值的类型不同还需要进行强制类型转换。有人觉得 == 会比 === 慢，实际上虽然强制类型转换确实要多花点时间，但仅仅是微秒级（百万分之一秒）的差别而已。如果进行比较的两个值类型相同，则 == 和 === 使用相同的算法，所以除了 JavaScript  引擎实现上的细微差别之外，它们之间并没有什么不同。== 和 === 都会检查操作数的类型。区别在于**操作数类型不同时它们的处理方式不同**。

## 逗号操作符

逗号操作符可以在一条语句中执行多个操作，常用于申明多个变量，还可以用于赋值（总会返回表达式中的最后一项）。
```
var num1 = 1, num2 = 2, num3 = 3;
var num = (5, 1, 4, 8, 0); // num 为 0
```

## 抽象关系比较 a < b

分为两个部分：比较双方都是字符串（后半部分）和其他情况（前半部分）。比较双方首先调用 ToPrimitive ，如果结果出现非字符串，就根据 ToNumber 规则将双方强制类型转换为数字来进行比较。
```
var a = [ 42 ];
var b = [ "43" ];
a < b; // true
b < a; // false
```
 -0 和 NaN 的相关规则在这里也适用。如果比较双方都是字符串，则按字母顺序来进行比较
```
var a = [ "42" ];
var b = [ "043" ];
a < b; // false

var a = [ 4, 2 ];
var b = [ 0, 4, 3 ];
a < b; // false

var a = { b: 42 };
var b = { b: 43 };
a < b; // ??
// 结果还是 false ，因为 a 是 [object Object] ，b 也是 [object Object]，所以按照字母顺序 a < b 并不成立。

// 下面的例子就有些奇怪了:
var a = { b: 42 };
var b = { b: 43 };
a < b; // false
a == b; // false
a > b; // false
a <= b; // true
a >= b; // true
```
因为根据规范 a <= b 被处理为 b < a ，然后将结果反转。因为 b < a 的结果是 false ，所以 a <= b 的结果是 true。实际上 JavaScript  中 <= 是 “ 不大于 ” 的意思（即 !(a > b) ，处理为 !(b < a) ）。同理 a >= b 处理为 b <= a 。

## 比较字符串
在比较字符串时，实际比较的是两个字符串中对应位置的每个字符的字符编码值。任何操作数与NaN进行关系比较，结果都是 false。
```
"23" < "3"      // false “2” 的字符编码是 50，“3” 是 51 
"a" < 2         // false 因为 “a” 被转换成了 NaN
```

## toString

```
[] + {}; // "[object Object]"
{} + []; // 0
[null].toString() // ""
[undefined].toString() // ""
[null, undefined].toString() // ","
```
第一行代码中， {} 出现在 + 运算符表达式中，因此它被当作一个值（空对象）来处理。 [] 会被强制类型转换为 "" ，而 {} 会被强制类型转换为 "[object Object]" 。
但在第二行代码中， {} 被当作一个独立的空代码块（不执行任何操作）。代码块结尾不需要分号，所以这里不存在语法上的问题。最后 + [] 将 [] 显式强制类型转换为 0 。

## 构造函数

```
var Person = function(name) { this.name = name;
};
// 实例化一个Person
var alice = new Person('alice');
// 不要这么做!
Person('bob'); //=> undefined
```
这个函数只会返回 undefined，并且执行上下文是 window(全局)对象，你无意间创建了一个全局变量 name。调用构造函数时不要丢掉 new 关键字。当使用 new 关键字来调用构造函数时，执行上下文从全局对象(window)变成一个空的 上下文，这个上下文代表了新生成的实例。因此，this 关键字指向当前创建的实例。默认情况下，如果你的构造函数中没有返回任何内容，就会返回 this——当前的上下文。 要不然就返回任意非原始类型的值。

## bind 实现

```
Function.prototype.bind = Function.prototype.bind || function (obj) {
    var slice = [].slice,
        args = slice.call(arguments, 1), self = this,
        nop = function () {},
        bound = function () {
            return self.apply(this instanceof nop ? this : (obj || {}), args.concat(slice.call(arguments)));
        };
    nop.prototype = self.prototype; bound.prototype = new nop();
    return bound; 
};
```

## Object.create() 实现

```
Object.create = Object.create || function(o) {
    function F() {};
    F.prototype = o;
    return new F();
};
```
