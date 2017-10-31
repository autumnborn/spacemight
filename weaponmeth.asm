; weapon methods
proc wpn_init uses ebx ecx, pWpn:DWORD, pParent:DWORD, type:BYTE, direct:BYTE
	mov ebx, [pWpn]
	mov ecx, [pParent]
	mov [ebx+WEAPON.parent], ecx
	mov cl, [type]
	mov [ebx+WEAPON.type], cl
	mov cl, [direct]
	mov [ebx+WEAPON.direct], cl
	
	.if [type]=W_SIMPLE
		mov [ebx+WEAPON.size.x], 5
		mov [ebx+WEAPON.size.y], 10
	.elseif [type]=W_DOUBLE
		mov [ebx+WEAPON.size.x], 10
		mov [ebx+WEAPON.size.y], 10
	.endif	

	ret
endp

proc wpn_draw uses ebx ecx, pWpn:DWORD
	mov ebx, [pWpn]
	invoke SetPixel, [hdc], [ebx+WEAPON.p.x], [ebx+WEAPON.p.y], 0FF0000h
	ret
endp

proc wpn_fire uses ebx ecx, pWpn:DWORD, startX:DWORD, startY:DWORD
	mov ebx, [pWpn]
	mov ecx, [startX]
	mov [ebx+WEAPON.p.x], ecx
	mov ecx, [startY]
	mov [ebx+WEAPON.p.y], ecx
	invoke timeSetEvent, WPN_TIMER_DELAY, WPN_TIMER_RESOL, wpn_TimeProc, ebx, TIME_PERIODIC
	mov [ebx+WEAPON.timer], eax
	ret
endp

proc wpn_destructor uses ebx, pWpn:DWORD
	mov ebx, [pWpn]
	mov eax, [ebx+WEAPON.timer]
	test eax, eax
	jz @F
	invoke timeKillEvent, eax
	mov [ebx+WEAPON.timer], 0
  @@:
  	ret
endp

proc wpn_TimeProc uses ebx, uID, uMsg, dwUser, dw1, dw2
	mov ebx, [dwUser]
	.if [ebx+WEAPON.direct]<0
		dec [ebx+WEAPON.p.y]
	.else
		inc [ebx+WEAPON.p.y]
	.endif		
	.if [ebx+WEAPON.p.y] > SCR_HEIGHT | [ebx+WEAPON.p.y] < 0
		stdcall wpn_destructor, ebx
	.endif
	stdcall wpn_draw, ebx 
	ret
endp
