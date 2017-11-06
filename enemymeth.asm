; enemy unit methods
if DBG
	nop
	db "enemymeth"
	nop
end if

proc enm_init uses ebx ecx edx, pEnm:DWORD, pPlr: DWORD
	mov ebx, [pEnm]

	mov eax, [pPlr]
	mov [ebx+ENEMY.pPlayer], eax

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

; proc enm_wakeup uses ebx, pEnm:DWORD
; 	mov ebx, [pEnm]
; 	invoke timeSetEvent, ENM_TIMER_DELAY, ENM_TIMER_RESOL, enm_TimeProc, ebx, TIME_PERIODIC 
; 	mov [ebx+ENEMY.timer], eax
; 	ret
; endp

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

;proc enm_TimeProc uses eax ebx ecx edx, uID, uMsg, dwUser, dw1, dw2
proc enm_update uses ebx ecx, pEnm:DWORD
	mov ebx, [pEnm]
	stdcall enm_clear, ebx
	stdcall enm_behavior, ebx
	stdcall enm_updateWpns, ebx
	stdcall enm_draw, ebx
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

proc enm_behavior uses ebx ecx edx, pEnm:DWORD
	mov ebx, [pEnm]
	
	movzx edx, byte [ebx+ENEMY.speed]
	stdcall plr_GetY, [ebx+ENEMY.pPlayer]
	lea ecx, [ebx+ENEMY.p.y]
	add dword [ecx], edx
	cmp [ecx], eax
	jae .exit	 
	stdcall plr_GetX, [ebx+ENEMY.pPlayer]
	mov ecx, [ebx+ENEMY.p.x]
	add eax, 4
	cmp ecx, eax
	ja .toleft
	sub eax, 8
	cmp ecx, eax
	jnb .fire
	add ecx, edx
	jmp @F
  .toleft:	
	sub ecx, edx
	jmp @F
  .fire:
  	stdcall enm_fire, ebx	
  @@:
  	mov [ebx+ENEMY.p.x], ecx
  .exit:	
	ret
endp

proc enm_fire uses ebx ecx edx, pEnm:DWORD
	lea edx, [ebx+ENEMY.wpn]

	xor ecx, ecx
  @@:
	GetDimFieldAddr edx, WEAPON, ecx, exist
	.if byte [eax]=0
		GetDimIndexAddr edx, WEAPON, ecx
		stdcall wpn_fire, eax, [ebx+ENEMY.p.x], [ebx+ENEMY.p.y], [ebx+ENEMY.size.x]
		push ebx
		invoke timeSetEvent, ENM_FIRE_DELAY, ENM_FIRE_RESOL, enm_TimeFireProc, ebx, TIME_ONESHOT
		pop ebx
		;test eax, eax
		;setne [ebx+ENEMY.firesleep]
		jmp @F
	.endif
	inc ecx
	cmp ecx, [edx+WPNARR.length]
	jnz @B 
  @@:
  	ret
endp

proc enm_TimeFireProc, uID, uMsg, dwUser, dw1, dw2
	mov ebx, [dwUser]
	;mov byte [ebx+ENEMY.firesleep], 0
	invoke timeKillEvent, [uID]
	ret
endp

;!!
proc enm_delWpns uses ebx ecx, pWpnArr:DWORD
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
