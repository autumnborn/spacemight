
  proc WindowProc hWnd, wMsg, wParam, lParam
      push ebx esi edi
      cmp [wMsg],WM_DESTROY
      je .wmdestroy

      cmp [wMsg], WM_PAINT
      je .wmpaint

    .defwndproc:
      invoke DefWindowProc,[hWnd],[wMsg],[wParam],[lParam]
      jmp .finish

    .wmpaint:
       invoke BeginPaint, [hWnd], paint 
       stdcall _bgPaint
       invoke EndPaint, [hWnd], paint
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