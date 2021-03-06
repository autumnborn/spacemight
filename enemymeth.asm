; enemy unit methods
if DBG
	nop
	db "enemymeth"
	nop
end if

; Constructor
; pType - pointer to UNITTYPE
proc enm_init uses ebx ecx edx, pEnm:DWORD, pType:DWORD, pPlr: DWORD
	locals
		pWpnType dd ?
		wpnDirect dd ?
	endl

	mov ebx, [pEnm]

	mov [ebx+ENEMY.isAnim], 0
	mov [ebx+ENEMY.animDelay], ENM_ANIM_DELAY_T

	mov eax, [pPlr]
	mov [ebx+ENEMY.pPlayer], eax

	mov eax, [pType]
    mov [ebx+ENEMY.pType], eax
	mov ecx, [eax+UNITTYPE.pWpnType]
	mov [pWpnType], ecx 

	movzx ecx, byte [eax+UNITTYPE.wpnDirect]
	mov [ebx+ENEMY.wpnDirect], cl
	mov [wpnDirect], ecx

	mov cl, [eax+UNITTYPE.type]
    mov [ebx+ENEMY.type], cl

	mov cl, [eax+UNITTYPE.speed]
    mov [ebx+ENEMY.speed], cl

    mov cx, [eax+UNITTYPE.health]
    mov [ebx+ENEMY.health], cx
	
	mov ecx, [eax+UNITTYPE.size.x]
	mov [ebx+ENEMY.size.x], ecx
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biWidth], ecx
	
	mov ecx, [eax+UNITTYPE.size.y]
	mov [ebx+ENEMY.size.y], ecx
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biHeight], ecx
	
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biSize], sizeof.BITMAPINFOHEADER
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biPlanes], 1
	mov [ebx+ENEMY.img.bmInfo.bmiHeader.biBitCount], 32

	lea eax, [ebx+ENEMY.img.bmInfo]
	lea ecx, [ebx+ENEMY.img.pvBits]
	lea edx, [ebx+ENEMY.img.memDC]
	stdcall _createDIB, eax, ecx, edx
	mov [ebx+ENEMY.img.dib], eax


    mov eax, [pType]
    mov ecx, [eax+UNITTYPE.pimg]
	mov edx, [ebx+ENEMY.size.x]
    imul edx, [ebx+ENEMY.size.y]
    IMG_MEMCOPY [ebx+ENEMY.img.pvBits], ecx, edx


 	lea edx, [ebx+ENEMY.wpn]
    xor ecx, ecx
  @@:  
 	GetDimIndexAddr edx, WEAPON, ecx
	stdcall wpn_init, eax, [pWpnType], ebx, [wpnDirect]
	inc ecx
	cmp ecx, [edx+WPNARR.length]
	jnz @B
	ret
endp

; Clear screen at current enemy position
proc enm_clear uses ebx ecx edx, pEnm:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pEnm]
    mov ecx, [ebx+ENEMY.p.x]
    mov edx, [ebx+ENEMY.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+ENEMY.size.x], [ebx+ENEMY.size.y], [screen.memDC], ecx, edx, SRCCOPY
	invoke EndPaint, [hwnd], paint
	ret
endp

; Draws enemy at current position
proc enm_draw uses ebx ecx edx, pEnm:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pEnm]
    mov ecx, [ebx+ENEMY.p.x]
    mov edx, [ebx+ENEMY.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+ENEMY.size.x], [ebx+ENEMY.size.y], [ebx+ENEMY.img.memDC], 0, 0, SRCCOPY
	invoke EndPaint, [hwnd], paint
	ret
endp

; Stops enemy updating:
; reset isExist flag
proc enm_stop uses ebx, pEnm:DWORD
	mov ebx, [pEnm]
	mov al, [ebx+ENEMY.isExist]
	test al, al
	jz @F
	mov byte [ebx+ENEMY.isExist], 0
	mov eax, [ebx+ENEMY.pType]
	mov ax, [eax+UNITTYPE.health]
	mov [ebx+ENEMY.health], ax
  @@:
	ret
endp

; ~
proc enm_destructor uses ebx ecx edx, pEnm:DWORD
	mov ebx, [pEnm]
	mov [ebx+ENEMY.isExist], 0
	
	lea eax, [ebx+ENEMY.wpn]
	stdcall _delWpns, eax

	stdcall _deleteDIB, [ebx+ENEMY.img.dib], [ebx+ENEMY.img.memDC]
  	ret
endp

; Updates enemy
proc enm_update uses eax ebx, pEnm:DWORD
	mov ebx, [pEnm]
	
	.if [ebx+ENEMY.isAnim]
		stdcall enm_die, ebx
		jmp @F
	.endif

	stdcall enm_clear, ebx
	stdcall enm_behavior, ebx
	stdcall enm_draw, ebx
  @@:
	ret
endp

