;程序执行的起始地址	
ORG 	0000H				
    LJMP 	Main			
ORG 	0023H
    LJMP UART_INTER
ORG     0030H
Main:
    MOV SP,#60H
    ;初始化串口参数
   		;9600bps
    SETB EA				
	SETB ES 
    MOV TMOD,#021H
    MOV TH1,#0FDH		
	MOV TL1,#0FDH 
	MOV SCON,#50H		
	MOV PCON,#00H
    SETB TR1
	CALL PRINT_TIP
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
    D1: 
        MOV R6,#250    
    D2: 
        DJNZ R6,D2     
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
CMP_T:
    CJNE A,#54H,CMP_S ;T键打开定时器 
    MOV DPTR,#TIMER_TIP  	
	MOV R0,#00H	
    CALL PRINTF
    CALL TIMER_ON
CMP_S:          
    CJNE A, #53H,CMP_ENTER ;S键关闭串口
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
    
    CALL CMP_T
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
;关闭串口
UART_OFF:
    CALL RX
    MOV DPTR,#OFF_UART  	
	MOV R0,#00H	
    CALL PRINTF
    CLR ES
    CLR TR1
    RETI
;打开软件计时器
TIMER_ON:
    INC R1
    INC R3
    CJNE R1,#3e8H,TIMER_ON
    AJMP TASK1
;任务一
TASK1:
;任务二
TASK2:
END    
