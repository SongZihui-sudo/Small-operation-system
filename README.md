# Small-operation-system
一个基于汇编的像是系统的操作系统，哈哈😀

#Small操作系统
基于汇编的操作系统。
这个项目将于这几天启动。😊
主要的打算实现的功能有:

1.多任务调度。

2.加减乘除计算功能。

3.读取键盘输入与显示。

Operating system based on Assembly language.
The project will be launched in the next few days. Yoo
The main functions intended to be implemented are
1. Multitask scheduling.
2. add , subtract , multiply and divide
3. There are also drivers for the key(get data from key),and show it at screen.

# 2021-8-25  第一次更新SmallOS 0.1
基于STC89C52RC单片机，实现字符串的基本输出与输入（通过串口）。
借助了putty。
源码在keil工程里。

# 2021-8-26 第二次更新SmallOS 0.2
加入换行功能，默认为回车，可以在程序中修改,并加入了定时器0的初始化。

# 2021-8-27 第三次更新SmallOS 0.3
优化了现有代码，简化了字符串输出函数。但是字符串长度必须小于10字符，包括空格。
加入了S键关闭串口。
加入定时器2主要是因为与打开串口所使用的定时器1相冲突，所以不得不弃用了定时器0。日后将做出改进。目前将用定时器2，设计多任务功能。

# 2021-8-28 第四次更新SmallOS 0.5
通过定时器二，初步实现了两个任务的并发运行。
但是第一个任务的优先级大于第二个任务，且第二个任务的运行频率大于第一个任务。
