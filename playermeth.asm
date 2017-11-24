; player unit methods
if DBG
	nop
	db "playermeth"
	nop
end if

; Constructor
; pType - pointer to UNITTYPE
proc plr_init uses ebx ecx edx, pPlr:DWORD, pType:DWORD
	locals
		pWpnType dd ?
		wpnDirect dd ?
	endl

	mov ebx, [pPlr]

	mov [ebx+PLAYER.isAnim], 0
	mov [ebx+PLAYER.animDelay], PLR_ANIM_DELAY_T

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

	mov [ebx+PLAYER.score], 0
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

; Clear screen at current player position
proc plr_clear uses ebx ecx edx, pPlr:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pPlr]
    
    mov ecx, [ebx+PLAYER.p.x]
    mov edx, [ebx+PLAYER.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+PLAYER.size.x], [ebx+PLAYER.size.y], [screen.memDC], ecx, edx, SRCCOPY

	invoke EndPaint, [hwnd], paint
	ret
endp

; Draws player at current position
proc plr_draw uses ebx ecx edx, pPlr:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pPlr]

    mov ecx, [ebx+PLAYER.p.x]
    mov edx, [ebx+PLAYER.p.y]
	invoke BitBlt, [hdc], ecx, edx, [ebx+PLAYER.size.x], [ebx+PLAYER.size.y], [ebx+PLAYER.img.memDC], 0, 0, SRCCOPY


	invoke EndPaint, [hwnd], paint
	ret
endp

; Runs player main timer
proc plr_wakeup uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	mov eax, [ebx+PLAYER.timer]
	test eax, eax
	jnz @F
	invoke timeSetEvent, PLR_TIMER_DELAY, PLR_TIMER_RESOL, plr_TimeProc, ebx, TIME_PERIODIC 
	mov [ebx+PLAYER.timer], eax
  @@:
	ret
endp

; Stops player main timer
proc plr_stop uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	mov eax, [ebx+PLAYER.timer]
	test eax, eax
	jz @F
	invoke timeKillEvent, eax
	mov [ebx+PLAYER.timer], 0
  @@:
	ret
endp

; ~
proc plr_destructor uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	
	stdcall plr_stop, ebx

	lea eax, [ebx+PLAYER.wpn]
	stdcall _delWpns, eax
	
	stdcall _deleteDIB, [ebx+PLAYER.img.dib], [ebx+PLAYER.img.memDC]
  	ret
endp

; Updates player by timer
; (typical mmsystem TimeProc function)
proc plr_TimeProc uses eax ebx ecx edx, uID, uMsg, pPlr, dw1, dw2
	local wpnDirect dd ?

	mov ebx, [pPlr]

	.if [ebx+PLAYER.isAnim]
		stdcall plr_die, ebx
		jmp .exit
	.endif

	.if dword [ebx+PLAYER.act.left]
		stdcall plr_clear, ebx
	.endif

	lea ecx, [ebx+PLAYER.p.x]
	lea edx, [ebx+PLAYER.p.y]

	.if [ebx+PLAYER.act.left]
		cmp dword [ecx], 0
		jng @F
		movzx eax, [ebx+PLAYER.speed] 
		sub dword [ecx], eax  
	  @@:
	.endif 

	.if [ebx+PLAYER.act.right]
		mov eax, [ebx+PLAYER.size.x]
		add eax, [ecx] 
		cmp eax, SCR_WIDTH
		jnl @F
		movzx eax, [ebx+PLAYER.speed]
		add dword [ecx], eax
	  @@:
	.endif
	
	.if [ebx+PLAYER.act.up]
		cmp dword [edx], 0
		jng @F
		movzx eax, [ebx+PLAYER.speed]
		sub dword [edx], eax
	  @@:	
	.endif 
	
	.if [ebx+PLAYER.act.down]
		mov eax, [ebx+PLAYER.size.y]
		add eax, [edx] 
		cmp eax, SCR_HEIGHT
		jnl @F
		movzx eax, [ebx+PLAYER.speed]
		add dword [edx], eax
	  @@:
	.endif


	.if [ebx+PLAYER.act.fire] & ~[ebx+PLAYER.fireSleep]
		movzx ecx, [ebx+PLAYER.wpnDirect]
		mov [wpnDirect], ecx

		lea edx, [ebx+PLAYER.wpn]			
		xor ecx, ecx
	  @@:
		GetDimFieldAddr edx, WEAPON, ecx, isExist
		.if byte [eax]=0
			GetDimIndexAddr edx, WEAPON, ecx
			stdcall wpn_fire, eax, [ebx+PLAYER.p.x], [ebx+PLAYER.p.y], [ebx+PLAYER.size.x], [ebx+PLAYER.size.x], [wpnDirect]
			push ebx
			invoke timeSetEvent, PLR_FIRE_DELAY, PLR_FIRE_RESOL, plr_TimeFireProc, ebx, TIME_ONESHOT
			pop ebx
			test eax, eax
			setne [ebx+PLAYER.fireSleep]
			jmp @F
		.endif
		inc ecx
		cmp ecx, [edx+WPNARR.length]
		jnz @B 
	  @@:
	.endif

	stdcall plr_draw, ebx
	stdcall plr_updateWpns, ebx

  .exit:
	stdcall inf_drawHealth, infout, ebx
	ret
