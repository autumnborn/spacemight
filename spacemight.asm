format PE GUI 4.0
entry start

include 'win32a.inc'
include 'structures.asm'

section '.data' data readable writeable
	wClass db "SpaceMightWindow", 0
	wTitle db "Space Might", 0
	wc WNDCLASS 0,WindowProc,0,0,0,0,0,COLOR_BTNFACE+1,0,wClass
	hwnd dd ?
	msg MSG
	hdc dd ?
	dib dd ?
	memDC dd ?
	pvBits dd ?
	bmInfo BITMAPINFO <sizeof.BITMAPINFOHEADER, 640, 480, 1, 32>
	paint PAINTSTRUCT
	player PLAYER
	errmsg db "Error", 0
	DIB_RGB_COLORS = 0

section '.code' code readable executable
  start:
  	include 'form.asm'

  .msg_loop:
    invoke GetMessage, msg, NULL, 0, 0
    cmp eax,0
    je exit

    invoke TranslateMessage, msg
    invoke DispatchMessage, msg
    jmp .msg_loop


  exit:
  	invoke ExitProcess, 0

  	include 'formproc.asm'

section '.idata' import data readable
	include 'imports.inc'





