---
title: MySQL笔记（一）
date: 2020-04-22 09:27:19
categories: mysql
---

## 引擎
1. InnoDB 是一个可靠的事务处理引擎，它不支持全文本搜索
2. MEMORY在功能等同于MyISAM，但由于数据存储在内存(不是磁盘) 中，速度很快(特别适合于临时表)
3. MyISAM是一个性能极高的引擎，它支持全文本搜索(参见第18章)， 但不支持事务处理。
4. 外键不能跨引擎混用引擎类型有一个大缺陷。外键(用于强制实施引用完整性)不能跨引擎，即使用一 个引擎的表不能引用具有使用不同引擎的表的外键。

## 使用 REGEXP：
```
// shop_name 是测试数据，包含 --，比如 商家--1
SELECT `shop_name` FROM business WHERE `shop_name` REHEXP '--1|--2';
SELECT `shop_name` FROM business WHERE `shop_name` REHEXP '--[0-9]';
```

## Concat() 拼接串，即把多个串连接起来形成一个较长的串
Trim() 删除数据多余的空格，RTrim() 函数去掉值右边的所有空格，LTrim() 去掉串左边的空格
常见的情景：报表中的名字按照name(location)的格式，而表中数据存储在两个列name和country中
```
SELECT Concat(Trim(`shop_name`), Trim(' ( '), Trim(`mail_type`), ' )') AS format_title
FROM business;
// 标题--1(中通)
````
但是拼接串它没有名字，它只是一个值，客户机没有办法引用它（一个未命名的列），解决办法是*别名(alias)*，是一个字段或值的替换名。别名用AS关键字赋予。

## 执行算术计算
```
SELECT `shop_name`, `mail_type`， `distance`, `service_time`, `service_time` * `distance` as `total_price`
FROM business
WHERE `mail_type` LIKE '_通'
ORDER BY `distance`
DESC;
// 标题--9 中通 980 59 57820
```

## 常用的文本处理函数：
1. Left() 返回串左边的字符，Right() 返回串右边的字符
2. Length() 返回串的长度
3. Locate() 找出串的一个子串
4. Lower() 将串转换为小写，Upper() 将串转换为大写
5. LTrim() 去掉串左边的空格，RTrim() 去掉串右边的空格
6. Soundex() 返回串的SOUNDEX值（SOUNDEX是一个将任何文本串转换为描述其语音表示的字母数字模式的算法，如：Y.Lee -> Y.Lie，
`SELECT shop_name FROM business WHERE Soundex(shop_name) = Soundex('Y.Lie')`）
7. SubString() 返回子串的字符

## 常用的日期处理函数
1. AddDate() 增加一个日期(天、周等)
2. AddTime()增加一个时间(时、分等) 
3. CurDate()返回当前日期
4. CurTime()返回当前时间 
5. Date()返回日期时间的日期部分
6. DateDiff()计算两个日期之差
7. Date_Add()高度灵活的日期运算函数
8. Date_Format()返回一个格式化的日期或时间串
9. Day()返回一个日期的天数部分
10. DayOfWeek()对于一个日期，返回对应的星期几
11. Hour()返回一个时间的小时部分
12. Minute()返回一个时间的分钟部分
13. Month()返回一个日期的月份部分 
14. Now()返回当前日期和时间
15. Second()返回一个时间的秒部分
16. Time()返回一个日期时间的时间部分
17. Year()返回一个日期的年份部分

## 聚焦函数
```
-- street 的行数
SELECT COUNT(*) AS `street_count` FROM street;
-- 最大值
SELECT MAX(`distance`) AS max_distance,
-- 最小值
MIN(`distance`) AS min_distance,
-- 平均值
AVG(`distance`) AS avg_distance,
-- 所有值的和
SUM(`distance`) AS total_distance,
-- 所有不同值的和（去重）
SUM(DISTINCT `distance`) AS total_distance_distinct
FROM business;
```

## GROUP BY
1. GROUP BY子句可以包含任意数目的列。这使得能对分组进行嵌套， 为数据分组提供更细致的控制。
2. 如果在GROUP BY子句中嵌套了分组，数据将在最后规定的分组上进行汇总。换句话说，在建立分组时，指定的所有列都一起计算(所以不能从个别的列取回数据)。
3. GROUP BY子句中列出的每个列都必须是检索列或有效的表达式(但不能是聚集函数)。如果在SELECT中使用表达式，则必须在 GROUP BY子句中指定相同的表达式。不能使用别名。
4. 除聚集计算语句外，SELECT语句中的每个列都必须在GROUP BY子 句中给出。
5. 如果分组列中具有NULL值，则NULL将作为一个分组返回。如果列 中有多行NULL值，它们将分为一组。
6. GROUP BY子句必须出现在WHERE子句之后，ORDER BY子句之前。
7. 使用WITH ROLLUP关键字，可以得到每个分组以 及每个分组汇总级别(针对每个分组)的值
```
SELECT `mail_type`, COUNT(*) AS `num_mail_type`
FROM `business`
GROUP BY `mail_type`;

