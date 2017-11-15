; player unit methods
if DBG
	nop
	db "playermeth"
	nop
end if

; pType - pointer to UNITTYPE
proc plr_init uses ebx ecx edx, pPlr:DWORD, pType:DWORD
	locals
		pWpnType dd ?
		wpnDirect dd ?
	endl

	mov ebx, [pPlr]

	mov eax, [pType]
	mov [ebx+PLAYER.pType], eax
	mov ecx, [eax+UNITTYPE.pWpnType]
	mov [pWpnType], ecx 

	movzx ecx, byte [eax+UNITTYPE.wpnDirect]
	mov [ebx+PLAYER.wpnDirect], cl
	mov [wpnDirect], ecx

	mov cl, [eax+UNITTYPE.speed]
    mov [ebx+PLAYER.speed], cl

	mov cx, [eax+UNITTYPE.health]
    mov [ebx+PLAYER.health], cx
	
	mov ecx, [eax+UNITTYPE.size.x]
	mov [ebx+PLAYER.size.x], ecx
	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biWidth], ecx

	mov ecx, [eax+UNITTYPE.size.y]
	mov [ebx+PLAYER.size.y], ecx
	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biHeight], ecx

	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biSize], sizeof.BITMAPINFOHEADER
	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biPlanes], 1
	mov [ebx+PLAYER.img.bmInfo.bmiHeader.biBitCount], 32

	lea eax, [ebx+PLAYER.img.bmInfo]
	lea ecx, [ebx+PLAYER.img.pvBits]
	lea edx, [ebx+PLAYER.img.memDC]
	stdcall _createDIB, eax, ecx, edx
	mov [ebx+PLAYER.img.dib], eax

	mov eax, [pType]
    mov ecx, [eax+UNITTYPE.pimg]
	mov edx, [ebx+PLAYER.size.x]
    imul edx, [ebx+PLAYER.size.y]
    IMG_MEMCOPY [ebx+PLAYER.img.pvBits], ecx, edx

 	lea edx, [ebx+PLAYER.wpn]
    xor ecx, ecx
  @@:  
 	GetDimIndexAddr edx, WEAPON, ecx
	stdcall wpn_init, eax, [pWpnType], ebx, [wpnDirect]
	inc ecx
	cmp ecx, [edx+WPNARR.length]
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
	stdcall _deleteDIB, [ebx+PLAYER.img.dib], [ebx+PLAYER.img.memDC]
  	ret
endp

proc plr_TimeProc uses eax ebx ecx edx, uID, uMsg, pPlr, dw1, dw2
	local wpnDirect dd ?

	mov ebx, [pPlr]


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
		movzx ecx, [ebx+PLAYER.wpnDirect]
		mov [wpnDirect], ecx

		lea edx, [ebx+PLAYER.wpn]			
		xor ecx, ecx
	  @@:
		GetDimFieldAddr edx, WEAPON, ecx, exist
		.if byte [eax]=0
			GetDimIndexAddr edx, WEAPON, ecx
			stdcall wpn_fire, eax, [ebx+PLAYER.p.x], [ebx+PLAYER.p.y], [ebx+PLAYER.size.x], [ebx+PLAYER.size.x], [wpnDirect]
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
	stdcall inf_drawHealth, infout, ebx
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

proc plr_hit uses ebx ecx, pPlr:DWORD, pWpn:DWORD
	mov ebx, [pPlr]
	mov ecx, [pWpn]
	stdcall wpn_hit, ecx
	mov ax, [ecx+WEAPON.damage]
	sub [ebx+PLAYER.health], ax
	cmp word [ebx+PLAYER.health], 0
	jg @F
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