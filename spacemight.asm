format PE GUI 4.0
entry start

include 'win32a.inc'
include 'macro\if.inc'
include 'equates.inc'
include 'macro.inc'
include 'structures.inc'

section '.data' data readable writeable
	wClass db "SpaceMightWindow", 0
	wTitle db "Space Might", 0
	wc WNDCLASS 0,WindowProc,0,0,0,0,0,COLOR_BTNFACE+1,0,wClass
	hwnd dd ?
	msg MSG
	hdc dd ?
	screen DIBINFO ?, ?, ?, <<sizeof.BITMAPINFOHEADER, SCR_WIDTH, SCR_HEIGHT, 1, 32>>
	paint PAINTSTRUCT
	player PLAYER
	enemy ENEMY
	wdctrl WORLDCTRL

	errmsg db "Error", 0
	img_pl file "img\sm_plr_32x32x32_raw.bmp"
	img_w1 file "img\sm_wpn1_2x8x32_raw.bmp"
	img_e1 file "img\sm_enm1_24x32x32_raw.bmp"
	worldTimer dd ?; temp

section '.code' code readable executable
  	
  start:
  	include 'form.asm'
 
  	stdcall _configWnd
    stdcall _createDIB, screen.bmInfo, screen.pvBits, screen.memDC
    mov [screen.dib], eax

  	mov [player.p.x], 304
  	mov [player.p.y], 224
 

  	stdcall plr_init, player
  	stdcall plr_wakeup, player

  	mov [enemy.p.x], 10
  	mov [enemy.p.y], 20
  	stdcall wdc_init, wdctrl
  	stdcall wdc_wakeup, wdctrl

  .msg_loop:
    invoke GetMessage, msg, NULL, 0, 0
    cmp eax,0
    je exit

    stdcall _control

    invoke TranslateMessage, msg
    invoke DispatchMessage, msg
    jmp .msg_loop


  exit:
  	stdcall plr_destructor, player
   	stdcall _deleteDIB, [screen.dib], [screen.memDC]
  	invoke ExitProcess, 0

  	include 'formproc.asm'
  	include 'enemymeth.asm'
  	include 'playermeth.asm'
  	include 'weaponmeth.asm'
  	include 'worldctrlmeth.asm'

  ; Keyboard handler
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
	  	  
	  push ebx ecx edx
	  invoke GetAsyncKeyState, VK_SPACE
	  pop edx ecx ebx 
	  and eax, 8000h
	  .if eax<>0
	  	mov al, -1
	  .endif
	  .if al <> [player.act.fire]
	  	not [player.act.fire]
	  .endif
	  
	@@:
	  ret
  endp

 
  ; bmInfo - ptr to BITMAPINFO
  ; pvBits - ptr to var for ptr to bitmap bits
  ; memDC  - ptr to var for handle to a memory device context
  ; return dib-handle, pvBits - ptr to bitmap bits, memDC - handle to a memory device context
  proc _createDIB uses ebx, bmInfo:DWORD, pvBits:DWORD, memDC:DWORD
    invoke CreateCompatibleDC, [hdc]
    mov ebx, [memDC]
    mov [ebx], eax
    push ebx
    invoke CreateDIBSection, [hdc], [bmInfo], DIB_RGB_COLORS, [pvBits], NULL, NULL    
    pop ebx
    push eax
    invoke SelectObject, [ebx], eax
    pop eax
    ret
  endp

  ; dib - dib handle returned _createDIB
  proc _deleteDIB, dib:DWORD, memDC:DWORD
  	invoke DeleteObject, [dib]
  	invoke ReleaseDC, [hwnd], [memDC]
  	ret
  endp 

  proc _rnd uses edx, max:DWORD
	@@:
	  xor edx, edx	
	  rdrand eax
	  jnc @B
	  div [max]
	  mov eax, edx
	  ret
  endp

section '.idata' import data readable
	include 'imports.inc'





