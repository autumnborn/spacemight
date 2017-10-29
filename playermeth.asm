; player unit methods
proc plr_init, pPlr:DWORD



endp

proc plr_draw, pPlr:DWORD
  mov eax, [pPlr]
  invoke SetPixel, [hdc], [eax+PLAYER.p.x], [eax+PLAYER.p.y], 0FFFFFFh
  ret
endp

proc plr_ctrl uses ebx ecx edx, pPlr:DWORD
  mov ebx, [pPlr]
  mov dl, [ebx+PLAYER.lrud]

  push ebx ecx edx
  invoke GetAsyncKeyState, VK_LEFT
  pop edx ecx ebx  
  
  rol eax, 1
  and al, 1
  mov cl, dl
  shr cl, 3
  and cl, 1
  cmp al, cl
  je @F
  shl al, 3
  and dl, 7
  xor dl, al
  mov [ebx+PLAYER.lrud], dl
@@:
  ret

endp
