; player unit methods
proc plr_init uses ebx, pPlr:DWORD

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
