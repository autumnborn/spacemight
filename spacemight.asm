format PE GUI 4.0
entry start

include 'win32a.inc'
include 'structures.asm'

section '.data' data readable writeable
	wClass db "SpaceMightWindow", 0
	wTitle db "Space Might", 0
	wc WNDCLASS 0,WindowProc,0,0,0,0,0,COLOR_BTNFACE+1,0,wClass
	msg MSG
	player PLAYER
	errmsg db "Error", 0

section '.code' code readable executable
  start:
  	include 'form.asm'


  exit:
  	invoke ExitProcess, 0


section '.idata' import data readable
	include 'imports.inc'





