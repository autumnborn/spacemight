; enemy unit methods
proc enm_init uses ebx ecx edx, pEnm:DWORD
	mov ebx, [pEnm]
	mov [ebx+ENEMY.size.x], 24
	mov [ebx+ENEMY.size.y], 32
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biSize], sizeof.BITMAPINFOHEADER
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biPlanes], 1
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biBitCount], 32

	mov eax, [ebx+ENEMY.size.x]
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biWidth], eax
	mov eax, [ebx+ENEMY.size.y]
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biHeight], eax

	lea eax, [ebx+ENEMY.img.bmInfo]
	lea ecx, [ebx+ENEMY.img.pvBits]
	lea edx, [ebx+ENEMY.img.memDC]
	stdcall _createDIB, eax, ecx, edx
	mov [ebx+ENEMY.img.dib], eax

	mov ecx, [ebx+ENEMY.size.x]
    imul ecx, [ebx+ENEMY.size.y]
    IMG_MEMCOPY [ebx+ENEMY.img.pvBits], img_e1, ecx

    mov [ebx+ENEMY.speed], 2 

 	lea edx, [ebx+ENEMY.wpn]
    xor ecx, ecx
  @@:  
 	GetDimIndexAddr edx, WEAPON, ecx
	stdcall wpn_init, eax, ebx, W_SIMPLE, 0
	inc ecx
	cmp ecx, [edx+WPNARR.length]
	jnz @B
	ret
endp

proc enm_clear uses ebx ecx edx, pEnm:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pEnm]
    mov ecx, [ebx+ENEMY.p.x]
    mov edx, [ebx+ENEMY.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+ENEMY.size.x], [ebx+ENEMY.size.y], [screen.memDC], ecx, edx, SRCCOPY
	invoke EndPaint, [hwnd], paint
	ret
endp

proc enm_draw uses ebx ecx edx, pEnm:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pEnm]
    mov ecx, [ebx+ENEMY.p.x]
    mov edx, [ebx+ENEMY.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+ENEMY.size.x], [ebx+ENEMY.size.y], [ebx+ENEMY.img.memDC], 0, 0, SRCCOPY
	invoke EndPaint, [hwnd], paint
	ret
endp

proc enm_wakeup uses ebx, pEnm:DWORD
	mov ebx, [pEnm]
	invoke timeSetEvent, ENM_TIMER_DELAY, ENM_TIMER_RESOL, enm_TimeProc, ebx, TIME_PERIODIC 
	mov [ebx+ENEMY.timer], eax
	ret
endp

proc enm_destructor uses ebx, pEnm:DWORD
	mov ebx, [pEnm]

	lea eax, [ebx+ENEMY.wpn]
	stdcall enm_delWpns, eax
	
	mov eax, [ebx+ENEMY.timer]
	test eax, eax
	jz @F
	invoke timeKillEvent, eax
	mov [ebx+ENEMY.timer], 0
  @@:
	lea eax, [ebx+ENEMY.img.dib]
	lea ecx, [ebx+ENEMY.img.memDC]
	stdcall _deleteDIB, eax, ecx
  	ret
endp

proc enm_TimeProc uses eax ebx ecx edx, uID, uMsg, dwUser, dw1, dw2
	mov ebx, [dwUser]

	stdcall enm_draw, ebx
	stdcall enm_updateWpns, ebx
	ret
endp

proc enm_updateWpns uses ebx ecx edx, pEnm:DWORD
	mov ebx, [pEnm]
 	lea edx, [ebx+ENEMY.wpn]
    xor ecx, ecx
  
  @@:  
  	GetDimFieldAddr edx, WEAPON, ecx, exist
  	mov al, byte [eax]
  	test al, al
  	jz .skip
 	GetDimIndexAddr edx, WEAPON, ecx
	stdcall wpn_update, eax

  .skip:	
	inc ecx
	cmp ecx, [edx+WPNARR.length]
	jnz @B	
	ret

endp

;!!
proc enm_delWpns uses ebx ecx, pWpnArr: DWORD
	mov ebx, [pWpnArr]
	xor ecx, ecx
  @@:  
 	GetDimIndexAddr ebx, WEAPON, ecx
	stdcall wpn_destructor, eax
	inc ecx
	cmp ecx, [ebx+WPNARR.length]
	jnz @B

	ret
endp