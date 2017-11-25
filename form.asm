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
    invoke CreateWindowEx, WS_EX_APPWINDOW, szWndClass, szWndTitle, [dwWndStyle], 50, 50, 640, 480, 0, 0, [wc.hInstance], 0

    test eax, eax
    jne @F
    invoke MessageBox, 0, errmsg, errmsg, MB_OKCANCEL
    jmp exit
  
  @@:
    mov [hwnd], eax
    invoke GetWindowDC, eax
    mov [hdc], eax
