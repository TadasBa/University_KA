; 2021 
; Tadas Baltrunas 
; PS 5gr
; 3 programa 11 variantas
; Zingsninio rezimo pertraukimo (int 1) apdorojimo procedura, atpazistanti komanda ADC reg+r/m

.model small
.stack 100h
.data

    author  db "AUTHOR: Tadas Baltrunas$"
    about   db "This program, when int 1h is on, detects command ADC and prints info about it$"     
    
    newline db 10, 13, '$'
    found   db "Zingsninio rezimo pertraukimas! $"
    ADCf    db "adc $"
    ADDf    db "add $"
       
    mood db 0h
    reg  db 0h
    rm   db 0h
    opk  db 0h
    adr  db 0h 
    d    db 0h
    w    db 0h
    
    adc1 db 0h
    add1 db 0h
    
    rAX dw ?
    rBX dw ?
    rCX dw ?
    rDX dw ?
    rSI dw ?
    rDI dw ?
    rSP dw ?
    rBP dw ?
    
    AXs db "ax$" 
    AHs db "ah$"
    ALs db "al$"
    BXs db "bx$" 
    BHs db "bh$"
    BLs db "bl$"
    CXs db "cx$" 
    CHs db "ch$"
    CLs db "cl$"
    DXs db "dx$" 
    DHs db "dh$"
    DLs db "dl$"
    SIs db "si$" 
    DIs db "di$"
    BPs db "bp$"
    SPs db "sp$"
     
.code

start:
 
    mov  ax, @data
    mov  ds, ax
    
    mov  ah, 9
    mov  dx, offset author
    int  21h
    
    mov  ah, 9
    mov  dx, offset newline
    int  21h
    
    mov  ah, 9
    mov  dx, offset about
    int  21h   
    
    mov  ah, 9
    mov  dx, offset newline
    int  21h      
;-------------------------------------------------    
    mov  ax, 0
    mov  es, ax   ; ES NUSTATOME VEKTORIU LENTELES PRADZIOS ADRESU
    
    push es:[4]  ; ISSISAUGOME ISR PRADZIOS ADRESA
    push es:[6]  ; ISSISAUGOME ISR SEGMENTO PRADZIOS ADRESA
              
              
    mov  word ptr es:[4], offset ISR ; VEKTORIU LENETELEJE ISSISAUGOM ISR POSLINKI NUO KODO SEGMENTO PRADZIOS
    mov  es:[6], cs  ; VEKTORIU LENTELEJE ISSISAUGOME ISR SEGMENTA
    
    pushf  ; ISSISAUGOM SF
    pushf  ; ISSISAUGOM SF DAR KARTA KAD GALETUME PASIIMTI REIKSME
    
    pop  ax ; ISSIEMAME SF REIKSME
    
    or   ax, 0100h ; AX = 0000 0001 0000 0000 
    
    push ax
    popf    ; TF=1
    
    nop ; PERTRAUKIMAS PRASIDEDA PO SIOS KOMANDOS
;-------------------------------------------------    
    mov  ax, 03Eh
    mov  dx, 0AAh
    mov  bp, 1000h
    mov  sp,  0Fh  
    adc  dl, al    
    mov  cl, 015d   
    adc  cl, dl  
    add  di, di    
    mov  si, 0FFFFh
    mov  dx, 01h   
    adc  si, dx    
    add  bp, sp
    adc  sp, bp
    add  al, ah

    
    popf ; TF=0, ISSIMAMA PACIOJE PRADZIOJE BUVUSIOS FLAG REIKSMES         
;-------------------------------------------------              
    pop  es:[6]   
    pop  es:[4]    

EndOfTheProgram:

    mov  ah, 4Ch 
    mov  al, 0
    int  21h      
