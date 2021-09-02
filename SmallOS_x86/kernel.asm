NEWseg	equ 800H
write   equ 1000H
;第二扇区
JMP KERNEL
mov     ax, NEWseg
sub     ax,20h
mov     ds,ax            ;DS=800H-20H改变段地址之后，需要减去引导扇区的偏移量

os db 'smallos---:','$'
key   db '????????'
cm_shut_down db 'shutdown'
cm_time db 'time'
cm_help db 'help'
cm_write db 'write'
com_ok db '[OK]COMMAND','$'
com_ok2 db '[OK]WRITE','$'
error db '[ERROR]NO THAT COMMAND','$'
a db '-','$'
tip db '********help*******','$'
tip0 db 'shutdown: closing you computer ,you can input /shutdown/','$'
tip1 db 'time: you can check you system time,input /time/','$'
tip2 db  'write: write in the screen,you can input /save/','$'
KERNEL:
	MOV AX,NEWseg
 	mov ax, cs
	mov ds, ax
	mov es, ax	
	call shell
	JMP $
printf:                 ;显示指定的字符串, 以'$'为结束标记
      mov al,[si]
      cmp al,'$'
      je disover
      mov ah,0eh
      int 10h
      inc si
      jmp printf
disover:
      ret
newline:                     ;显示回车换行
      mov ah,0eh
      mov al,0dh
      int 10h
      mov al,0ah
      int 10h
      ret
HuiXian:
	mov ah,0eh
	int 10h
	ret     
shell:
	mov si,os
	call printf
	mov si,0
input:
	mov ah,00h
	int 16h
	call HuiXian
	cmp al,0dh
	je input_enter
	mov [key+si],al
	inc si
	jmp input
input_enter:
	call commanddeal
	jmp shell
commanddeal:
	mov si,0
	mov cx,8
command:
	mov ah,[cm_shut_down+si]
	mov al,[key+si]
	cmp ah,al
	jne input_enter2
	inc si
	loop command
	jmp shut_down
	ret
shut_down:
	call shutdown
	call clear
	ret
input_enter2:
	call command_2
	jmp shell
command_2:
	mov si,0
	mov cx,4
time_com:
	mov ah,[cm_time+si]
	mov al,[key+si]
	cmp ah,al
	jne input_enter3
	inc si
	loop time_com
	jmp show_time 
	ret
show_time:
	call newline
	mov si,com_ok
	call printf
	call newline
	mov al,4
    	out 70h,al
    	in al,71h
	mov cl,4
	rol al,cl
	mov ch,al
	and al,0fh
	add al,48
	call HuiXian
	mov al,ch
	rol al,cl
	and al,0fh
	add al,48
	call HuiXian
	mov si,a
	call printf
	mov al,2
    	out 70h,al
    	in al,71h
 	mov cl,4;移位参数，移动四位
 	;一共执行两次
 	rol al,cl
 	mov ch,al;暂时存储al的值，防止丢失
 	and al,0fh;剥离后四位数据
 	add al,48
	call HuiXian
 	mov al,ch;恢复数值
 	rol al,cl
 	and al,0fh;剥离后四位数据
 	add al,48
	CALL HuiXian
	call newline
	ret
shutdown:
	mov si,com_ok
	call printf
	call newline
	MOV AX, 5301H      
        XOR BX, BX             
        INT 15H
	MOV AX, 530EH        
        MOV CX, 0102H         
        INT 15H
	MOV AX, 5307H        
        MOV BL, 01H        
        MOV CX, 0003H       
        INT 15H                           
	ret
input_enter3:
	call command_3
	jmp shell
command_3:
	mov si,0
	mov cx,4
help_com:
	mov ah,[cm_help+si]
	mov al,[key+si]
	cmp ah,al
	jne command_4
	inc si
	loop help_com
	jmp help
	ret
help:
	mov si,tip
	call printf
	call newline
	mov si,tip0
	call printf
	call newline
	mov si,tip1
	call printf
	call newline
	mov si,tip2
	call printf
	call newline
	ret
command_4:
	mov si,0
	mov cx,5
write_com:
	mov ah,[cm_write+si]
	mov al,[key+si]
	cmp ah,al
	jne badinput
	inc si
	loop write_com
	jmp c_write
	ret
c_write:
	call newline
	mov si,com_ok
	call printf
	call newline
	;jmp write:0
	ret
badinput:
	mov si,error
	call printf
	call newline
	ret
clear:
	mov si,0
	mov cx,0
	ret	
