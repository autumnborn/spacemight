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
    invoke MessageBox, NULL, szErr, NULL, MB_ICONERROR+MB_OK
    jmp exit

  @@:
    invoke CreateWindowEx, WS_EX_APPWINDOW, szWndClass, szWndTitle, [dwWndStyle], 50, 50, 640, 480, 0, 0, [wc.hInstance], 0
    test eax, eax
    jnz @F
    invoke MessageBox, NULL, szErr, NULL, MB_ICONERROR+MB_OK
    jmp exit
  
  @@:
    mov [hwnd], eax
    invoke GetWindowDC, eax
    test eax, eax
    jnz @F
    invoke MessageBox, NULL, szErr, NULL, MB_ICONERROR+MB_OK 
    jmp exit

  @@: 
    mov [hdc], eax