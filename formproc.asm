
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
    invoke BitBlt, [hdc], 0, 0, SCR_WIDTH, SCR_HEIGHT, [screen.memDC], 0, 0, SRCCOPY
    ret
  endp

  proc _configWnd
    locals
      p POINT 0,0
      r RECT 0,0,0,0
    endl

    lea eax, [p]
    invoke ClientToScreen, [hwnd], eax
    lea eax, [r]
    invoke GetWindowRect, [hwnd], eax
    mov eax, [r.left]
    sub [p.x], eax
    mov eax, [r.top]
    sub [p.y], eax
    invoke OffsetViewportOrgEx, [hdc], [p.x], [p.y], 0
    
    mov eax, [p.x]
    mov ebx, [p.y]
    add ebx, eax ;+border
    shl eax, 1   ;border*2
    add eax, SCR_WIDTH    
    add ebx, SCR_HEIGHT
    invoke MoveWindow, [hwnd], [r.left], [r.top], eax, ebx

    ret
  endp