---
title: JavaScript高级程序设计笔记四：创建对象的几种方式
date: 2018-11-17 11:02:45
categories: 前端
---

虽然 Object 构造函数或对象字面量都可以用来创建单个对象，但这些方式有个明显的缺点：使用同个接口创建很多对象，会产生大量的重复代码。

## 工厂模式

工厂模式是软件工程领域一种广为人知的设计模式，这种模式抽象了创建具体对象的过程，考虑到在ECMAScript中无法创建类，开发人员就发明了一种函数，用函数来封装以特定接口创建对象的细节，如下面的例子所示：
```js
function createPerson(name, age, job) {
    var o = new Object();
    o.name = name;
    o.job = job;
    o.sayName = function() {
        alert(this.name);
    }
    return o;
}
var p1 = createPerson("Nicholas", 29, "Software Engineer");
var p2 = createPerson("Greg", 27, "Doctor");
```
工厂模式虽然解决了创建多个相似对象的问题，但却没有解决对象识别的问题（即怎样知道一个对象的类型）。

## 构造函数模式

ECMAScript中的构造函数可用来创建特定类型的对象。像 Object 和 Array 这样的原生构造函数，在运行时会自动出现在执行环境中。此外，也可以创建自定义的构造函数，从而定义自定义对象类型的属性和方法。例如，可以使用构造函数模式将前面的例子重写如下：
```js
function Person(name, age, job){
    this.name = name;
    this.age = age;
    this.job = job;
    this.sayName = function() {
        alert(this.name);
    }
}
var p1 = new Person("Nicholas", 29, "software Engineer");
var p2 = new Person("Greg", 27, "Doctor");
```
我们注意到， Person() 中的代码除了与 createPerson() 中相同的部分外，还存在以下不同之处:
- 没有显式地创建对象;
- 直接将属性和方法赋给了this对象;
- 没有 return语句

此外，还应该注意到函数名 Person 使用的是大写字母P。按照惯例，构造函数始终都应该以一个大写字母开头，而非构造函数则应该以一个小写字母开头，主要是为了区别于 ECMAScript 中的其他函数；因为构造函数本身也是函数，只不过可以用来创建对象而已。要创建 Person 的新实例，必须使用 new 操作符，实际上会经历以下4个步骤:
1. 创建一个新对象;
2. 将构造函数的作用域赋给新对象（因此 this 就指向了这个新对象）
3. 执行构造函数中的代码（为这个新对象添加属性）
4. 返回新对象

p1 和 p2 分别保存着 Person 的一个不同的实例，这两个对象都有一个 constructor（构造函数）属性，该属性指向 Person，如下所示：
```js
alert(p1.constructor === Person); // true
alert(p2.constructor === Person); // true
```
对象的 constructor 属性最初是用来标识对象类型的。但是，提到检测对象类型，还是 instanceof 操作符要更可靠一些。我们在这个例子中创建的所有对象既是 Object 的实例，同时也是 Person 的实例，这一点通过 instanceof 操作符可以得到验证：
```js
alert(p1 instanceof Object); // true
alert(p1 instanceof Person); // true
alert(p2 instanceof Object); // true
alert(p2 instanceof Person); // true
```
**将构造函数当作函数**
构造函数与其他函数的唯一区别，就在于调用它们的方式不同。不过，构造函数也是函数，不存在定义构造函数的特殊语法。任何函数，只要通过 new 操作符来调用，那它就可以作为构造函数；而任何函数，如果不通过 new 操作符来调用，它跟普通函数也不会有什么两样。
**构造函数的问题**
构造函数模式虽然好用，但也并非没有缺点。使用构造函数的主要问题，就是每个方法都要在每个实例上重新创建一遍。在前面的例子中，p1 和 p2 都有一个名为 sayName() 的方法，但那两个方法不是同一个 Function 的实例。不要忘了 ECMAScript 中的函数是对象，因此每定义一个函数，也就是实例化了一个对象。从逻辑角度讲，此时的构造函数也可以这样定义：
```js
function Person(name, age, job){
    this.name = name;
    this.age = age;
    this.job = job;
    this.sayName = new Function("alert(this.name)") // 与声明函数在逻辑上是等价的
}
```
从这个角度上来看构造函数，更容易明白每个 Person 实例都包含一个不同的 Function实例（以显示name属性）的本质。说明白些，以这种方式创建函数，会导致不同的作用域链和标识符解析，但创建 Function 新实例的机制仍然是相同的。因此，不同实例上的同名函数是不相等的，以下代码可以证明这一点：
```js
alert(p1.sayName === p2.sayName); // false
```
然而，创建两个完成同样任务的 Function 实例的确没有必要；况且有 this 对象在，根本不用在执行代码前就把函数绑定到特定对象上面。因此，大可像下面这样，通过把函数定义转移到构造函数外部来解决这个问题：
```js
function Person(name, age, job) {
    this.name = name;
    this.age = age;
    this.job =job;
    this.sayName = sayName;
}
function sayName() {
    alert(this.name);
}
var p1 = new Person("Nicholas", 29, "Software Engineer");
var p2 = new Person("greg", 27, "Doctor");
```
在这个例子中，我们把 sayName() 函数的定义转移到了构造函数外部。而在构造函数内部，我们将 sayName 属性设置成等于全局的 sayName 函数。这样一来，由于 sayName 包含的是一个指向函数的指针，因此 p1 和 p2 对象就共享了在全局作用域中定义的同一个 sayName() 函数。这样做确实解决了两个函数做同一件事的问题，可是新问题又来了：在全局作用域中定义的函数实际上只能被某个对象调用，这让全局作用域有点名不副实。而更让人无法接受的是：如果对象需要定义很多方法，那么就要定义很多个全局函数，于是我们这个自定义的引用类型就丝毫没有封装性可言了。

