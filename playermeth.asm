; player unit methods
if DBG
	nop
	db "playermeth"
	nop
end if

proc plr_init uses ebx ecx edx, pPlr:DWORD
	mov ebx, [pPlr]
	mov [ebx+PLAYER.size.x], 32
	mov [ebx+PLAYER.size.y], 32
	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biSize], sizeof.BITMAPINFOHEADER
	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biPlanes], 1
	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biBitCount], 32

	mov eax, [ebx+PLAYER.size.x]
	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biWidth], eax
	mov eax, [ebx+PLAYER.size.y]
	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biHeight], eax

	lea eax, [ebx+PLAYER.img.bmInfo]
	lea ecx, [ebx+PLAYER.img.pvBits]
	lea edx, [ebx+PLAYER.img.memDC]
	stdcall _createDIB, eax, ecx, edx
	mov [ebx+PLAYER.img.dib], eax

	mov ecx, [ebx+PLAYER.size.x]
    imul ecx, [ebx+PLAYER.size.y]
    IMG_MEMCOPY [ebx+PLAYER.img.pvBits], img_pl, ecx

    mov [ebx+PLAYER.speed], 4 

 	lea edx, [ebx+PLAYER.wpn]
    xor ecx, ecx
  @@:  
 	GetDimIndexAddr edx, WEAPON, ecx
	stdcall wpn_init, eax, wpntype_1, ebx, -1
	inc ecx
	cmp ecx, [edx+WPNARR.length] ; eq [ebx+PLAYER.wpn.length] 
	jnz @B
	ret
endp

proc plr_clear uses ebx ecx edx, pPlr:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pPlr]
    
    mov ecx, [ebx+PLAYER.p.x]
    mov edx, [ebx+PLAYER.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+PLAYER.size.x], [ebx+PLAYER.size.y], [screen.memDC], ecx, edx, SRCCOPY

	invoke EndPaint, [hwnd], paint
	ret
endp

proc plr_draw uses ebx ecx edx, pPlr:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pPlr]

    mov ecx, [ebx+PLAYER.p.x]
    mov edx, [ebx+PLAYER.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+PLAYER.size.x], [ebx+PLAYER.size.y], [ebx+PLAYER.img.memDC], 0, 0, SRCCOPY


	invoke EndPaint, [hwnd], paint
	ret
endp

proc plr_wakeup uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	invoke timeSetEvent, PLR_TIMER_DELAY, PLR_TIMER_RESOL, plr_TimeProc, ebx, TIME_PERIODIC 
	mov [ebx+PLAYER.timer], eax
	ret
endp

proc plr_destructor uses ebx, pPlr:DWORD
	mov ebx, [pPlr]

	lea eax, [ebx+PLAYER.wpn]
	stdcall plr_delWpns, eax
	
	mov eax, [ebx+PLAYER.timer]
	test eax, eax
	jz @F
	invoke timeKillEvent, eax
	mov [ebx+PLAYER.timer], 0
  @@:
	lea eax, [ebx+PLAYER.img.dib]
	lea ecx, [ebx+PLAYER.img.memDC]
	stdcall _deleteDIB, eax, ecx
  	ret
endp

proc plr_TimeProc uses eax ebx ecx edx, uID, uMsg, dwUser, dw1, dw2
	mov ebx, [dwUser]


	.if dword [ebx+PLAYER.act.left]
		stdcall plr_clear, ebx
	.endif

	lea ecx, [ebx+PLAYER.p.x]
	lea edx, [ebx+PLAYER.p.y]

	.if [ebx+PLAYER.act.left]
		cmp dword [ecx], 0
		jna @F
		movzx eax, [ebx+PLAYER.speed] 
		sub dword [ecx], eax  
	  @@:
	.endif 

	.if [ebx+PLAYER.act.right]
		mov eax, [ebx+PLAYER.size.x]
		add eax, [ecx] 
		cmp eax, SCR_WIDTH
		jnb @F
		movzx eax, [ebx+PLAYER.speed]
		add dword [ecx], eax
	  @@:
	.endif
	
	.if [ebx+PLAYER.act.up]
		cmp dword [edx], 0
		jna @F
		movzx eax, [ebx+PLAYER.speed]
		sub dword [edx], eax
	  @@:	
	.endif 
	
	.if [ebx+PLAYER.act.down]
		mov eax, [ebx+PLAYER.size.y]
		add eax, [edx] 
		cmp eax, SCR_HEIGHT
		jnb @F
		movzx eax, [ebx+PLAYER.speed]
		add dword [edx], eax
	  @@:
	.endif


	.if [ebx+PLAYER.act.fire] & ~[ebx+PLAYER.firesleep]
		lea edx, [ebx+PLAYER.wpn]

		xor ecx, ecx
	  @@:
		GetDimFieldAddr edx, WEAPON, ecx, exist
		.if byte [eax]=0
			GetDimIndexAddr edx, WEAPON, ecx
			stdcall wpn_fire, eax, [ebx+PLAYER.p.x], [ebx+PLAYER.p.y], [ebx+PLAYER.size.x]
			push ebx
			invoke timeSetEvent, PLR_FIRE_DELAY, PLR_FIRE_RESOL, plr_TimeFireProc, ebx, TIME_ONESHOT
			pop ebx
			test eax, eax
			setne [ebx+PLAYER.firesleep]
			jmp @F
		.endif
		inc ecx
		cmp ecx, [edx+WPNARR.length]
		jnz @B 
	  @@:
	.endif

	stdcall plr_draw, ebx
	stdcall plr_updateWpns, ebx
	ret
endp

proc plr_TimeFireProc, uID, uMsg, dwUser, dw1, dw2
	mov ebx, [dwUser]
	mov byte [ebx+PLAYER.firesleep], 0
	invoke timeKillEvent, [uID]
	ret
endp

proc plr_updateWpns uses ebx ecx edx, pPlr:DWORD
	mov ebx, [pPlr]
 	lea edx, [ebx+PLAYER.wpn]
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
	cmp ecx, [edx+WPNARR.length] ; eq [ebx+PLAYER.wpn.length] 
	jnz @B	
	ret

endp

; Visibility for enemies
; returns coordinate x
proc plr_GetX uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	mov eax, [ebx+PLAYER.p.x]
	ret
endp

; Visibility for enemies
; returns coordinate y
proc plr_GetY uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	mov eax, [ebx+PLAYER.p.y]
	ret
endp

proc plr_hit uses ebx ecx, pEnm:DWORD, pWpn:DWORD
	mov ebx, [pEnm]
	mov ecx, [pWpn]
	stdcall wpn_hit, ecx
	lea eax, [ebx+ENEMY.health]
	sub [eax], [ecx+WEAPON.damage]
	cmp [eax], 0
	ja @F
	stdcall plr_die, ebx
  @@: 
	ret
endp

proc plr_die uses ebx ecx, pEnm:DWORD
	mov ebx, [pEnm]
	;todo something
	stdcall plr_clear, ebx
	ret
endp


; call destructor for all instances of WEAPON (WPNARR)
; N.B: replace to common
proc plr_delWpns uses ebx ecx, pWpnArr: DWORD
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