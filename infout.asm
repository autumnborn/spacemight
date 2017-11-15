; Information output
if DBG
	nop
	db "infout"
	nop
end if


proc inf_init uses ebx, pInf:DWORD
	mov ebx, [pInf]
	
	mov [ebx+INFOUT.img.bmInfo.bmiHeader.biWidth], SCR_WIDTH
	mov [ebx+INFOUT.img.bmInfo.bmiHeader.biHeight], 30
	mov [ebx+INFOUT.img.bmInfo.bmiHeader.biSize], sizeof.BITMAPINFOHEADER
	mov [ebx+INFOUT.img.bmInfo.bmiHeader.biPlanes], 1
	mov [ebx+INFOUT.img.bmInfo.bmiHeader.biBitCount], 32
	lea eax, [ebx+INFOUT.img.bmInfo]
	lea ecx, [ebx+INFOUT.img.pvBits]
	lea edx, [ebx+INFOUT.img.memDC]
	stdcall _createDIB, eax, ecx, edx
	mov [ebx+INFOUT.img.dib], eax

	ret
endp

proc inf_destructor uses ebx, pInf:DWORD
	mov ebx, [pInf]
	stdcall _deleteDIB, [ebx+INFOUT.img.dib], [ebx+INFOUT.img.memDC]
	ret
endp

proc inf_drawHealth uses eax ebx ecx edx, pInf:DWORD, pPlr:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ecx, [pPlr]
	mov edx, [ecx+PLAYER.pType]
	movzx eax, word [edx+UNITTYPE.health]
	xor edx, edx
	mov bl, 100
	div bl
	movzx ebx, word [ecx+PLAYER.health]
	xchg eax, ebx
	div bx
	mov dl, al ; dl - %
	
	.if dl>60
		mov eax, 0FF00h
	.elseif dl>30
		mov eax, 0FFFF00h
	.else
		mov eax, 0FF0000h
	.endif

	mov ebx, [pInf]
	mov edi, [ebx+INFOUT.img.pvBits]
	xor cl, cl

  @@:	
	stosd
	inc cl
	cmp cl, dl
	jb @B
	xor eax, eax
	cmp cl, 100
	jb @B

	invoke BitBlt, [hdc], INF_HEALTH_X, INF_HEALTH_Y, 100, 1, [screen.memDC], INF_HEALTH_X, INF_HEALTH_Y, SRCCOPY
	invoke BitBlt, [hdc], INF_HEALTH_X, INF_HEALTH_Y, 100, 1, [ebx+INFOUT.img.memDC], 0, 29, SRCCOPY
	invoke EndPaint, [hwnd], paint
	ret
endp

proc inf_drawText uses eax ebx ecx edx, pInf:DWORD, pszBuff:DWORD, x:DWORD, y:DWORD, color:DWORD
	mov ebx, [pInf]
	mov eax, [x]
	mov [ebx+INFOUT.rect.left], eax
	mov eax, [y]
	mov [ebx+INFOUT.rect.top], eax

	invoke SetBkMode, [hdc], TRANSPARENT
	invoke SetTextColor, [hdc], [color]
	lea eax, [ebx+INFOUT.rect]
	invoke DrawText, [hdc], [pszBuff], -1, eax, DT_NOCLIP
	
	ret
endp