;程序执行的起始地址	
ORG 	0000H				
    LJMP 	Main			
ORG 	0023H
    LJMP INTER
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
    MOV DPTR,#STR_Tab  	
	MOV R0,#00H			

PRINTF: 
    MOV	 A,R0			;下标赋值
	MOVC A, @A+DPTR		;读取数组数据
    CLR  ES
    CLR  TI
    MOV SBUF,A
    CALL DEALAY

    INC	R0				;下标自加
    CALL DEALAY
    CJNE R0,#01EH,Next	;判断是否为30，否则进去STOP，防止循环重复输出
    CALL SHELL
    CALL SHELLPR
Next:		
	SJMP PRINTF
    ;延时	
DEALAY:						
    MOV R7,#250 
    D1: 
        MOV R6,#250    
    D2: 
        DJNZ R6,D2     
    DJNZ R7,D1  
    RET

SHELL:
    MOV DPTR,#00H
    MOV DPTR,#SHELL_Tab  	
    MOV 	R1,#00H
    RET
SHELLPR:
    
    MOV	 A,R1			;下标赋值
	MOVC A, @A+DPTR		;读取数组数据
    CLR  ES
    CLR  TI
    MOV SBUF,A
    CALL DEALAY

    INC	R1				;下标自加
    CALL DEALAY
    CJNE R1,#0AH,Next2	;判断是否为30，否则进去STOP，防止循环重复输出
    CALL STOP_2
Next2:
    SJMP SHELLPR
    ;停止重复发送 
STOP_2:
    SETB TI
    SETB 	ES
    CALL INTER
    CALL STOP_2
    ;读取键盘输入
RX:
    MOV SBUF,A
    JNB TI,$
    CLR TI
    RET

INTER:
    PUSH ACC				
    PUSH PSW
    JBC TI, L_EXIT
	CLR RI			;否则清除发送标志位
    MOV A,SBUF
    CALL RX
L_EXIT:
    POP PSW
    POP ACC
    RETI
    ;判断是否发送完毕
;要发送的数据
STR_Tab: 				
    DB 48H,45H,4CH,4CH,4FH,57H,4FH,52H,4CH,44H,0AH,0DH,57H,45H,4CH,43H,4FH,4DH,45H,0AH,0DH,53H,4DH,41H,4CH,4CH,4FH,53H,0AH,0DH;HELLOWORDWELCOMESMALLOS
SHELL_TAB:
    DB 53H,4DH,41H,4CH,4CH,4FH,53H,3AH,0AH,0DH
END 