;-------------------------------------------------    
proc ISR    ; INTERRUPT SERVICE ROUTINE
                                       
    push ax
    push bx
    push dx
    push bp
    push es
    push ds
    
    mov rAX, ax
    mov rBX, bx
    mov rCX, cx
    mov rDX, dx
    mov rSI, si   
    mov rDI, di
    mov rSP, sp
    mov rBP, bp
    
    mov ax, @data
    mov ds, ax
               
    mov bp, sp      ; SU STEKU DIRBTI PATOGIAUSIA SU BP REGISTRU           
    add bp, 12      ; RANDAME GRYZIMO ADRESA
    mov bx, [bp]    ; ISSISAUGOM GRYZIMO ADRESO POSLINKI
    
    mov es, [bp+2]  ; ISSISAUGOM GRYZIMO SEGMENTA
    mov dl, es:[bx] ; ISIMAME KOMANDOS OPK BAITA
    mov opk, dl
    
    mov al, dl
    and al, 0FCh    ; NUNULINAME PASKUTINIUS DU NUSKAITYTOS KOMANDOS BITUS                                                        
                                                            
    cmp al, 10h     ; TIKRINAME AR OPK ATITINKA KOMANDOS ADC
    je foundADC
    
    cmp al, 00h
    je foundADD
    jne  ToISRend
    
    foundADC:
    
    inc adc1
    jmp continue
               
    foundADD:
    
    inc add1            
                
    continue:
    
    mov ah, 9h
    mov dx, offset found
    int 21h
    
    mov ah, 9h
    mov dx, offset newline
    int 21h 
    
    mov dl, [es:bx+1] ; ISSISAUGOME KOMANDOS ADRRESS BAITA
    mov adr, dl 
    
    mov al, opk
    and al, 02h
    mov d,  al        ; ISSISAUGOME d BITO REIKSME
    
    mov al, opk
    and al, 01h        
    mov w,  al        ; ISSISAUGOME w BITO REIKSME  
    
    mov al, adr
    and al, 0C0h
    mov mood, al      ; ISSISAUGOME mod REIKSME
    
    mov al, adr
    and al, 038h
    mov reg, al       ; ISSISAUGOME reg REIKSME
                                               
    mov al, adr
    and al, 07h
    mov rm, al        ; ISSISAUGOME r/m REIKSME 
    
    call Address    
    call space     
    call MachineCode     
    call space
    
    cmp adc1, 1
    je  printADCmsg
    
    mov ah, 9
    mov dx, offset ADDf
    int 21h    
    jmp compare    

ToISRend:
    
    jmp ISRend
    
    printADCmsg:    
    mov ah, 9
    mov dx, offset ADCf
    int 21h    
    
    compare:    
    cmp mood, 040h
    je  mod01
    
    cmp mood, 080h
    je  mod01
    
    cmp mood, 00h
    je  mod00
    
    call mod11
    jmp  ISRend
    
    mod01:
    call mod1
    jmp  ISRend
    
    mod00:
    call mod0
    jmp  ISRend

ISRend: 
    
    cmp adc1, 1
    je  decADC
    cmp add1, 1
    je  decADD
    jmp endend
    
    decADC:    
    dec adc1
    jmp endend
    
    decADD:    
    dec add1
    jmp endend
    
    endend:    
    mov ah, 9h
    mov dx, offset newline
    int 21h
    
    pop ds
    pop es 
    pop bp
    pop dx
    pop bx
    pop ax
        
    iret  
    
ISR endp 
;-------------------------------------------------
proc mod11
    push ax
    push dx
    
    cmp w, 0h
    je w0mod11
    jmp w1mod11
    
w0mod11:

    cmp d, 2h
    je w0d1mod11
    jmp w0d0mod11
    
w0d1mod11:

    CALL w0d1mod11REG
    call comma
    call space
    CALL w0d1mod11RM
    call semicolon
    call space
    CALL w0d1mod11REG
    call equal
    CALL w0d1mod11REGvalue
    call space
    call semicolon
    call space
    CALL w0d1mod11RM
    call equal
    CALL w0d1mod11RMvalue
    jmp  EXITmod11
        
    
w0d0mod11:     
    
    CALL w0d1mod11RM
    call comma
    call space
    CALL w0d1mod11REG
    call semicolon
    call space
    CALL w0d1mod11RM
    call equal
    CALL w0d1mod11RMvalue
    call space
    call semicolon
    call space
    CALL w0d1mod11REG
    call equal
    CALL w0d1mod11REGvalue
    jmp  EXITmod11

w1mod11:

    cmp d, 2h
    je w1d1mod11
    jmp w1d0mod11

w1d1mod11: 
    
    CALL w1d1mod11REG
    call comma
    call space
    CALL w1d1mod11RM
    call semicolon
    call space
    CALL w1d1mod11REG
    call equal
    CALL w1d1mod11REGvalue
    call space
    call semicolon
    call space
    CALL w1d1mod11RM
    call equal
    CALL w1d1mod11RMvalue
    jmp  EXITmod11

w1d0mod11:
    
    CALL w1d1mod11RM
    call comma
    call space
    CALL w1d1mod11REG
    call semicolon
    call space
    CALL w1d1mod11RM
    call equal
    CALL w1d1mod11RMvalue
    call space
    call semicolon
    call space
    CALL w1d1mod11REG
    call equal
    CALL w1d1mod11REGvalue
    jmp  EXITmod11

