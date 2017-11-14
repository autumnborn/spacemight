
proc inf_healthDraw uses ebx ecx edx, pPlr:DWORD, pRect:DWORD, color:DWORD
	invoke BeginPaint, [hwnd], paint
	mov ebx, [pRect]
	mov ecx, [ebx+RECT.right]
	sub ecx, [ebx+RECT.left]
	mov edx, [ebx+RECT.bottom]
	sub edx, [ebx+RECT.top]
	invoke BitBlt, [hdc], [ebx+RECT.left], [ebx+RECT.top], ecx, edx, [screen.memDC], [ebx+RECT.left], [ebx+RECT.top], SRCCOPY
	
	mov ebx, [pPlr]
	movzx ebx, word [ebx+PLAYER.health]
	stdcall _val2dsu, ebx, szBuff
	invoke SetTextColor, [hdc], [color]
	invoke SetBkMode, [hdc], TRANSPARENT
	invoke DrawText, [hdc], szBuff, -1, [pRect], DT_CALCRECT
	invoke DrawText, [hdc], szBuff, -1, [pRect], DT_NOCLIP
	invoke EndPaint, [hwnd], paint
	ret
endp
