; world control unit methods
if DBG
	nop
	db "worldctrlmeth"
	nop
end if

proc wdc_init uses ebx, pWdc:DWORD
	mov ebx, [pWdc]
	mov byte [ebx+WORLDCTRL.enmdelay], WDC_ENM_DELAY
	lea edx, [ebx+WORLDCTRL.enemies]
    xor ecx, ecx
  @@:  
 	GetDimIndexAddr edx, ENEMY, ecx
	stdcall enm_init, eax, etype_1, player
	inc ecx
	cmp ecx, [edx+ENMARR.length]
	jnz @B
	ret
endp

proc wdc_wakeup uses ebx, pWdc:DWORD
	mov ebx, [pWdc]
	invoke timeSetEvent, ENM_TIMER_DELAY, ENM_TIMER_RESOL, wdc_TimeProc, ebx, TIME_PERIODIC 
	mov [ebx+WORLDCTRL.timer], eax
	ret
endp

proc wdc_TimeProc uses eax ebx ecx edx, uID, uMsg, dwUser, dw1, dw2
	mov ebx, [dwUser]
	dec byte [ebx+WORLDCTRL.enmdelay]
 
 	lea edx, [ebx+WORLDCTRL.enemies]
    xor ecx, ecx
  
  @@:  
  	GetDimFieldAddr edx, ENEMY, ecx, exist
  	mov al, byte [eax]
  	test al, al
  	jnz .upd

  	mov ebx, [dwUser]
  	mov al, [ebx+WORLDCTRL.enmdelay]
  	test al, al
  	jnz .cont
  	mov byte [ebx+WORLDCTRL.enmdelay], WDC_ENM_DELAY

 	GetDimIndexAddr edx, ENEMY, ecx
 	inc byte [eax+ENEMY.exist]
 	push edx
 	xchg edx, eax
	stdcall _rnd, SCR_WIDTH
	mov [edx+ENEMY.p.x], eax
	mov [edx+ENEMY.p.y], 0
	pop edx

  .upd:	
 	GetDimIndexAddr edx, ENEMY, ecx
	stdcall enm_update, eax
	stdcall wdc_enemyCollision, eax, player
	stdcall wdc_playerCollision, player, eax

  .cont:
  	GetDimIndexAddr edx, ENEMY, ecx
  	stdcall enm_updateWpns, eax	;weapon updating independent of enemy die 
	inc ecx
	cmp ecx, [edx+ENMARR.length]
	jnz @B
	ret
endp

proc wdc_destructor uses ebx, pWdc:DWORD
	mov ebx, [pWdc]

	mov eax, [ebx+WORLDCTRL.timer]
	test eax, eax
	jz @F
	invoke timeKillEvent, eax
	mov [ebx+WORLDCTRL.timer], 0

	ret
endp
nop
nop
db "collisions"
nop
nop
; Enemies collisions handle
proc wdc_enemyCollision uses eax ebx ecx edx, pEnm:DWORD, pPlr:DWORD
	locals 
		enmX1 dd ?
		enmX2 dd ?
		enmY1 dd ?
		enmY2 dd ?
	endl

	mov ebx, [pEnm]

	mov eax, [ebx+ENEMY.p.x]
	mov [enmX1], eax
	add eax, [ebx+ENEMY.size.x]
	mov [enmX2], eax
	mov eax, [ebx+ENEMY.p.y]
	mov [enmY1], eax
	add eax, [ebx+ENEMY.size.y]
	mov [enmY2], eax
	
	;player weapon collision
	mov eax, [pPlr]
 	lea edx, [eax+PLAYER.wpn]

    xor ecx, ecx

  @@:  
  	GetDimFieldAddr edx, WEAPON, ecx, exist
  	mov al, byte [eax]
  	test al, al
  	jz .skip

	GetDimFieldAddr edx, WEAPON, ecx, size.x
	mov ebx, [eax]
 	GetDimFieldAddr edx, WEAPON, ecx, p.x
	add ebx, [eax]
	mov eax, [eax]
	
	.if eax>[enmX2] | ebx<[enmX1]
		jmp .skip
	.endif

 	GetDimFieldAddr edx, WEAPON, ecx, size.y
	mov ebx, [eax]
 	GetDimFieldAddr edx, WEAPON, ecx, p.y
	add ebx, [eax]
	mov eax, [eax]

	.if eax>[enmY2] | ebx<[enmY1]
		jmp .skip
	.endif
	;collision exist
	GetDimIndexAddr edx, WEAPON, ecx
	stdcall enm_hit, [pEnm], eax
	test eax, eax
	jz .skip
	push edx
	mov edx, [pPlr]
	lea edx, [edx+PLAYER.points]
	add [edx], eax
	pop edx

  .skip:	
	inc ecx
	cmp ecx, [edx+WPNARR.length]
	jnz @B
	

	ret
endp

; Player collisions handle
proc wdc_playerCollision uses eax ebx ecx edx, pPlr:DWORD, pEnm:DWORD
	locals 
		plrX1 dd ?
		plrX2 dd ?
		plrY1 dd ?
		plrY2 dd ?
	endl

	mov ebx, [pPlr]

	mov eax, [ebx+PLAYER.p.x]
	mov [plrX1], eax
	add eax, [ebx+PLAYER.size.x]
	mov [plrX2], eax
	mov eax, [ebx+PLAYER.p.y]
	mov [plrY1], eax
	add eax, [ebx+PLAYER.size.y]
	mov [plrY2], eax
	
	;enemy weapon collision
	mov eax, [pEnm]
 	lea edx, [eax+ENEMY.wpn]

    xor ecx, ecx

  @@:  
  	GetDimFieldAddr edx, WEAPON, ecx, exist
  	mov al, byte [eax]
  	test al, al
  	jz .skip

	GetDimFieldAddr edx, WEAPON, ecx, size.x
	mov ebx, [eax]
 	GetDimFieldAddr edx, WEAPON, ecx, p.x
	add ebx, [eax]
	mov eax, [eax]
	
	.if eax>[plrX2] | ebx<[plrX1]
		jmp .skip
	.endif

 	GetDimFieldAddr edx, WEAPON, ecx, size.y
	mov ebx, [eax]
 	GetDimFieldAddr edx, WEAPON, ecx, p.y
	add ebx, [eax]
	mov eax, [eax]

	.if eax>[plrY2] | ebx<[plrY1]
		jmp .skip
	.endif
	;collision exist
	GetDimIndexAddr edx, WEAPON, ecx
	stdcall plr_hit, [pPlr], eax

  .skip:	
	inc ecx
	cmp ecx, [edx+WPNARR.length]
	jnz @B
	

	ret
endp