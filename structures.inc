;
struct BITMAPINFO
	bmiHeader BITMAPINFOHEADER
	bmiColors dd 2 dup(0) 
ends

struct DIBINFO
	dib dd ?
	memDC dd ?
	pvBits dd ?
	bmInfo BITMAPINFO
ends

struct ACTIONFLAGS
	struct
		left db ?
		right db ?
		up db ?
		down db ?
	ends
	fire db ?
ends

struct WEAPON
	parent dd ?
	type db ?	
	damage dw ?
	direct db ?
	isExist db ?
	p POINT
	size POINT
	img DIBINFO
ends

ARRAY WPNARR, 10, WEAPON

struct PLAYER
	pType dd ?
	speed db ?
	weapon db ? ;(?)
	wpnDirect db ?
	health dw ?
	score dd ?
	timer dd ?
	fireSleep db ?
	p POINT
	size POINT
	act ACTIONFLAGS
	wpn WPNARR
	img DIBINFO
ends

struct ENEMY
	type db ?
	pType dd ?
	speed db ?
	weapon db ?
	wpnDirect db ?
	health dw ?
	isExist db ?
	fireSleep db ?
	isAnim db ?
	animDelay db ?
	animFrmIdx dd ?
	pPlayer dd ?
	p POINT
	size POINT
	wpn WPNARR
	img DIBINFO
ends

ARRAY ENMARR, 3, ENEMY

struct WORLDCTRL
	timer dd ?
	level db ?
	pPlayer dd ?
	enmDelay db ?
	enemies ENMARR
ends

struct UNITTYPE
	type db ?
	speed db ?
	pWpnType dd ?
	wpnDirect db ?
	health dw ?
	pimg dd ?
	size POINT
ends

struct WPNTYPE
	type db ?
	damage dw ?
	pimg dd ?
	size POINT	
ends

struct INFOUT
	rect RECT
	img DIBINFO
ends

struct ANIM
	frmCount dd ?
	frameW dd ?
	size POINT
	img DIBINFO
ends

struct ANIMTYPE
	frmCount dd ?
	pimg dd ?
	size POINT
ends