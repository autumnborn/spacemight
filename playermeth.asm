; player unit methods
proc plr_init, plr:DWORD



endp

proc plr_draw, plr:DWORD
  mov eax, [plr]
  invoke SetPixel, [hdc], [eax+PLAYER.p.x], [eax+PLAYER.p.y], 0FFFFFFh
  ret
endp

proc plr_command, pPlr:DWORD
	

endp