## 原型模式

我们创建的每个函数都有一个 prototype（原型属性），这个属性是一个指针，指向一个对象，而这个对象的用途是包含可以由特定类型的所有实例共享的属性和方法。如果按照字面意思来理解，那么 prototype 就是通过调用构造函数而创建的那个对象实例的原型对象。使用原型对象的好处是可以让所有对象实例共享它所包含的属性和方法。换句话说，不必在构造函数中定义对象实例的信息，而是可以将这些信息直接添加到原型对象中，如下面的例子所示：
```js
function Person() {}
Person.prototype.name ="Nicholas";
Person.prototype.age = 29;
Person.prototype.job = "Software Engineer";
Person.prototype.sayName = function() {
    alert(this. name)
}
var p1 = new Person();
var p2 = new Person();
alert(p1.sayName === p2.sayName); // true
```
在此我们将 sayName() 方法和所有属性直接添加到 Person 的 prototype 中，构造函数变成了空函数。即使如此，也仍然可以通过调用构造函数来创建新对象，而且新对象还会具有相同的属性和方法。但与构造函数不同的是，新对象的这些属性和方法是由所有实例共享的。换句话说，p1 和 p2 访问的都是同一组属性和同一个 sayName() 函数。
**原型模式继承的问题**
原型中所有属性是被很多实例共享的，对于基本值，可以通过在实例上添加同名属性以隐藏原型中的对应属性，但是当原型中包含引用类型的属性时，问题就比较突出了：
```js
function Person() {}

Person.prototype = {
    constructor: Person,
    name: 'Bob',
    age: 23,
    friends: ['Court', 'Shelby']
}

var p1 = new Person();
var p2 = new Person();

p1.friends.push('Van');

alert(p1.friends); // 'Court'， 'Shelby'， 'Van'
alert(p2.friends); // 'Court'， 'Shelby'， 'Van' 此处会有问题

alert(p1.friends === p2.friends); // true
```

## 组合使用构造函数模式和原型模式
前者用于定义实例属性，后者定义方法和共享的属性，这样每个实例都有自己的一份实例属性副本，但同时又共享着对方法的引用，最大限度地节省内存。如下：
```js
function Person(name, age, job) {
  this.name = name;
  this.age = age;
  this.job = job;
  this.friends = ['Court', 'Shelby'];
}

Person.prototype = {
    constructor: Person,
    sayName() {
        alert(this.name);
    }
}

var p1 = new Person("Nicholas", 29, "Software Engineer");
var p2 = new Person("greg", 27, "Doctor");

p1.friends.push('Van');

alert(p1.friends); // 'Court', 'Shelby', 'Van'
alert(p2.friends); // 'Court', 'Shelby'
alert(p1.sayName === p2.sayName); // false
alert(p1.friends === p2.friends); // true
```
