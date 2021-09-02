NEWseg equ 800h
write  equ 1000h
jmp Write
mess db 'writing','$'
Write:
	mov ax,write
	mov ax,cs
	mov ds,ax

	call output
	call input
	jmp $
input:
    mov ah,0
    int 16h                        ;从键盘读字符 ah=扫描码 al=字符码
    mov ah,0eh                     ;把键盘输入的字符显示出来 
    int 10h
    cmp    al, 0dh                 ;回车作为输入结束标记
    je     newline
    cmp    al,01bh
    je     back
    jmp    input
back:
	jmp NEWseg:$
	ret
output:
	mov si,mess
	call printf
	call newline
	ret
printf:
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
