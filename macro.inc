; Arrays of structure macroses
macro ARRAY var, size, type
{
  struct var 
    rept size idx:0 
    \{
      i\#idx type
    \}
    length dd size-1
  ends
}

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

; Memory copy
macro IMG_MEMCOPY pDest, pSrc, bCount
{
	local beginl, chk
    
    mov edi, pDest
    mov esi, pSrc
 	
  beginl:
    lodsd
    test al, al
  	jnz @F
  	add edi, 4
  	jmp chk
  @@:	
    ror eax, 8 ;argb to rgba
    stosd
  chk:  
    dec bCount
    test bCount, bCount
    jnz beginl
  	  
}