endp

; Fire delay expiration callback
proc plr_TimeFireProc, uID, uMsg, pPlr, dw1, dw2
	mov ebx, [pPlr]
	mov byte [ebx+PLAYER.fireSleep], 0
	invoke timeKillEvent, [uID]
	ret
endp

; Updates instances of WEAPON with isExist flag
proc plr_updateWpns uses ebx ecx edx, pPlr:DWORD
	mov ebx, [pPlr]
 	lea edx, [ebx+PLAYER.wpn]
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
	cmp ecx, [edx+WPNARR.length] ; eq [ebx+PLAYER.wpn.length] 
	jnz @B	
	ret

endp

; Returns coordinate x
; (enm_behavior)
proc plr_getX uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	mov eax, [ebx+PLAYER.p.x]
	ret
endp

; Returns coordinate y
; (enm_behavior)
proc plr_getY uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	mov eax, [ebx+PLAYER.p.y]
	ret
endp

; Collision with enemy weapon handler
; pWpn - ptr to enemy(!) WEAPON instance
proc plr_hit uses ebx ecx, pPlr:DWORD, pWpn:DWORD
	mov ebx, [pPlr]

	cmp byte [ebx+PLAYER.isAnim], 0
	je @F
	xor eax, eax
	jmp .exit

  @@:
	mov ecx, [pWpn]
	stdcall wpn_hit, ecx
	mov ax, [ecx+WEAPON.damage]
	sub [ebx+PLAYER.health], ax
	cmp word [ebx+PLAYER.health], 0
	jg .exit
	mov [ebx+PLAYER.isAnim], -1
  
  .exit: 
	ret
endp

; boom
proc plr_die uses ebx ecx edx, pPlr:DWORD
	mov ebx, [pPlr]

	; direct call
	mov ax, [ebx+PLAYER.health]
	test ax, ax
	jz @F
	mov [ebx+PLAYER.health], 0
	mov [ebx+PLAYER.isAnim], -1

  @@:
	dec [ebx+PLAYER.animDelay]
	mov al, [ebx+PLAYER.animDelay]
	test al, al
	jnz @F  

	mov [ebx+PLAYER.animDelay], PLR_ANIM_DELAY_T
	stdcall plr_clear, ebx
	
	mov edx, [ebx+PLAYER.pType]
	mov edx, [edx+UNITTYPE.pAnim]
	; align x
	GetAlign [ebx+PLAYER.size.x], [edx+ANIM.size.x], [ebx+PLAYER.p.x]
	mov ecx, eax
	; align y
	GetAlign [ebx+PLAYER.size.y], [edx+ANIM.size.y], [ebx+PLAYER.p.y]

	stdcall anim_draw, edx, ecx, eax, [ebx+PLAYER.animFrmIdx]
	mov [ebx+PLAYER.animFrmIdx], eax
	test eax, eax
	jnz @F

	mov [ebx+PLAYER.isAnim], 0
	stdcall _restart
	stdcall _bgPaint
	stdcall _pause, szOver, 280, 220, 0FFh

  @@:	
	ret
endp
