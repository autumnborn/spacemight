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
	infout INFOUT

	errmsg db "Error", 0
	szBuff db 255 dup(0)
	rcHealth RECT 600, 460, 0, 0
	include 'objdesc.inc'

section '.code' code readable executable
  	
  start:
  	include 'form.asm'

  	stdcall _configWnd
    stdcall _createDIB, screen.bmInfo, screen.pvBits, screen.memDC
    mov [screen.dib], eax

  	mov [player.p.x], 304
  	mov [player.p.y], 224
 

  	stdcall plr_init, player, plrtype
  	stdcall plr_wakeup, player

  	stdcall inf_init, infout

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
  	stdcall wdc_destructor, wdctrl
   	stdcall _deleteDIB, [screen.dib], [screen.memDC]
  	invoke ExitProcess, 0

  	include 'formproc.asm'
  	include 'infout.asm'
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
  proc _deleteDIB uses ebx, dib:DWORD, memDC:DWORD
  	invoke DeleteObject, [dib]
  	invoke DeleteDC, [memDC]
  	ret
  endp 

  ; Random number from 0 to top-1
  proc _rnd uses edx, top:DWORD
	@@:
	  xor edx, edx	
	  rdrand eax
	  jnc @B
	  div [top]
	  mov eax, edx
	  ret
  endp

  ;	Cover for convert v2d unsigned
  ;	iVal - dword value
  ;	pBuf - dword ptr to  str buffer
  proc _val2dsu uses eax ebx ecx edx esi edi, iVal:DWORD, pBuf:DWORD
  	mov eax, [iVal]
  	mov edi, [pBuf]
  	call _v2d
  	call _strRev
  	ret
  endp

  ;	Cover for convert v2d signed
  ;	iVal - dword value
  ;	pBuf - dword ptr to str buffer
  proc _val2dss uses eax ebx ecx edx esi edi, iVal:DWORD, pBuf:DWORD
  	mov eax, [iVal]
  	mov edi, [pBuf]
  	xor edx, edx	;edx -> sign: 0 - p, 1 - n
  	mov ecx, eax
  	rol ecx, 1
  	test cl, 1
  	jz @F
  	inc edx
  	xor ecx, ecx
  	xchg eax, ecx
  	sub eax, ecx

  @@:
  	push edx
  	call _v2d
  	pop edx
  	test edx, edx
  	jz @F
  	mov [edi+ecx], byte "-"

  @@:
  	call _strRev
  	ret 
  endp 

  ; Converts value to dec string
  ; eax - value, edi - ptr to result buffer
  ; Note: num-chars places from right to left
  proc _v2d
  	xor ecx, ecx

  @@:
  	test eax, eax
  	jz @F	
  	xor edx, edx
  	mov ebx, 0Ah
  	div ebx
  	add dl, 30h
  	mov [edi+ecx], dl
  	inc ecx
  	jmp @B

  @@:
  	test ecx, ecx
  	jnz @F
  	mov [edi], byte 30h
    inc ecx
  @@:
  	mov [edi+ecx], word 0	
  	ret
  endp

  ; Reverts null terminated string
  ; edi - ptr to sz string buffer
  proc _strRev
  	push edi
  	mov esi, edi

  @@:
  	mov al, [esi]
  	test al, al
  	jz @F
  	inc esi
  	jmp @B
  
  @@:
  	dec esi
  	cmp esi, edi
  	jbe @F
  	mov al, [esi]
  	xchg al, [edi]
  	mov [esi], al
  	inc edi
  	jmp @B
  @@:
  	pop edi
  	ret
  endp

section '.idata' import data readable
	include 'imports.inc'





