
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
   

    invoke BitBlt, [hdc], 0, 0, 640, 480, [screen.memDC], 0, 0, SRCCOPY

    ret
  endp