SELECT `mail_type`, COUNT(*) AS `num_mail_type`
FROM `business`
GROUP BY `mail_type`
WITH ROLLUP;
```

## HAVING和WHERE的差别:
WHERE过滤指定的是行而不是分组。事实上，WHERE没有分组的概念。WHERE在数据分组前进行过滤，HAVING在数据分组后进行过滤。这是一个重要的区别，WHERE排除的行不包括在分组中。这可能会改变计算值，从而影响HAVING子句中基于这些值过滤掉的分组。

## 联结表
```
// 在联结两个表时，你实际上做的是将第一个表中的每一行与第二个表中的每一行配对。
// WHERE子句作为 过滤条件，它只包含那些匹配给定条件(这里是联结条件)的行。
// 没有WHERE子句，第一个表中的每个行将与第二个表中的每个行配对，而不管它们逻辑上是否可以配在一起。
SELECT p.name, c.name, d.name, s.name
FROM `province` p, `city` c, `district` d, `street` s
WHERE s.parent_code = d.code
AND d.parent_code = c.code
AND c.parent_code = p.code
AND p.name = '山西省'
ORDER BY c.name;
```

## UNION操作符来组合数条SQL查询，将它们的结果组合成单个结果集。规则：
1. UNION必须由两条或两条以上的SELECT语句组成，语句之间用关 键字UNION分隔
2. UNION中的每个查询必须包含相同的列、表达式或聚集函数(不过各个列不需要以相同的次序列出)。
3. 列数据类型必须兼容:类型不必完全相同，但必须是DBMS可以隐含地转换的类型(例如，不同的数值类型或不同的日期类型)。
4. UNION ALL返回所有匹配行，不取消重复的行
```
// 查询 `distance` < 400 ｜｜ `mail_type` IN ('顺丰', '圆通')
SELECT `shop_name`, `distance`
FROM `business`
WHERE `distance` < 400
UNION
SELECT `shop_name`, `distance`
FROM `business`
WHERE `mail_type` IN ('顺丰', '圆通')
ORDER BY `distance`;
```

## 更新表：
```
UPDATE `business`
SET `service_time` = round(rand() * 100)
WHERE `service_time` < 60;
```

## 创建用户
```
SELECT * FROM mysql.user;
—- `hotdog`@`%`：用户名 hotdog，% 表示允许任何ip地址，IDENTIFIEDBY 指定的口令为纯文本，MySQL 将在保存到user表之前对其进行加密。
CREATE USER `hotdog`@`%` IDENTIFIED BY ‘123456’;
—- 配置权限：对 hotdog 数据库有所有权限，不能访问其他数据库，GRANT 的反操作为 REVOKE
GRANT ALL PRIVILEGES ON hotdog.* TO `hotdog`@`%` IDENTIFIED BY '123456';
—- 删除用户
DROP USER `hotdog`@`localhost`;
—- 配置完权限之后刷新MySQL的系统权限相关表方可生效
FLUSH PRIVILEGES;
—- 删除用户
DROP USER `username`;
—- 查看赋予用户账号的权限
SHOW GRANT FOR `username`;
—- 更改口令，新口令必须传递到Password()函 数进行加密。
SET PASSWORD FOR `username` = Password(`new_password`)
```

## created_at字段与updated_at字段关于自动更新与自动插入时间戳
```
ALTER TABLE `user` ADD COLUMN `create_at` TIMESTAMP NOT NULL;
ALTER TABLE `user` ADD COLUMN `update_at` TIMESTAMP NOT NULL;
—- TIMESTAMP DEFAULT CURRENT_TIMESTAMP 表示插入的时候自动获取当前时间（格式为YY-mm-dd HH:ii:ss）
ALTER TABLE `user` MODIFY `create_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL;
—- TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 表示更新的时候自动获取当前时间（格式为YY-mm-dd HH:ii:ss）
ALTER TABLE `user` MODIFY `update_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL;
```

## 新增外键
```
ALTER  TABLE `products` ADD CONSTRAINT `fk_orders_customs` FOREIGN KEY (vend_id) REFERENCES `vendors` (vend_id);
```

## 视图
1. 规则和限制
    1. 与表一样，视图必须唯一命名(不能给视图取与别的视图或表相 同的名字)。
    2. 对于可以创建的视图数目没有限制。
    3. 为了创建视图，必须具有足够的访问权限。这些限制通常由数据库管理人员授予。
    4. 视图可以嵌套，即可以利用从其他视图中检索数据的查询来构造一个视图。
    5. ORDER BY可以用在视图中，但如果从该视图检索数据SELECT中也含有ORDER BY，那么该视图中的ORDER BY将被覆盖。
    6. 视图不能索引，也不能有关联的触发器或默认值。
    7. 视图可以和表一起使用。例如，编写一条联结表和视图的SELECT语句。
2. 性能问题：因为视图不包含数据，所以每次使用视图时，都必须处理查询执行时所需的任一个检索。如果你用多个联结和过滤创建了复杂的视图或者嵌套了视图，可能会发现性能下降得很厉害。因此，在部署使用了大量视图的应用前，应该进行测试。
3. 一些常见应用
    1. 重用SQL语句。
    2. 简化复杂的SQL操作。在编写查询后，可以方便地重用它而不必知道它的基本查询细节。
    3. 使用表的组成部分而不是整个表。
    4. 保护数据。可以给用户授予表的特定部分的访问权限而不是整个表的访问权限。
    5. 更改数据格式和表示。视图可返回与底层表的表示和格式不同的数据。

## 数据库维护
```
// 1. 用来检查表键是否正确
ANALYZE TABLE `table_name`;
// 2. CHECK TABLE用来针对许多问题对表进行检查。在MyISAM表上还对 索引进行检查。CHECK TABLE支持一系列的用于MyISAM表的方式。 CHANGED检查自最后一次检查以来改动过的表。EXTENDED执行最 彻底的检查，FAST只检查未正常关闭的表，MEDIUM检查所有被删 除的链接并进行键检验，QUICK只进行快速扫描。如下所示，CHECK TABLE发现和修复问题
CHECK TABLE `table_name`;
// 3. 如果从一个表中删除大量数据，应该使用OPTIMIZE TABLE来收回所用的空间，从而优化表的性能。
OPTIMIZE TABLE `table_name`;
```

## 字符集
```
// 查看所支持的字符集完整列表
SHOW CHARACTER SET;
// 查看所支持校对的完整列表
SHOW COLLATION;
SHOW FULL COLUMNS FROM `village`;
SHOW VARIABLES LIKE '%char%';
```

## 改善性能
```
1. 但过一段时间后你可能需要调整内存分配、缓冲区大 小等。查看当前设置：
SHOW VARIABLES;
SHOW STATUS;
2. 显示所有活动进程(以及它们的线程ID和执行时间)
SHOW PROCESSLIST；
3. KILL命令终结某个特定的进程(使用这个命令需要作为管理员登录)。
4. LIKE很慢。一般来说，最好是使用FULLTEXT而不是LIKE。
5. 索引改善数据检索的性能，但损害数据插入、删除和更新的性能。如果你有一些表，它们收集数据且不经常被搜索，则在有必要之前不要索引它们。(索引可根据需要添加和删除。)
```
21. MySQL不允许对变长列(或一个列的可变部分)进行索引
22. MySQL中没有专门存储货币的数据类型，一般情况下使用DECIMAL(8, 2)

## MySQL 数据类型
1. 串数据类型
![串数据类型](/images/7EA9F5A0D8F1.png)
2. 数值数据类型 
![数值数据类型](/images/5D37349650BC.png)
3. 日期和时间数据类型
![日期和时间数据类型](/images/5BC46C7A9A76.png)
4. 二进制数据类型
![二进制数据类型](/images/7058C7294EBE.png)

## 触发器
> 想要某条语句（或某些语句）在事件发生时自动执行。MySQL响应以下任意语句而 自动执行的一条MySQL语句(或位于BEGIN和END语句之间的一组语 句):DELETE; NSERT; UPDATE。
>
> 只有表才支持触发器，每个表最多支持6个触发器（每条INSERT、UPDATE 和DELETE的之前和之后），单一触发器不能与多个事件或多个表关联。

```
// 触发器将在INSERT语句成功执行后执行。从 NEW.order_num 取得这个值并返回它，此触发器必须按照AFTER INSERT执行
CREATE TRIGGER `new_order` AFTER INSERT ON `orders` FOR EACH ROW SELECT NEW.order_num;
// 删除触发器
DROP TRIGGER `new_product`;
```

1. *INSERT触发器*（在INSERT语句执行之前或之后执行）：
  1. 在INSERT触发器代码内，可引用一个名为NEW的虚拟表，访问被 插入的行;
  2. 在BEFORE INSERT触发器中，NEW中的值也可以被更新(允许更改 被插入的值);
  3. 对于AUTO_INCREMENT列，NEW在INSERT执行之前包含0，在INSERT 执行之后包含新的自动生成值。

2. *DELETE触发器*（在DELETE语句执行之前或之后执行）：
  1. 在DELETE触发器代码内，你可以引用一个名为OLD的虚拟表，访 问被删除的行;
  2. OLD中的值全都是只读的，不能更新。
```
// 在任意订单被删除前将执行此触发器。它使用一条INSERT语句将OLD中的值(要被删除的订单)
// 保存到一个名为archive_ orders的存档表中
CREATE TRIGGER `delete_order` BEFORE DELETE ON `orders` FOR EACH ROW
BEGIN
    INSERT INTO `archive_orders`(`order_num`, `order_date`, `cust_id`)
    VALUES(OLD.order_num, OLD.order_date, OLD.cust_id);
END;
```

3. *UPDATE触发器*（在UPDATE语句执行之前或之后执行）：
  1. 在UPDATE触发器代码中，你可以引用一个名为OLD的虚拟表访问 以前(UPDATE语句前)的值，引用一个名为NEW的虚拟表访问新更新的值;
  2. 在BEFORE UPDATE触发器中，NEW中的值可能也被更新(允许更改 将要用于UPDATE语句中的值);
  3. OLD中的值全都是只读的，不能更新。
```
// 保证州名缩写总是大写
CREATE TRIGGER `upper_vendor` BEFORE UPDATE ON `vendors` FOR EACH ROW
SET NEW.vend_state = Upper(NEW.vend_state);
```

