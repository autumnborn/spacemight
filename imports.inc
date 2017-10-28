library winmm, 'WINMM.DLL',\
	kernel32, 'kernel32.dll',\
	user32, 'USER32.DLL',\
	gdi32, 'GDI32.DLL'

include "api\kernel32.inc"
include "api\user32.inc"
include "api\gdi32.inc"

import winmm,\
	timeSetEvent, 'timeSetEvent',\
	timeKillEvent, 'timeKillEvent'
