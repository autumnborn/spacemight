; player unit methods
proc plr_init uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	mov [ebx+PLAYER.size.x], 32
	mov [ebx+PLAYER.size.y], 32
	;mov [ebx+PLAYER.weapon], W_SIMPLE
	;mov [ebx+PLAYER.wpn], W_SIMPLE
	lea eax, [ebx+PLAYER.wpn]
	stdcall wpn_init, eax, ebx, W_SIMPLE, -1
	ret
endp

proc plr_draw uses ebx, pPlr:DWORD
	mov ebx, [pPlr]
	invoke SetPixel, [hdc], [ebx+PLAYER.p.x], [ebx+PLAYER.p.y], 0FFFFFFh
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
	mov eax, [ebx+PLAYER.timer]
	test eax, eax
	jz @F
	invoke timeKillEvent, eax
	mov [ebx+PLAYER.timer], 0
  @@:
  	ret
endp

proc plr_TimeProc uses ebx, uID, uMsg, dwUser, dw1, dw2
	mov ebx, [dwUser]

	.if [ebx+PLAYER.act.left]<>0
		dec [ebx+PLAYER.p.x] 
	.endif 

	.if [ebx+PLAYER.act.right]<>0
		inc [ebx+PLAYER.p.x] 
	.endif
	
	.if [ebx+PLAYER.act.up]<>0
		dec [ebx+PLAYER.p.y] 
	.endif 
	
	.if [ebx+PLAYER.act.down]<>0
		inc [ebx+PLAYER.p.y] 
	.endif

	.if [ebx+PLAYER.act.fire]<>0
		.if [ebx+PLAYER.wpn.timer]=0 
			lea eax, [ebx+PLAYER.wpn]
			stdcall wpn_fire, eax, [ebx+PLAYER.p.x], [ebx+PLAYER.p.y] 
		.endif
	.endif


	stdcall plr_draw, ebx

	ret
endp













; proc plr_ctrl uses ebx ecx edx, pPlr:DWORD
;   mov ebx, [pPlr]
;   mov dl, [ebx+PLAYER.lrud]

;   push ebx ecx edx
;   invoke GetAsyncKeyState, VK_LEFT
;   pop edx ecx ebx  
  
;   rol eax, 1
;   and al, 1
;   mov cl, dl
;   shr cl, 3
;   and cl, 1
;   cmp al, cl
;   je @F
;   shl al, 3
;   and dl, 7
;   xor dl, al
;   mov [ebx+PLAYER.lrud], dl
; @@:
;   ret

; endp
