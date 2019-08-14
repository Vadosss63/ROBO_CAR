;------------------------------------
;-  Generated Initialization File  --
;------------------------------------

$include (C8051F310.inc)

public  Init_Device

INIT SEGMENT CODE
    rseg INIT

; Peripheral specific initialization functions,
; Called from the Init_Device label
Reset_Sources_Init:
    mov  VDM0CN,    #080h
    clr  A                     ; Wait 100us for initialization
    djnz ACC,       $
    mov  RSTSRC,    #006h
    ret

PCA_Init:
    anl  PCA0MD,    #0BFh
    mov  PCA0MD,    #000h
    mov  PCA0CPL4,  #0FFh
    orl  PCA0MD,    #040h;
    mov  PCA0CPH4,  #0FFh
    ret

Timer_Init:
    mov  TCON,      #040h
    mov  TMOD,      #020h
    mov  CKCON,     #008h
    mov  TH1,       #096h
    ret

UART_Init:
    mov  SCON0,     #030h
    ret

Port_IO_Init:
    ; P0.0  -  Unassigned,  Open-Drain, Digital
    ; P0.1  -  Unassigned,  Open-Drain, Digital
    ; P0.2  -  Unassigned,  Open-Drain, Digital
    ; P0.3  -  Unassigned,  Push-Pull,  Digital
    ; P0.4  -  TX0 (UART0), Push-Pull,  Digital
    ; P0.5  -  RX0 (UART0), Open-Drain, Digital
    ; P0.6  -  Unassigned,  Open-Drain, Digital
    ; P0.7  -  Unassigned,  Open-Drain, Digital

    ; P1.0  -  Unassigned,  Open-Drain, Digital
    ; P1.1  -  Unassigned,  Open-Drain, Digital
    ; P1.2  -  Unassigned,  Open-Drain, Digital
    ; P1.3  -  Unassigned,  Open-Drain, Digital
    ; P1.4  -  Unassigned,  Open-Drain, Digital
    ; P1.5  -  Unassigned,  Open-Drain, Digital
    ; P1.6  -  Unassigned,  Open-Drain, Digital
    ; P1.7  -  Unassigned,  Open-Drain, Digital
    ; P2.0  -  Unassigned,  Push-Pull,  Digital
    ; P2.1  -  Unassigned,  Push-Pull,  Digital
    ; P2.2  -  Unassigned,  Push-Pull,  Digital
    ; P2.3  -  Unassigned,  Push-Pull,  Digital

    mov  P2MDIN,    #0BFh
    mov  P0MDOUT,   #018h
    mov  P2MDOUT,   #08Fh
    mov  P3MDOUT,   #01Ch
    mov  XBR0,      #001h
    mov  XBR1,      #040h
    ret

Oscillator_Init:
    mov  OSCICN,    #083h
    ret

Interrupts_Init:
    mov  IE,        #010h
    ret

; Initialization function for device,
; Call Init_Device from your main program
Init_Device:
    lcall Reset_Sources_Init
    lcall PCA_Init
    lcall Timer_Init
    lcall UART_Init
    lcall Port_IO_Init
    lcall Oscillator_Init
    lcall Interrupts_Init
    ret

end
