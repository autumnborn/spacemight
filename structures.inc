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
	timer dd ?
	p POINT
	size POINT
	img DIBINFO
ends

ARRAY WPNARR, 10, WEAPON

struct PLAYER
	speed db ?
	weapon db ?
	health dw ?
	timer dd ?
	p POINT
	size POINT
	act ACTIONFLAGS
	wpn WPNARR
	img DIBINFO
ends

struct ENEMY
	type db ?
	speed db ?
	weapon db ?
	health dw ?
	timer dd ?
	p POINT
	size POINT
ends
