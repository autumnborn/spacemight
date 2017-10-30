format PE GUI 4.0
entry start

include 'win32a.inc'
include 'macro\if.inc'
include 'equates.inc'
include 'structures.inc'

section '.data' data readable writeable
	wClass db "SpaceMightWindow", 0
	wTitle db "Space Might", 0
	wc WNDCLASS 0,WindowProc,0,0,0,0,0,COLOR_BTNFACE+1,0,wClass
	hwnd dd ?
	msg MSG
	hdc dd ?
	dib dd ?
	memDC dd ?
	pvBits dd ?
	bmInfo BITMAPINFO <sizeof.BITMAPINFOHEADER, 640, 480, 1, 32>
	paint PAINTSTRUCT
	player PLAYER
	errmsg db "Error", 0

section '.code' code readable executable
  start:
  	include 'form.asm'
  
  	mov [player.p.x], 100
  	mov [player.p.y], 100
  	mov [player.size.x], 100
  	mov [player.size.y], 100
  	stdcall plr_wakeup, player

  .msg_loop:
    invoke GetMessage, msg, NULL, 0, 0
    cmp eax,0
    je exit
    ; stdcall plr_draw, player
    ; stdcall plr_ctrl, player
    stdcall _control

    invoke TranslateMessage, msg
    invoke DispatchMessage, msg
    jmp .msg_loop


  exit:
  	stdcall plr_destructor, player
  	invoke ExitProcess, 0

  	include 'formproc.asm'
  	include 'playermeth.asm'

  	proc _control uses ebx ecx edx 

	  push ebx ecx edx
	  invoke GetAsyncKeyState, VK_LEFT
	  pop edx ecx ebx 
	  and eax, 8000h
	  .if eax<>0
	  	mov al, -1
	  .endif
	  .if al <> [player.act.left]
	  	not [player.act.left]
	  .endif
	  
	  push ebx ecx edx
	  invoke GetAsyncKeyState, VK_UP
	  pop edx ecx ebx 
	  and eax, 8000h
	  .if eax<>0
	  	mov al, -1
	  .endif
	  .if al <> [player.act.up]
	  	not [player.act.up]
	  .endif
	  
	  push ebx ecx edx
	  invoke GetAsyncKeyState, VK_RIGHT
	  pop edx ecx ebx 
	  and eax, 8000h
	  .if eax<>0
	  	mov al, -1
	  .endif
	  .if al <> [player.act.right]
	  	not [player.act.right]
	  .endif
	  
	  push ebx ecx edx
	  invoke GetAsyncKeyState, VK_DOWN
	  pop edx ecx ebx 
	  and eax, 8000h
	  .if eax<>0
	  	mov al, -1
	  .endif
	  .if al <> [player.act.down]
	  	not [player.act.down]
	  .endif
	  

	@@:
	  ret
  	endp

section '.idata' import data readable
	include 'imports.inc'





