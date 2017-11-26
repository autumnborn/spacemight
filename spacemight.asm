format PE GUI 4.0
entry start

include 'win32a.inc'
include 'macro\if.inc'
include 'equates.inc'
include 'macro.inc'
include 'structures.inc'

section '.rdata' data readable
	include 'objdesc.inc'

section '.data' data readable writeable
	szWndClass db "SpaceMightWindow", 0
	szWndTitle db "Space Might", 0
	dwWndStyle dd WS_OVERLAPPEDWINDOW+WS_VISIBLE-WS_THICKFRAME-WS_MAXIMIZEBOX
	wc WNDCLASS 0, WindowProc, 0, 0, 0, 0, 0, COLOR_BTNFACE+1, 0, szWndClass
	screen DIBINFO ?, ?, ?, <<sizeof.BITMAPINFOHEADER, SCR_WIDTH, SCR_HEIGHT, 1, 32>>
	errmsg db "Error", 0
	szStart db "START", 0
	szLevel db "LEVEL ", 0
	szPause db "PAUSE", 0
	szEnd db "Congratulations, you did it!", 0Dh, 0Ah, "The End", 0
	szOver db "GAME OVER", 0

section '.bss' data readable writeable
	hwnd dd ?
	msg MSG
	hdc dd ?
	rndSeed dd ?
	paused db ?
	paint PAINTSTRUCT
	player PLAYER
	enemy ENEMY
	wdctrl WORLDCTRL
	infout INFOUT
	anim ANIM
	splash SPLASH
	szBuff db 255 dup(0)