EXITmod11:
    
    pop dx
    pop ax
    
    ret
mod11 endp
;-------------------------------------------------
proc w0d1mod11RM 
    
    push ax
    push dx
    
    RM0:      
    cmp  rm, 0
    jne  RM1
    lea  dx, ALs
    call print
    jmp  EXITrm
    
    RM1:
    cmp  rm, 1
    jne  RM2
    lea  dx, CLs
    call print
    jmp  EXITrm
    
    RM2:
    cmp  rm, 2
    jne  RM3
    lea  dx, DLs
    call print
    jmp  EXITrm
    
    RM3:
    cmp  rm, 3
    jne  RM4
    lea  dx, BLs
    call print
    jmp  EXITrm
    
    RM4:
    cmp  rm, 4 
    jne  RM5
    lea  dx, AHs
    call print
    jmp  EXITrm
    
    RM5:
    cmp  rm, 5 
    jne  RM6
    lea  dx, CHs
    call print
    jmp  EXITrm
    
    RM6:
    cmp  rm, 6 
    jne  RM7
    lea  dx, DHs
    call print
    jmp  EXITrm
       
    RM7:
    lea  dx, BHs
    call print
 
EXITrm: 
            
    pop dx
    pop ax      
    ret         
                
w0d1mod11RM endp
;-------------------------------------------------
proc w0d1mod11REG 
    
    push ax
    push dx
    
    REG0:      
    cmp  reg, 00
    jne  REG1
    lea  dx, ALs
    call print
    jmp  EXITreg
    
    REG1:
    cmp  reg, 08h
    jne  REG2
    lea  dx, CLs
    call print
    jmp  EXITreg
    
    REG2:
    cmp  reg, 010h
    jne  REG3
    lea  dx, DLs
    call print
    jmp  EXITreg
    
    REG3:
    cmp  reg, 018h
    jne  REG4
    lea  dx, BLs
    call print
    jmp  EXITreg
    
    REG4:
    cmp  reg, 020h 
    jne  REG5
    lea  dx, AHs
    call print
    jmp  EXITreg
    
    REG5:
    cmp  reg, 028h 
    jne  REG6
    lea  dx, CHs
    call print
    jmp  EXITreg
    
    REG6:
    cmp  reg, 030h 
    jne  REG7
    lea  dx, DHs
    call print
    jmp  EXITreg
       
    REG7:
    lea  dx, BHs
    call print
 
EXITreg: 
            
    pop dx
    pop ax      
    ret         
                
w0d1mod11REG endp 
;-------------------------------------------------
proc w0d1mod11REGvalue
    
    push ax
    push dx 
    
    REGv0:
    cmp  reg, 00h
    jne  REGv1
    mov  ax, rAX
    call ConvAndPrint  
    jmp  EXITregv
    
    REGv1:
    cmp  reg, 08h
    jne  REGv2
    mov  ax, rCX
    call ConvAndPrint  
    jmp  EXITregv
    
    REGv2:
    cmp  reg, 010h
    jne  REGv3
    mov  ax, rDX
    call ConvAndPrint  
    jmp  EXITregv
    
    REGv3:
    cmp  reg, 018h
    jne  REGv4
    mov  ax, rBX
    call ConvAndPrint  
    jmp  EXITregv
    
    REGv4:
    cmp  reg, 020h
    jne  REGv5
    mov  ax, rAX 
    mov  al, ah
    call ConvAndPrint  
    jmp  EXITregv
    
    REGv5:
    cmp  reg, 028h
    jne  REGv6
    mov  ax, rCX 
    mov  al, ah
    call ConvAndPrint  
    jmp  EXITregv
    
    REGv6:
    cmp  reg, 030h
    jne  REGv7
    mov  ax, rDX
    mov  al, ah
    call ConvAndPrint  
    jmp  EXITregv
    
    REGv7:
    mov  ax, rBX   
    mov  al, ah
    call ConvAndPrint  
      
EXITregv: 
     
    pop dx
    pop ax
    
    ret
    
