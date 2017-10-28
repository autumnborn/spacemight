
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

    cmp eax,0
    jne @F
    invoke MessageBox, 0, errmsg, errmsg, MB_OKCANCEL
    jmp exit
  @@:
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

    .defwndproc:
      invoke DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
      jmp .finish

    .wmdestroy:
      invoke PostQuitMessage,0
      mov eax,0

    .finish:
      pop edi esi ebx
      ret
  endp