; Updates existed instances of WEAPON
proc enm_updateWpns uses ebx ecx edx, pEnm:DWORD
	mov ebx, [pEnm]
 	lea edx, [ebx+ENEMY.wpn]
    xor ecx, ecx
  
  @@:  
  	GetDimFieldAddr edx, WEAPON, ecx, isExist
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

; Implements enemy behavior:
; move, fire
proc enm_behavior uses ebx ecx edx, pEnm:DWORD
	mov ebx, [pEnm]
	
	movzx edx, byte [ebx+ENEMY.speed]
	stdcall plr_getY, [ebx+ENEMY.pPlayer]
	lea ecx, [ebx+ENEMY.p.y]
	.if dword [ecx] > SCR_HEIGHT
		stdcall enm_stop, ebx
		jmp .exit
	.endif 
	
	add dword [ecx], edx
	cmp [ecx], eax
	je .exit

	;enemies shoots from backyard, if enemy type <> 1 
	jb .direct0
	cmp [ebx+ENEMY.type], 1
	jz .exit
	mov [ebx+ENEMY.wpnDirect], WPN_DIRECT_U	
	jmp @F

  .direct0:
	mov [ebx+ENEMY.wpnDirect], WPN_DIRECT_D
	;////

  @@:
	stdcall plr_getX, [ebx+ENEMY.pPlayer]
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

; Shot
proc enm_fire uses ebx ecx edx, pEnm:DWORD
	local wpnDirect dd ?
	
	mov ebx, [pEnm]

	.if ~[ebx+ENEMY.isFireSleep]
		movzx ecx, [ebx+ENEMY.wpnDirect]
		mov [wpnDirect], ecx

		lea edx, [ebx+ENEMY.wpn]
		xor ecx, ecx
	  @@:
		GetDimFieldAddr edx, WEAPON, ecx, isExist
		.if byte [eax]=0
			GetDimIndexAddr edx, WEAPON, ecx
			stdcall wpn_fire, eax, [ebx+ENEMY.p.x], [ebx+ENEMY.p.y], [ebx+ENEMY.size.x], [ebx+ENEMY.size.y], [wpnDirect]
			push ebx
			invoke timeSetEvent, ENM_FIRE_DELAY, ENM_FIRE_RESOL, enm_TimeFireProc, ebx, TIME_ONESHOT
			pop ebx
			test eax, eax
			setne [ebx+ENEMY.isFireSleep]
			jmp @F
		.endif
		inc ecx
		cmp ecx, [edx+WPNARR.length]
		jnz @B 

	.endif	
  @@:
  	ret
endp

; Fire delay expiration callback
proc enm_TimeFireProc uses eax ebx ecx edx, uID, uMsg, pEnm, dw1, dw2
	mov ebx, [pEnm]
	mov byte [ebx+ENEMY.isFireSleep], 0
	invoke timeKillEvent, [uID]
	ret
endp

; Collision with player weapon handler
; pWpn pointer to player(!) WEAPON instance
; return points, if died, and null otherwise 
proc enm_hit uses ebx ecx, pEnm:DWORD, pWpn:DWORD
	mov ebx, [pEnm]

	cmp byte [ebx+ENEMY.isAnim], 0
	je @F
	xor eax, eax
	jmp .exit

  @@:
	mov ecx, [pWpn]
	stdcall wpn_hit, ecx
	mov ax, [ecx+WEAPON.damage]
	sub [ebx+ENEMY.health], ax
	xor eax, eax
	cmp word [ebx+ENEMY.health], 0
	jg .exit
	
	mov [ebx+ENEMY.isAnim], -1
	or eax, 10

  .exit: 
	ret
endp

; boom
proc enm_die uses eax ebx ecx edx, pEnm:DWORD
	mov ebx, [pEnm]

	; direct call
	mov ax, [ebx+ENEMY.health]
	test ax, ax
	jz @F
	mov [ebx+ENEMY.health], 0
	mov [ebx+ENEMY.isAnim], -1
	
  @@:
	dec [ebx+ENEMY.animDelay]
	mov al, [ebx+ENEMY.animDelay]
	test al, al
	jnz @F  

	mov [ebx+ENEMY.animDelay], ENM_ANIM_DELAY_T
	stdcall enm_clear, ebx
	
	mov edx, [ebx+ENEMY.pType]
	mov edx, [edx+UNITTYPE.pAnim]
	; align x
	GetAlign [ebx+ENEMY.size.x], [edx+ANIM.size.x], [ebx+ENEMY.p.x]
	mov ecx, eax
	; align y
	GetAlign [ebx+ENEMY.size.y], [edx+ANIM.size.y], [ebx+ENEMY.p.y]
	
	stdcall anim_draw, edx, ecx, eax, [ebx+ENEMY.animFrmIdx]
	mov [ebx+ENEMY.animFrmIdx], eax
	test eax, eax
	jnz @F

	mov [ebx+ENEMY.isAnim], 0
	stdcall enm_stop, ebx
	stdcall enm_clear, ebx

  @@:
  	ret
endp
