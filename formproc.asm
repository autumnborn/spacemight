
  proc WindowProc hwnd,wmsg,wparam,lparam
      push ebx esi edi
      cmp [wmsg],WM_DESTROY
      je .wmdestroy

      cmp [wmsg], WM_PAINT
      je .wmpaint

    .defwndproc:
      invoke DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
      jmp .finish

    .wmpaint:
       invoke BeginPaint, [hwnd], paint 
       stdcall _bgPaint
       invoke EndPaint, [hwnd], paint
       xor eax, eax
       jmp .finish

    .wmdestroy:
      invoke PostQuitMessage,0
      xor eax, eax

    .finish:
      pop edi esi ebx
      ret
  endp

  proc _bgPaint
   
    invoke CreateCompatibleDC, [hdc]
    mov [memDC], eax
    invoke CreateDIBSection, [hdc], bmInfo, DIB_RGB_COLORS, pvBits, NULL, NULL
    mov [dib], eax
    invoke SelectObject, [memDC], eax
    invoke BitBlt, [hdc], 0, 0, 640, 480, [memDC], 0, 0, SRCCOPY
    invoke DeleteObject, [dib]
    invoke ReleaseDC, NULL, [dib]
    
    ret
  endp