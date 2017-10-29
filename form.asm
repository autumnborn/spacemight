    ;
    invoke GetModuleHandle,0
    mov [wc.hInstance],eax
    invoke LoadIcon,0,IDI_APPLICATION
    mov [wc.hIcon],eax
    invoke LoadCursor,0,IDC_ARROW
    mov [wc.hCursor],eax
    invoke RegisterClass,wc

    test eax,eax
    jnz @F
    invoke MessageBox, 0, errmsg, errmsg, MB_OKCANCEL
    jmp exit

  @@:
    invoke CreateWindowEx, WS_EX_APPWINDOW, wClass, wTitle, WS_OVERLAPPEDWINDOW+WS_VISIBLE, 50, 50, 640, 480, 0, 0, [wc.hInstance], 0

    test eax, eax
    jne @F
    invoke MessageBox, 0, errmsg, errmsg, MB_OKCANCEL
    jmp exit
  
  @@:
    invoke GetWindowDC, eax
    mov [hdc], eax

  .msg_loop:
    invoke GetMessage, msg, NULL, 0, 0
    cmp eax,0
    je exit

    invoke TranslateMessage, msg
    invoke DispatchMessage, msg

    jmp .msg_loop


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