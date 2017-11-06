; world control unit methods
if DBG
	nop
	db "worldctrlmeth"
	nop
end if

proc wdc_init uses ebx, pWdc:DWORD
	mov ebx, [pWdc]
	lea edx, [ebx+WORLDCTRL.enemies]
    xor ecx, ecx
  @@:  
 	GetDimIndexAddr edx, ENEMY, ecx
	stdcall enm_init, eax, player
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
	lea eax, [ebx+WORLDCTRL.enemies.i0]
	stdcall enm_update, eax
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