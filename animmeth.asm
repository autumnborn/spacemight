; animation methods
if DBG
	nop
	db "animmeth"
	nop
end if

proc anim_init uses ebx ecx edx, pAnim:DWORD, pType:DWORD
	mov ebx, [pAnim]
	mov eax, [pType]

	mov ecx, [eax+ANIMTYPE.frames]
	mov [ebx+ANIM.frames], ecx

	mov ecx, [eax+ANIMTYPE.size.x]
	mov [ebx+ANIM.size.x], ecx
	mov [ebx+ANIM.img.bmInfo.bmiHeader.biWidth], ecx

	mov ecx, [eax+ANIMTYPE.size.y]
	mov [ebx+ANIM.size.y], ecx
	mov [ebx+ANIM.img.bmInfo.bmiHeader.biHeight], ecx
	
	xor edx, edx
	mov eax, [ebx+ANIM.size.x]
	mov ecx, [ebx+ANIM.frames]
	div ecx
	mov [ebx+ANIM.frameW], eax

	mov [ebx+ANIM.img.bmInfo.bmiHeader.biSize], sizeof.BITMAPINFOHEADER
	mov [ebx+ANIM.img.bmInfo.bmiHeader.biPlanes], 1
	mov [ebx+ANIM.img.bmInfo.bmiHeader.biBitCount], 32

	lea eax, [ebx+ANIM.img.bmInfo]
	lea ecx, [ebx+ANIM.img.pvBits]
	lea edx, [ebx+ANIM.img.memDC]
	stdcall _createDIB, eax, ecx, edx
	mov [ebx+ANIM.img.dib], eax

	mov eax, [pType]
	mov ecx, [eax+ANIMTYPE.pimg]
	mov edx, [ebx+ANIM.size.x]
	imul edx, [ebx+ANIM.size.y]
	IMG_MEMCOPY [ebx+ANIM.img.pvBits], ecx, edx

	ret
endp

proc anim_destructor uses ebx, pAnim:DWORD
	mov ebx, [pAnim]
	stdcall _deleteDIB, [ebx+ANIM.img.dib], [ebx+ANIM.img.memDC]
	ret
endp

proc anim_clear uses ebx ecx edx, pAnim:DWORD, x:DWORD, y:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pAnim]
	invoke BitBlt, [hdc], [x], [y], [ebx+ANIM.frameW], [ebx+ANIM.size.y], [screen.memDC], [x], [y], SRCCOPY
	invoke EndPaint, [hwnd], paint
	ret
endp

proc anim_draw uses ebx ecx edx, pAnim:DWORD, x:DWORD, y:DWORD, frame:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pAnim]

	mov eax, [ebx+ANIM.frameW]
	mov ecx, [frame]
	mul ecx
	invoke BitBlt, [hdc], [x], [y], [ebx+ANIM.frameW], [ebx+ANIM.size.y], [ebx+ANIM.img.memDC], eax, 0, SRCCOPY
	
	invoke EndPaint, [hwnd], paint
	
	ret
endp