;程序执行的起始地址	
ORG 	0000H				
    LJMP 	Main			
ORG 	0023H
    LJMP UART_INTER
ORG     0030H

Main: 
    MOV SP,#60H
    ;初始化串口参数
    MOV TMOD,#020H		;9600bps
	MOV SCON,#50H		
	MOV TH1,#0FDH		
	MOV TL1,#0FDH
	MOV PCON,#00H
	SETB EA				
	SETB ES		
	SETB TR1
    ;DPTR指向数组
    MOV DPTR,#TIP0  	
	MOV R0,#00H	
    CALL PRINTF

    MOV DPTR,#STR_Tab  	
	MOV R0,#00H	
    CALL PRINTF		

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
CMP_:
	CJNE A, #0DH, RX
    MOV DPTR,#STR0_Tab  	
    MOV R0,#00H 
    CALL PRINTF
    CALL STOP
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
    CALL CMP_
L_EXIT:
    POP PSW
    POP ACC
    RETI
    ;判断是否发送完毕
;要发送的数据
STR_Tab: 				
    DB 48H,45H,4CH,4CH,4FH,2CH,48H,49H,21H,21H;HELLO,HI!!
STR0_TAB:
    DB 0AH,0DH,53H,4DH,41H,4CH,4CH,4FH,53H,3AH;SMALLOS:
TIP0:
    DB 5BH,4FH,4BH,5DH,55H,41H,52H,54H,0AH,0DH;[OK]UART
END    