w0d1mod11REGvalue endp
;-------------------------------------------------
proc w0d1mod11RMvalue
    
    push ax
    push dx 
    
    RMv0:
    cmp  rm, 0
    jne  RMv1
    mov  ax, rAX
    call ConvAndPrint  
    jmp  EXITrmv
    
    RMv1:
    cmp  rm, 1
    jne  RMv2
    mov  ax, rCX
    call ConvAndPrint  
    jmp  EXITrmv
    
    RMv2:
    cmp  rm, 2
    jne  RMv3
    mov  ax, rDX
    call ConvAndPrint  
    jmp  EXITrmv
    
    RMv3:
    cmp  rm, 3
    jne  RMv4
    mov  ax, rBX
    call ConvAndPrint  
    jmp  EXITrmv
    
    RMv4:
    cmp  rm, 4
    jne  RMv5
    mov  ax, rAX 
    mov  al, ah
    call ConvAndPrint  
    jmp  EXITrmv
    
    RMv5:
    cmp  rm, 5
    jne  RMv6
    mov  ax, rCX 
    mov  al, ah
    call ConvAndPrint  
    jmp  EXITrmv
    
    RMv6:
    cmp  rm, 6
    jne  RMv7
    mov  ax, rDX
    mov  al, ah
    call ConvAndPrint  
    jmp  EXITrmv
    
    RMv7:
    mov  ax, rBX   
    mov  al, ah
    call ConvAndPrint  
      
EXITrmv: 
     
    pop dx
    pop ax
    
    ret
    
w0d1mod11RMvalue endp
;-------------------------------------------------
proc w1d1mod11RM
       
    push ax
    push dx
    
    wRM0:      
    cmp  rm, 0
    jne  wRM1
    lea  dx, AXs
    call print
    jmp  EXITwrm
    
    wRM1:
    cmp  rm, 1
    jne  wRM2
    lea  dx, CXs
    call print
    jmp  EXITwrm
    
    wRM2:
    cmp  rm, 2
    jne  wRM3
    lea  dx, DXs
    call print
    jmp  EXITwrm
    
    wRM3:
    cmp  rm, 3
    jne  wRM4
    lea  dx, BXs
    call print
    jmp  EXITwrm
    
    wRM4:
    cmp  rm, 4 
    jne  wRM5
    lea  dx, SPs
    call print
    jmp  EXITwrm
    
    wRM5:
    cmp  rm, 5 
    jne  wRM6
    lea  dx, BPs
    call print
    jmp  EXITwrm
    
    wRM6:
    cmp  rm, 6 
    jne  wRM7
    lea  dx, SIs
    call print
    jmp  EXITwrm
       
    wRM7:
    lea  dx, DIs
    call print
 
EXITwrm: 
            
    pop dx
    pop ax      
    ret
          
w1d1mod11RM endp
;-------------------------------------------------
proc w1d1mod11REG
       
    push ax
    push dx
    
    
    wREG0:      
    cmp  reg, 00h
    jne  wREG1
    lea  dx, AXs
    call print
    jmp  EXITwreg
    
    wREG1:
    cmp  reg, 08h
    jne  wREG2
    lea  dx, CXs
    call print
    jmp  EXITwreg
    
    wREG2:
    cmp  reg, 010h
    jne  wREG3
    lea  dx, DXs
    call print
    jmp  EXITwreg
    
    wREG3:
    cmp  reg, 018h
    jne  wREG4
    lea  dx, BXs
    call print
    jmp  EXITwreg
    
    wREG4:
    cmp  reg, 020h 
    jne  wREG5
    lea  dx, SPs
    call print
    jmp  EXITrm
    
    wREG5:
    cmp  reg, 028h 
    jne  wREG6
    lea  dx, BPs
    call print
    jmp  EXITwreg
    
    wREG6:
    cmp  reg, 030h 
    jne  wREG7
    lea  dx, SIs
    call print
    jmp  EXITwreg
       
    wREG7:
    lea  dx, DIs
    call print
 
EXITwreg: 
            
    pop dx
    pop ax      
    ret
          
w1d1mod11REG endp
;-------------------------------------------------
proc w1d1mod11RMvalue
    
    push ax
    push dx

    wRMv0:
    cmp  rm, 0
    jne  wRMv1
    mov  ax, rAX
    call ConvAndPrint  
    jmp  EXITwrmv
    
    wRMv1:
    cmp  rm, 1
    jne  wRMv2
    mov  ax, rCX
    call ConvAndPrint  
    jmp  EXITwrmv
    
    wRMv2:
    cmp  rm, 2
    jne  wRMv3
    mov  ax, rDX
    call ConvAndPrint  
    jmp  EXITwrmv
    
    wRMv3:
    cmp  rm, 3
    jne  wRMv4
    mov  ax, rBX
    call ConvAndPrint  
    jmp  EXITwrmv
    
    wRMv4:
    cmp  rm, 4
    jne  wRMv5
    mov  ax, rSP 
    call ConvAndPrint  
    jmp  EXITwrmv
    
    wRMv5:
    cmp  rm, 5
    jne  wRMv6
    mov  ax, rBP 
    call ConvAndPrint  
    jmp  EXITwrmv
    
    wRMv6:
    cmp  rm, 6
    jne  wRMv7
    mov  ax, rSI
    call ConvAndPrint  
    jmp  EXITwrmv
    
    wRMv7:
    mov  ax, rDI   
    call ConvAndPrint  
      
