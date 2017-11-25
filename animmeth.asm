; animation methods
if DBG
	nop
	db "animmeth"
	nop
end if

; Constructor
; pType - ptr to ANIMTYPE
proc anim_init uses ebx ecx edx, pAnim:DWORD, pType:DWORD
	mov ebx, [pAnim]
	mov eax, [pType]

	mov [ebx+ANIM.frmNext], 0

	mov [ebx+ANIM.pType], eax

	mov ecx, [eax+ANIMTYPE.frmCount]
	mov [ebx+ANIM.frmCount], ecx

	mov ecx, [eax+ANIMTYPE.size.y]
	mov [ebx+ANIM.size.y], ecx
	mov [ebx+ANIM.img.bmInfo.bmiHeader.biHeight], ecx	

	mov ecx, [eax+ANIMTYPE.size.x]
	mov [ebx+ANIM.img.bmInfo.bmiHeader.biWidth], ecx

	xor edx, edx
	mov eax, ecx
	mov ecx, [ebx+ANIM.frmCount]
	div ecx
	mov [ebx+ANIM.size.x], eax

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
	mov edx, [eax+ANIMTYPE.size.x]
	imul edx, [eax+ANIMTYPE.size.y]
	IMG_MEMCOPY [ebx+ANIM.img.pvBits], ecx, edx

	ret
endp

; ~
proc anim_destructor uses ebx, pAnim:DWORD
	mov ebx, [pAnim]
	stdcall _deleteDIB, [ebx+ANIM.img.dib], [ebx+ANIM.img.memDC]
	ret
endp

; Clear screen at current animation position
proc anim_clear uses ebx ecx edx, pAnim:DWORD, x:DWORD, y:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pAnim]
	invoke BitBlt, [hdc], [x], [y], [ebx+ANIM.size.x], [ebx+ANIM.size.y], [screen.memDC], [x], [y], SRCCOPY
	invoke EndPaint, [hwnd], paint
	ret
endp

; Draws one frame from animation sequence
; pAnim - ptr to instance of ANIM
; x, y - coords
; idx - index of frame to draw
; return index of next frame
proc anim_draw uses ebx ecx edx, pAnim:DWORD, x:DWORD, y:DWORD, idx:DWORD
	mov ebx, [pAnim]
	
	mov ecx, [idx]
	mov eax, [ebx+ANIM.frmCount]
	inc ecx
	.if ecx>eax
		xor eax, eax
		jmp @F
	.elseif ecx=eax
		xor ecx, ecx
	.endif

	push ecx
	invoke BeginPaint, [hwnd], paint
	mov eax, [ebx+ANIM.size.x]
	mov ecx, [idx]
	mul ecx
	invoke BitBlt, [hdc], [x], [y], [ebx+ANIM.size.x], [ebx+ANIM.size.y], [ebx+ANIM.img.memDC], eax, 0, SRCCOPY
	invoke EndPaint, [hwnd], paint
	pop eax

  @@:
	ret
endp

; Draws frame and store next index for next call
; pAnim - ptr to instance of ANIM
; x, y - coords
; return index of next frame
proc anim_drawNext uses ebx ecx, pAnim:DWORD, x:DWORD, y:DWORD
	mov ebx, [pAnim]
	stdcall anim_draw, ebx, [x], [y], [ebx+ANIM.frmNext]
	mov [ebx+ANIM.frmNext], eax
	ret
endp