; weapon methods
if DBG
	nop
	db "weaponmeth"
	nop
end if

proc wpn_init uses ebx ecx edx, pWpn:DWORD, pType:DWORD, pParent:DWORD, direct:BYTE
	mov ebx, [pWpn]
	mov ecx, [pParent]
	mov [ebx+WEAPON.parent], ecx

	mov cl, [direct]
	mov [ebx+WEAPON.direct], cl

	mov eax, [pType]
	mov cl, [eax+WPNTYPE.type]
	mov [ebx+WEAPON.type], cl
	
	mov cx, [eax+WPNTYPE.damage]
	mov [ebx+WEAPON.damage], cx
	
	mov ecx, [eax+WPNTYPE.size.x]
	mov [ebx+WEAPON.size.x], ecx
	mov [ebx+WEAPON.img.bmInfo.bmiHeader.biWidth], ecx

	mov ecx, [eax+WPNTYPE.size.y]
	mov [ebx+WEAPON.size.y], ecx
	mov [ebx+WEAPON.img.bmInfo.bmiHeader.biHeight], ecx

	mov [ebx+WEAPON.img.bmInfo.bmiHeader.biSize], sizeof.BITMAPINFOHEADER
	mov [ebx+WEAPON.img.bmInfo.bmiHeader.biPlanes], 1
	mov [ebx+WEAPON.img.bmInfo.bmiHeader.biBitCount], 32

	lea eax, [ebx+WEAPON.img.bmInfo]
	lea ecx, [ebx+WEAPON.img.pvBits]
	lea edx, [ebx+WEAPON.img.memDC]
	stdcall _createDIB, eax, ecx, edx
	mov [ebx+WEAPON.img.dib], eax

	mov eax, [pType]
    mov ecx, [eax+WPNTYPE.pimg]
	mov edx, [ebx+WEAPON.size.x]
    imul edx, [ebx+WEAPON.size.y]
    IMG_MEMCOPY [ebx+WEAPON.img.pvBits], ecx, edx

	ret
endp

proc wpn_clear uses ebx ecx edx, pWpn:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pWpn]
    
    mov ecx, [ebx+WEAPON.p.x]
    mov edx, [ebx+WEAPON.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+WEAPON.size.x], [ebx+WEAPON.size.y], [screen.memDC], ecx, edx, SRCCOPY

	invoke EndPaint, [hwnd], paint
	ret
endp

proc wpn_draw uses ebx ecx edx, pWpn:DWORD
	invoke BeginPaint, [hwnd], paint

	mov ecx, [ebx+WEAPON.p.x]
    mov edx, [ebx+WEAPON.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+WEAPON.size.x], [ebx+WEAPON.size.y], [ebx+WEAPON.img.memDC], 0, 0, SRCCOPY

	invoke EndPaint, [hwnd], paint
	ret
endp

proc wpn_fire uses ebx ecx edx, pWpn:DWORD, startX:DWORD, startY:DWORD, hostW:DWORD, hostH:DWORD, direct:BYTE
	mov ebx, [pWpn]
	mov cl, [direct]
	mov [ebx+WEAPON.direct], cl
	;center X align
	mov ecx, [hostW]
	sub ecx, [ebx+WEAPON.size.x]
	shr ecx, 1
	add ecx, [startX]
	mov [ebx+WEAPON.p.x], ecx
	
	mov ecx, [startY]
	;startY align cond direct
	cmp [ebx+WEAPON.direct], WPN_DIRECT_D
	jnz @F 
	add ecx, [hostW]
  @@:	
	mov [ebx+WEAPON.p.y], ecx
	mov byte [ebx+WEAPON.exist], -1
	ret
endp

proc wpn_stop uses ebx, pWpn:DWORD
	mov ebx, [pWpn]
	mov al, [ebx+WEAPON.exist]
	test al, al
	jz @F
	mov byte [ebx+WEAPON.exist], 0
  @@:
	ret
endp

proc wpn_destructor uses ebx ecx, pWpn:DWORD
	mov ebx, [pWpn]
	stdcall wpn_stop, ebx
	stdcall _deleteDIB, [ebx+WEAPON.img.dib], [ebx+WEAPON.img.memDC]
  	ret
endp

;ex-wpn_TimeProc
proc wpn_update uses ebx, pWpn:DWORD
	mov ebx, [pWpn]
	stdcall wpn_clear, ebx

	cmp [ebx+WEAPON.direct], WPN_DIRECT_D
	jl @F
	add [ebx+WEAPON.p.y], WPN_SPEED
	jmp .exitif
  @@:	
	sub [ebx+WEAPON.p.y], WPN_SPEED
  .exitif:
	 
	.if [ebx+WEAPON.p.y] > SCR_HEIGHT ;sign < 0 as unsign > SCR_HEIGHT too
		stdcall wpn_stop, ebx
		jmp @F
	.endif
	stdcall wpn_draw, ebx 
  @@:	
	ret
endp

proc wpn_hit uses ebx ecx, pWpn:DWORD
	mov ebx, [pWpn]
	stdcall wpn_stop, ebx
	stdcall wpn_clear, ebx
	ret
endp