EXITwrmv: 
     
    pop dx
    pop ax
    
    ret
    
w1d1mod11RMvalue endp
;-------------------------------------------------
proc w1d1mod11REGvalue
    
    push ax
    push dx

    wREGv0:
    cmp  reg, 00
    jne  wREGv1
    mov  ax, rAX
    call ConvAndPrint  
    jmp  EXITwregv
    
    wREGv1:
    cmp  reg, 080h
    jne  wREGv2
    mov  ax, rCX
    call ConvAndPrint  
    jmp  EXITwregv
    
    wREGv2:
    cmp  reg, 010h
    jne  wREGv3
    mov  ax, rDX
    call ConvAndPrint  
    jmp  EXITwregv
    
    wREGv3:
    cmp  reg, 018h
    jne  wREGv4
    mov  ax, rBX
    call ConvAndPrint  
    jmp  EXITwregv
    
    wREGv4:
    cmp  reg, 020h
    jne  wREGv5
    mov  ax, rSP 
    call ConvAndPrint  
    jmp  EXITwregv
    
    wREGv5:
    cmp  reg, 028h
    jne  wREGv6
    mov  ax, rBP 
    call ConvAndPrint  
    jmp  EXITwregv
    
    wREGv6:
    cmp  reg, 030h
    jne  wREGv7
    mov  ax, rSI
    call ConvAndPrint  
    jmp  EXITwregv
    
    wREGv7:
    mov  ax, rDI   
    call ConvAndPrint  
      
EXITwregv: 
     
    pop dx
    pop ax
    
    ret
    
w1d1mod11REGvalue endp
;-------------------------------------------------
proc mod1
     
     ret
mod1 endp 
;-------------------------------------------------
proc mod0
     
     ret
mod0 endp
;-------------------------------------------------
proc Address
    
    push ax
    push dx
    
    mov ax, es
    call ConvAndPrint
    
    mov ah, 2h
    mov dl, ':'
    int 21h
    
    mov ax, [bp]
    call ConvAndPrint
    
    pop dx
    pop ax
        
    ret
    
Address endp 
;-------------------------------------------------
proc ConvAndPrint
          
    push ax
    push bx
    push cx
    push dx 
    
    begin:    
    
    mov cx, 4h   
    mov dx, 0
    
    PushHex:
    
    mov bx, 10h    
    div bx   
    push dx    
    xor dx, dx    
    dec cx
    cmp cx, 0    
    jne PushHex
        
    mov cx, 4h
    
    hexToAscii: 
    
    pop dx    
    cmp dx, 9h    
    ja hexAF    
    add dx, 30h
    jmp printAscii 
    
    hexAF:
    
    add dx, 37h
        
    printAscii:    
    
    mov ah, 2h
    int 21h
    
    dec cx
    cmp cx, 0        
    jne hexToAscii 
    
    pop dx
    pop cx
    pop bx
    pop ax
          
    ret 
          
ConvAndPrint endp  
;-------------------------------------------------
proc MachineCode
                
    push ax
       
    mov ah, opk
    mov al, adr 
    
    call ConvAndPrint
    
    pop ax
       
    ret         
                
MachineCode endp
;-------------------------------------------------
proc space
     
     push ax
     push dx
     
     mov ah, 2h
     mov dx, ' '
     int 21h
    
     pop dx
     pop ax
     ret
     
space endp
;-------------------------------------------------
proc equal
     
     push ax
     push dx
     
     mov ah, 2h
     mov dx, '='
     int 21h
    
     pop dx
     pop ax
     ret
     
equal endp
;-------------------------------------------------
proc plus
     
     push ax
     push dx
     
     mov ah, 2h
     mov dx, '+'
     int 21h
    
     pop dx
     pop ax
     ret
     
plus endp  
;-------------------------------------------------
proc comma
     
     push ax
     push dx
     
     mov ah, 2h
     mov dx, ','
     int 21h
    
     pop dx
     pop ax
     ret
     
comma endp
;-------------------------------------------------
proc semicolon
     
     push ax
     push dx
     
     mov ah, 2h
     mov dx, ';'
     int 21h
    
     pop dx
     pop ax
     ret
     
semicolon endp
;-------------------------------------------------
proc print
     
     push ax
     
     mov ah, 9h
     int 21h
    
     pop ax
     ret  
     
print endp          
;-------------------------------------------------                                                 
end