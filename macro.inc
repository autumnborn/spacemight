; Arrays of structure macroses
macro ARRAY var, size, type
{
  struct var 
    rept size idx:0 
    \{
      i\#idx type
    \}
    length dd size
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

; Gets array index address
macro GetDimIndexAddr var, type, index
{
  mov eax, sizeof.#type
  imul eax, index
  lea eax, [var+eax]
}

; Gets array field address
macro GetDimFieldAddr var, type, index, field
{
  mov eax, sizeof.#type
  imul eax, index
  lea eax, [var+type#.#field+eax]
} 

; Memory copy
macro MEMCOPY pDest, pSrc, bCount
{
    mov edi, pDest
    mov esi, pSrc

  @@:
    lodsb
    stosb
    dec bCount
    test bCount, bCount
    jnz @B
}

; Memcopy for images
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

; Gets image aligned coord
macro GetAlign size1, size2, coord
{
  mov eax, #size1
  sub eax, #size2
  shr eax, 1
  add eax, #coord
} 