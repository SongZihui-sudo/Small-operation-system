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
使用多任务功能会关闭串口。
# 2021-8-28 第四次更新SmallOS 0.5
通过定时器二，初步实现了两个任务的并发运行。
但是第一个任务的优先级大于第二个任务，且第二个任务的运行频率大于第一个任务。以R3寄存器中的值作为任务ID，为1是执行任务1，为2执行任务2，经过定时器设定的时间后切换任务，R3加1。利用中断切换任务
进入多任务模式后，会优先打开定时器0，用的是16位自动重载模式。到达时刻一，TF0到1，进入counter，调度任务一开始工作，此时定时器已经自动重装载完成，开始第二次计时。在这一计时时间段内会循环执行任务一，到达时后。TF0到1，切换到任务二执行，再次到时间后，因为目前一共有两个任务，则回到任务一继续执行。

三任务执行时：
![image](https://pcsdata.baidu.com/thumbnail/a62365045offe618cdd89530c3dcc564?fid=3125802318-16051585-112600230304236&rt=pr&sign=FDTAER-yUdy3dSFZ0SVxtzShv1zcMqd-xL3wT0P8aoX7tvX874yrcLYv%2Bhk%3D&expires=2h&chkv=0&chkbd=0&chkpc=&dp-logid=9022135683566985748&dp-callid=0&time=1630152000&bus_no=26&size=c300_u300&quality=100&vuk=-&ft=video)
