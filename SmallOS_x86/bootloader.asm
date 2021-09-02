NUMSECOR       EQU    8
NUMHEADER      EQU    0
NUMCYLIND      EQU    0 
mbrseg         equ    7c0h     ;启动扇区存放段地址
NEWseg         equ    800H
colorfuncport equ 3c8h   ;设置调色板功能端口
colorsetport equ 3c9h    ;设置调色板颜色端口
displayadd equ 0xa000    ;图像模式显存起始地址

jmp   start
MESSAGE1:DB 'HELLO,WELCOME','$'
MESSAGE2:DB '**SMALLOS**','$'
MESSAGE4:DB 'OPERATION SYSTEM RUN OK','$'

CYLIND DB 'CYLIND:?? $',0
HEADER DB 'HEADER:?? $',0
SECTOR DB 'SECTOR:?? $',2

FLOPPYOK DB '[OK]READ','$'
FYERROR  DB '[ERROR]READ','$'

start:
	CALL  INMBR
	CALL  FLOPPYLOAD
	call setmode
	call backgroud
	JMP NEWseg:0
setmode:
	mov ah,0
	mov al,03h         ;320*200
	int 10h
	ret
backgroud:         ;背景色设置
	mov dx,  colorfuncport
	mov al,  0           ;建调色板索引0号
	out dx,al
	mov dx,  colorsetport   ;设置蓝色背景
	mov al,0          ;R分量
	out dx,al
	mov al,0           ;G分量
	out dx,al
	mov al,35          ;B分量
	out dx,al
	ret
INMBR:
	MOV AX,mbrseg
	MOV DS,AX
	MOV AX,NEWseg
	MOV ES,AX
	CALL INMBRSHOW
	RET
INMBRSHOW:
	MOV SI,MESSAGE1
	CALL PRINTF
	CALL ENTER
	MOV SI,MESSAGE2
	CALL PRINTF
	CALL ENTER
	MOV SI ,MESSAGE4
	CALL PRINTF
	CALL ENTER
	RET
PRINTF:    	              ;显示指定的字符串, 以'$'为结束标记
      mov AL,[SI]
      cmp al,'$'
      je DISCOVER
      mov ah,0eh
      int 10h
      inc si
      jmp PRINTF
DISCOVER:
      ret
ENTER:                     ;显示回车换行
      mov ah,0eh
      mov al,0dh
      int 10h
      mov al,0ah
      int 10h
      ret
FLOPPYLOAD:
	CALL READ1SECTOR
	MOV  AX,ES
	ADD  AX,0X0020
	MOV ES,AX
	INC BYTE[SECTOR+11]
	CMP BYTE[SECTOR+11],NUMSECOR+1
	JNE FLOPPYLOAD
	MOV BYTE[SECTOR+11],1
	INC BYTE[HEADER+11]
	CMP BYTE[HEADER+11],NUMHEADER+1
	JNE FLOPPYLOAD
	MOV BYTE[HEADER+11],0
	INC BYTE[CYLIND+11]
	CMP BYTE[CYLIND+11],NUMHEADER+1
	JNE FLOPPYLOAD
	RET
NUMTOASCII:
	MOV AX,0
	MOV AL,CL
	MOV BL,10
	DIV BL
	ADD AX,3030H
	RET
READ1SECTOR:
	MOV CL,[SECTOR+11]
	CALL NUMTOASCII
	MOV [SECTOR+7],AL
	MOV [SECTOR+8],AH
	
	MOV CL,[HEADER+11]
	CALL NUMTOASCII
	MOV [HEADER+7],AL
	MOV [HEADER+8],AH

	MOV CH,[CYLIND+11]
	MOV DH,[HEADER+11]
	MOV CL,[SECTOR+11]
	
	MOV DI,0
RETRY:
	MOV AH,02H
	MOV AL,1
	MOV BX,0
	MOV DL,00H
	INT 13H
	JNC READOK
	INC DI
	MOV AH,0X00
	MOV DL,0X00
	INT 0X13
	CMP DI,5
	JNE RETRY

	MOV SI,FYERROR
	CALL PRINTF
	CALL ENTER
	JMP EXITREAD
READOK:
	MOV SI,FLOPPYOK
	CALL PRINTF
	CALL ENTER
EXITREAD:
	RET
TIMES 510-($-$$) DB 0
DB 0X55,0XAA