section '.code' code readable executable
  	
  start:
  	include 'form.asm'

  	stdcall _configWnd
    stdcall _createDIB, screen.bmInfo, screen.pvBits, screen.memDC
    mov [screen.dib], eax
    ; Player start position
  	mov [player.p.x], 304
  	mov [player.p.y], 224
 
  	stdcall plr_init, player, plrtype
  	stdcall inf_init, infout
  	stdcall wdc_init, wdctrl, player
  	stdcall anim_init, anim, atExp1

  	stdcall spl_show, splash, SPL_MAIN

  	stdcall _bgPaint
  	stdcall _pause, szStart, 300, 220, 0FFFFFFh

  .msg_loop:
    invoke GetMessage, msg, NULL, 0, 0
    cmp eax,0
    je exit

    stdcall _control

    invoke TranslateMessage, msg
    invoke DispatchMessage, msg
    jmp .msg_loop


  exit:
  	stdcall plr_destructor, player
  	stdcall wdc_destructor, wdctrl
  	stdcall inf_destructor, infout
  	stdcall anim_destructor, anim
   	stdcall _deleteDIB, [screen.dib], [screen.memDC]
  	invoke ExitProcess, 0

  	include 'formproc.asm'
  	include 'infout.asm'
  	include 'enemymeth.asm'
  	include 'playermeth.asm'
  	include 'weaponmeth.asm'
  	include 'worldctrlmeth.asm'
  	include 'animmeth.asm'
  	include 'splashmeth.asm'

	; Keyboard handler
	proc _control uses ebx ecx edx 

		invoke GetAsyncKeyState, VK_LEFT
		and eax, 8000h
		.if eax<>0
			mov al, -1
		.endif
		.if al <> [player.act.left]
			not [player.act.left]
		.endif

		invoke GetAsyncKeyState, VK_UP
		and eax, 8000h
		.if eax<>0
			mov al, -1
		.endif
		.if al <> [player.act.up]
			not [player.act.up]
		.endif

		invoke GetAsyncKeyState, VK_RIGHT
		and eax, 8000h
		.if eax<>0
			mov al, -1
		.endif
		.if al <> [player.act.right]
			not [player.act.right]
		.endif

		invoke GetAsyncKeyState, VK_DOWN
		and eax, 8000h
		.if eax<>0
			mov al, -1
		.endif
		.if al <> [player.act.down]
			not [player.act.down]
		.endif
			  
		invoke GetAsyncKeyState, VK_SPACE
		and eax, 8000h
		.if eax<>0
			mov al, -1
		.endif
		.if al <> [player.act.fire]
			not [player.act.fire]
		.endif

		invoke GetAsyncKeyState, VK_RETURN
		and eax, 8000h
		test eax, eax
		jz @F
		stdcall _pause, szPause, 300, 220, 0FF00h
	  @@:
	  
		ret
	endp

	; Restarts game
	proc _restart uses ecx
		stdcall plr_destructor, player
		stdcall wdc_destructor, wdctrl
		stdcall plr_init, player, plrtype
		stdcall wdc_init, wdctrl, player
		stdcall plr_wakeup, player
		stdcall wdc_wakeup, wdctrl
		ret
	endp

	; Set/Unset pause
	; pszText - ptr to string, which draws when pause sets.
	; If pszText is 0, then don't draw any text.
	; x, y - output coords.
	; color - text color
	proc _pause uses ecx edx, pszText:DWORD, x:DWORD, y:DWORD, color:DWORD
		.if ~[paused]
			stdcall plr_stop, player
			stdcall wdc_stop, wdctrl
			.if [pszText]<>0
				stdcall inf_drawText, infout, [pszText], [x], [y], [color]
			.endif
			not [paused]
			invoke Sleep, 500
		.else
			invoke Sleep, 250
			stdcall plr_wakeup, player
			stdcall wdc_wakeup, wdctrl
			stdcall _bgPaint
			not [paused]
		.endif
		ret
	endp
 
 	; Creates compatible device context and DIB section
	; bmInfo - ptr to BITMAPINFO
	; pvBits - ptr to var for ptr to bitmap bits
	; memDC  - ptr to var for handle to a memory device context
	; return dib-handle, pvBits - ptr to bitmap bits, memDC - handle to a memory device context
	proc _createDIB uses ebx, bmInfo:DWORD, pvBits:DWORD, memDC:DWORD
		invoke CreateCompatibleDC, [hdc]
		mov ebx, [memDC]
		mov [ebx], eax
		push ebx
		invoke CreateDIBSection, [hdc], [bmInfo], DIB_RGB_COLORS, [pvBits], NULL, NULL    
		pop ebx
		push eax
		invoke SelectObject, [ebx], eax
		pop eax
		ret
	endp

	; Deletes compatible DC
	; dib - DIB handle returned _createDIB
	proc _deleteDIB uses ebx, dib:DWORD, memDC:DWORD
		invoke DeleteObject, [dib]
		invoke DeleteDC, [memDC]
		ret
	endp 

	; Calls destructor for all instances of WEAPON (WPNARR)
	proc _delWpns uses ebx ecx, pWpnArr: DWORD
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

	; Random number from 0 to top-1
	proc _rnd uses ecx edx, top:DWORD
		mov     eax,[rndSeed]
		; if rndSeed = 0
		or      eax,eax
		jnz     @F
		; init rnd gen
		rdtsc
		xor     eax,edx
		mov     [rndSeed],eax
	  @@:
		xor     edx,edx
		mov     ecx,127773
		div     ecx
		mov     ecx,eax
		mov     eax,16807
		mul     edx
		mov     edx,ecx
		mov     ecx,eax
		mov     eax,2836
		mul     edx
		sub     ecx,eax
		xor     edx,edx
		mov     eax,ecx
		mov     [rndSeed],ecx
		mov     ecx,100000
		div     ecx
		mov eax, edx
		xor edx, edx
		div [top]
		mov eax, edx
		ret
	endp

	;	Cover for convert v2d unsigned
	;	iVal - dword value
	;	pBuf - dword ptr to  str buffer
	proc _val2dsu uses eax ebx ecx edx esi edi, iVal:DWORD, pBuf:DWORD
		mov eax, [iVal]
		mov edi, [pBuf]
		call _v2d
		call _strRev
		ret
	endp

	;	Cover for convert v2d signed
	;	iVal - dword value
	;	pBuf - dword ptr to str buffer
	proc _val2dss uses eax ebx ecx edx esi edi, iVal:DWORD, pBuf:DWORD
		mov eax, [iVal]
		mov edi, [pBuf]
		xor edx, edx	;edx -> sign: 0 - p, 1 - n
		mov ecx, eax
		rol ecx, 1
		test cl, 1
		jz @F
		inc edx
		xor ecx, ecx
		xchg eax, ecx
		sub eax, ecx

	  @@:
		push edx
		call _v2d
		pop edx
		test edx, edx
		jz @F
		mov [edi+ecx], byte "-"

	  @@:
		call _strRev
		ret 
	endp 

	; Converts value to dec string
	; eax - value, edi - ptr to result buffer
	; Note: num-chars places from right to left
	proc _v2d
		xor ecx, ecx

	  @@:
		test eax, eax
		jz @F	
		xor edx, edx
		mov ebx, 0Ah
		div ebx
		add dl, 30h
		mov [edi+ecx], dl
		inc ecx
		jmp @B

	  @@:
		test ecx, ecx
		jnz @F
		mov [edi], byte 30h
		inc ecx
	  @@:
		mov [edi+ecx], word 0	
		ret
	endp

	; Reverts null terminated string
	; edi - ptr to sz string buffer
	proc _strRev
		push edi
		mov esi, edi

	  @@:
		mov al, [esi]
		test al, al
		jz @F
		inc esi
		jmp @B

	  @@:
		dec esi
		cmp esi, edi
		jbe @F
		mov al, [esi]
		xchg al, [edi]
		mov [esi], al
		inc edi
		jmp @B
	  @@:
		pop edi
		ret
	endp

	; Concatinates null-terminated strings
	proc _concat uses eax esi edi, psz1:DWORD, psz2:DWORD
		mov esi, [psz1]

	  @@:	
		lodsb
		test al, al
		jnz @B
		dec esi
		xchg edi, esi
		mov esi, [psz2]

	  @@:
		lodsb
		stosb
		test al, al
		jnz @B
		stosb
		ret
	endp

	; Counts ansi string length includes last null-byte
	proc _countSz uses esi, psz:DWORD
		mov esi, [psz]

	  @@:
		lodsb
		test al, al
		jnz @B	
		sub esi, [psz]
		mov eax, esi
		ret
	endp

section '.idata' import data readable
	include 'imports.inc'





