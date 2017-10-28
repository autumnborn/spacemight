struct PLAYER
	speed db ?
	weapon db ?
	health dw ?
ends
struct ENEMY
	type db ?
	speed db ?
	weapon db ?
	health dw ?
	timer dd ?
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
