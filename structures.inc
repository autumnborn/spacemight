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
	pParent dd ?		; pointer to parent instance
	type db ?			; number of enemy type (del?)
	damage dw ?			; weapon demage
	direct db ?			; direction
	isExist db ?		; existence flag
	p POINT				; weapon coords
	size POINT			; weapon size (uses for drawing and collisions checking)
	img DIBINFO			; image
ends

ARRAY WPNARR, 10, WEAPON

struct PLAYER
	pType dd ?			; pointer to UNITTYPE
	speed db ?			; moving pixels shift
	wpnDirect db ?		; weapon direction
	health dw ?			; player health
	score dd ?			; player score (uses to define level)
	timer dd ?			; timer handle
	isFireSleep db ?	; delay before next shot flag 
	isAnim db ?			; die animation running flag
	animDelay db ?		; animation next frame drawing delay (ticks)
	animFrmIdx dd ?		; animation frame index	store
	p POINT				; player coords
	size POINT			; player size (uses for drawing and collisions checking)
	act ACTIONFLAGS		; player action flags
	wpn WPNARR			; array of WEAPON instances
	img DIBINFO			; image
ends

struct ENEMY
	type db ?			; number of enemy type (enm_behavior) (del?)
	pType dd ?			; pointer to UNITTYPE
	speed db ?			; moving pixels shift
	wpnDirect db ?		; weapon direction
	health dw ?			; enemy health
	isExist db ?		; existence flag
	isFireSleep db ?	; delay before next shot flag	
	isAnim db ?			; die animation running flag
	animDelay db ?		; animation next frame drawing delay (ticks)
	animFrmIdx dd ?		; animation frame index	store
	pPlayer dd ?		; pointer to PLAYER instance
	p POINT				; enemy coords
	size POINT			; enemy size (uses for drawing and collisions checking)
	wpn WPNARR			; array of WEAPON instances
	img DIBINFO			; image
ends

ARRAY ENMARR, 3, ENEMY

struct WORLDCTRL
	timer dd ?			; timer handle
	level db ?			; current game level number
	pPlayer dd ?		; pointer to PLAYER instance
	enmDelay db ?		; next enemy delay
	enemies ENMARR		; array of ENEMY instances
ends

struct INFOUT			; information output
	rect RECT
	img DIBINFO
ends

struct ANIM
	pType dd ?			; pointer to ANIMTYPE
	frmCount dd ?		; number of frames
	frmNext dd ?		; number of next frame storage (anim_drawNext)
	size POINT			; frame size
	img DIBINFO			; animation sequence
ends

struct SPLASH
	timer dd ?			; timer handle
	counter dd ?		; tick counter
	p POINT ?			; coords
	anim ANIM ?			; instance of ANIM
ends


struct UNITTYPE
	type db ?
	speed db ?
	health dw ?
	pWpnType dd ?
	wpnDirect db ?
	pAnim dd ?
	pimg dd ?
	size POINT
ends

struct WPNTYPE
	type db ?
	damage dw ?
	pimg dd ?
	size POINT	
ends

struct ANIMTYPE
	frmCount dd ?
	pimg dd ?
	size POINT			; sequence img size
ends