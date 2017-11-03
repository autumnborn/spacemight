; weapon methods
proc wpn_init uses ebx ecx, pWpn:DWORD, pParent:DWORD, type:BYTE, direct:BYTE
	mov ebx, [pWpn]
	mov ecx, [pParent]
	mov [ebx+WEAPON.parent], ecx
	mov cl, [type]
	mov [ebx+WEAPON.type], cl
	mov cl, [direct]
	mov [ebx+WEAPON.direct], cl

	mov [ebx+WEAPON.img.bmInfo.bmiHeader.biSize], sizeof.BITMAPINFOHEADER
	mov [ebx+WEAPON.img.bmInfo.bmiHeader.biPlanes], 1
	mov [ebx+WEAPON.img.bmInfo.bmiHeader.biBitCount], 32

	.if [type]=W_SIMPLE
		mov eax, 2
		mov ecx, 8
		mov [ebx+WEAPON.size.x], eax
		mov [ebx+WEAPON.size.y], ecx
		mov [ebx+WEAPON.img.bmInfo.bmiHeader.biWidth], eax
		mov [ebx+WEAPON.img.bmInfo.bmiHeader.biHeight], ecx

	.elseif [type]=W_DOUBLE
		mov [ebx+WEAPON.size.x], eax
		mov [ebx+WEAPON.size.y], ecx
	.endif	

	lea eax, [ebx+WEAPON.img.bmInfo]
	lea ecx, [ebx+WEAPON.img.pvBits]
	lea edx, [ebx+WEAPON.img.memDC]
	stdcall _createDIB, eax, ecx, edx
	mov [ebx+WEAPON.img.dib], eax

	mov ecx, [ebx+WEAPON.size.x]
    imul ecx, [ebx+WEAPON.size.x]
    IMG_MEMCOPY [ebx+WEAPON.img.pvBits], img_w1, ecx

	ret
endp

proc wpn_draw uses ebx ecx edx, pWpn:DWORD
	invoke BeginPaint, [hwnd], paint
	
	; mov ebx, [pWpn]
	; mov ecx, [ebx+WEAPON.p.x]
	; mov edx, [ebx+WEAPON.p.y]
	; sub ecx, [ebx+WEAPON.size.x]
	; sub edx, [ebx+WEAPON.size.y]
	; push ebx ecx edx
	; invoke SetPixel, [hdc], [ebx+WEAPON.p.x], [ebx+WEAPON.p.y], 0
	; pop edx ecx ebx 
	; invoke SetPixel, [hdc], [ebx+WEAPON.p.x], edx, 0FF0000h
	mov ecx, [ebx+WEAPON.p.x]
    mov edx, [ebx+WEAPON.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+WEAPON.size.x], [ebx+WEAPON.size.y], [ebx+WEAPON.img.memDC], 0, 0, SRCCOPY


	invoke EndPaint, [hwnd], paint
	ret
endp

proc wpn_fire uses ebx ecx, pWpn:DWORD, startX:DWORD, startY:DWORD
	mov ebx, [pWpn]
	mov ecx, [startX]
	mov [ebx+WEAPON.p.x], ecx
	mov ecx, [startY]
	mov [ebx+WEAPON.p.y], ecx
	; mov ecx, [ebx+WEAPON.timer]
	; test ecx, ecx
	; jnz @F
	invoke timeSetEvent, WPN_TIMER_DELAY, WPN_TIMER_RESOL, wpn_TimeProc, ebx, TIME_PERIODIC
	mov [ebx+WEAPON.timer], eax
  ; @@:
	ret
endp

proc wpn_destructor uses ebx, pWpn:DWORD
	xor eax, eax
	nop
	nop
	nop

	mov ebx, [pWpn]
	mov eax, [ebx+WEAPON.timer]
	test eax, eax
	jz @F
	invoke timeKillEvent, eax
	test eax, eax
	jnz @F
	mov [ebx+WEAPON.timer], 0
  @@:
  	lea eax, [ebx+WEAPON.img.dib]
	lea ecx, [ebx+WEAPON.img.memDC]
	stdcall _deleteDIB, eax, ecx
  	ret
endp

proc wpn_TimeProc uses ebx, uID, uMsg, dwUser, dw1, dw2
	mov ebx, [dwUser]

	cmp [ebx+WEAPON.direct], 0
	jl @F
	inc [ebx+WEAPON.p.y]
	jmp .exitif
  @@:	
	dec [ebx+WEAPON.p.y]
  .exitif:
	 
	.if [ebx+WEAPON.p.y] > SCR_HEIGHT ;sign < 0 as unsign > SCR_HEIGHT too
		stdcall wpn_destructor, ebx
	.endif
	stdcall wpn_draw, ebx 
	ret
endp
