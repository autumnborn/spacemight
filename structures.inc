;
struct BITMAPINFO
	bmiHeader BITMAPINFOHEADER
	bmiColors dd 2 dup(0) 
ends

struct SCRINFO
	dib dd ?
	memDC dd ?
	pvBits dd ?
	bmInfo BITMAPINFO
ends

struct ACTIONFLAGS
	left db ?
	right db ?
	up db ?
	down db ?
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
ends

struct PLAYER
	speed db ?
	weapon db ?
	health dw ?
	timer dd ?
	p POINT
	size POINT
	act ACTIONFLAGS
	wpn WEAPON
ends

struct ENEMY
	type db ?
	speed db ?
	weapon db ?
	health dw ?
	timer dd ?
	p POINT
	size POINT
	wpn WEAPON
ends

; Array of structure macroses
macro DIM var, size, type
{
  struct var#size
    rept size i:0 
    \{
      i\#i type
    \}
  ends
  var var#size ?
}

macro GetDimIndexAddr var, type, index
{
  mov eax, sizeof.#type
  ; mov ecx, index
  imul eax, index
  lea eax, [var+eax]
}

macro GetDimFieldAddr var, type, index, field
{
  mov eax, sizeof.#type
  ; mov ecx, index
  imul eax, index
  lea eax, [var+type#.#field+eax]
} 