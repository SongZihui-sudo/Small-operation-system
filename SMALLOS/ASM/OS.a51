$NOMOD51
$INCLUDE(reg52.h)
;程序执行的起始地址	
ORG 	0000H				
    LJMP 	Main			
ORG 	0023H
    LJMP UART_INTER
ORG     0030H

Main:
    MOV SP,#60H
    ;初始化串口参数
   	SETB EA				
	SETB ES 
    MOV TMOD,#021H;9600bps
    MOV TH1,#0FDH		
	MOV TL1,#0FDH 
	MOV SCON,#50H		
	MOV PCON,#00H
    SETB TR1 
;/************************串口交互界面·***************************************/
PRINT_TIP: 
    ;DPTR指向数组
    MOV DPTR,#UART_TIP  	
	MOV R0,#00H	
    CALL PRINTF
    MOV DPTR,#STR_Tab  	 ;解决多次重复输出的BUG
	MOV R0,#00H	
    CALL PRINTF
    CALL PRINT_TIP2
PRINT_TIP2:
    MOV DPTR,#STR0_TAB
    MOV R0,#00H
    CALL PRINTF
    CALL STOP 
;延时	
DEALAY:						
    MOV R7,#250 
    D1: MOV R6,#250    
    D2: DJNZ R6,D2     
    DJNZ R7,D1  
    RET
;输出字符函数   
PRINTF: 
    MOV	 A,R0			;下标赋值
	MOVC A, @A+DPTR		;读取数组数据
    CLR  ES
    CLR  TI
    MOV SBUF,A
    CALL DEALAY
    INC	R0				;下标自加
    CJNE R0,#0AH,Next	;判断是否为30，否则进去STOP，防止循环重复输出
    MOV R0,#30H
    RET
Next:		
	SJMP PRINTF
;停止重复发送 
STOP:
    SETB TI
    SETB ES
    CALL UART_INTER
;判断进行换行操作   
CMP_S:          
    CJNE A, #53H,CMP_ENTER ;S键关闭串口 
    MOV DPTR,#TIMER_TIP  	
	MOV R0,#00H	
    CALL PRINTF
    CALL UART_OFF
CMP_ENTER:
	CJNE A, #0DH, RX
    CALL PRINT_TIP2
;读取键盘输入
RX:	
    MOV SBUF,A
    JNB TI,$
    CLR TI
    RET
UART_INTER:
    PUSH ACC				
    PUSH PSW
    JBC TI, L_EXIT
	CLR RI			;否则清除发送标志位
    MOV A,SBUF
    CALL CMP_S
L_EXIT:
    POP PSW
    POP ACC
    RETI
;要发送的数据
STR_Tab: 				
    DB 48H,45H,4CH,4CH,4FH,2CH,48H,49H,21H,21H;HELLO,HI!!
STR0_TAB:
    DB 0AH,0DH,53H,4DH,41H,4CH,4CH,4FH,53H,3AH;SMALLOS:
UART_TIP:
    DB 5BH,4FH,4BH,5DH,55H,41H,52H,54H,0AH,0DH;[OK]UART
TIMER_TIP:
    DB 0AH,0DH,5BH,4FH,4BH,5DH,54H,49H,4DH,45H;[OK]TIMER
OFF_UART:
    DB 0AH,0DH,5BH,58H,58H,5DH,55H,41H,52H,54H;[XX]UART
;/****************************多任务*************************************/    
;初步实现了多任务，但是任务一的优先级大于任务二。
;任务二的运行频率大于任务一。
  ;关闭串口
UART_OFF:
    CALL RX
    MOV DPTR,#OFF_UART  	
	MOV R0,#00H	
    CALL PRINTF
    CLR TR1
    CLR ES
;打开定时器2  
TIMER2_INIT:
    ANL TMOD,#0F0H		;设置定时器模式
	MOV TL0,#091H		;设置定时初值
	MOV TH0,#0FFH		;设置定时初值
	CLR TF0			;清除TF0标志
	SETB TR0		;定时器0开始计时
    JBC TF0,COUNTER
COUNTER:
    SETB TF0
    MOV  R1,#00H
    INC  R1
    CJNE R1,#01H,TASK1
/**
    MOV 0XC9,#0		;初始化T2寄存器，在文件里没有定义，所以直接用地址0XC9
    MOV T2CON,#0		;初始化控制寄存器
    MOV TL2,#000H		;设置定时初值
    MOV TH2,#0DCH		;设置定时初值
    MOV RCAP2L,#0A4H	;设置定时重载值
    MOV RCAP2H,#0FFH	;设置定时重载值
    SETB TR2		;定时器2开始计时 
    MOV IE,#0XA0;IE=0XA0    
    RET
    **/
;任务一
TASK1:
    CLR P1.0
    SETB  P1.0
    JBC TF0, TASK2
    CALL TASK1
;任务二
TASK2:
    SETB P1.2
    CLR  P1.2
    JBC TF0,TASK1
    CALL TASK2
END     
