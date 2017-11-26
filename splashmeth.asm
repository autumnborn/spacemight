; Splash screens methods
if DBG
	nop
	db "splash"
	nop
end if


; Shows splash screen
; splScr - specify what splash screen have to be shown
proc spl_show uses ebx ecx edx, pSpl:DWORD, splScr:BYTE
	mov ebx, [pSpl]

	mov [ebx+SPLASH.counter], 0
	mov al, [splScr]

	.if al=SPL_MAIN
		mov edx, spl_showMain
		mov [ebx+SPLASH.p.x], 160
		mov [ebx+SPLASH.p.y], 160
		lea ecx, [ebx+SPLASH.anim]
		stdcall anim_init, ecx, atLogo
	.else
		jmp .exit
	.endif
	
	invoke timeSetEvent, SPL_TIMER_DELAY, SPL_TIMER_RESOL, edx, ebx, TIME_PERIODIC 
	mov [ebx+SPLASH.timer], eax
  
  .exit:
	ret	
endp

; Shows main-splash animation
; (typical mmsystem TimeProc function)
proc spl_showMain uses ebx ecx edx, uID, uMsg, pSpl, dw1, dw2
	mov ebx, [pSpl]
	mov ecx, [ebx+SPLASH.counter]

	stdcall anim_drawNext, anim, [ebx+SPLASH.p.x], [ebx+SPLASH.p.y]
	test eax, eax
	jnz .exit

	lea eax, [ebx+SPLASH.anim] 
	stdcall anim_drawNext, eax, [ebx+SPLASH.p.x], [ebx+SPLASH.p.y]
	test eax, eax
	jnz .cont

	invoke timeKillEvent, [ebx+SPLASH.timer]
	lea eax, [ebx+SPLASH.anim]
	stdcall anim_destructor, eax
  	jmp .exit

  .cont:		
	mov eax, [ebx+SPLASH.anim.size.x]
	add [ebx+SPLASH.p.x], eax

  .exit:
	inc [ebx+SPLASH.counter]
	ret
endp