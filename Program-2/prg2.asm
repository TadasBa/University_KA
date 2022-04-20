.model small   
   
.stack  100h
   
.data 
        
    duom1_vardas db 200 dup (0) ;failo vardas tures baigtis nuliu  
    duom2_vardas db 200 dup (0)
    swich        db 200 dup (0)
    rez_vardas   db 200 dup (0)
    pagalbos_tekstas db "Programa atima du sesioliktainius skaicius ir atspasudina rezultata kitame faile $" 
    succses          db "Programa suveike sekmingai $" 
    klaidos_tekstas  db "Klaida atidarant failus $"  
    pasisveikinimo_tekstas db "Sveiki, si programa atima du siasioliktainius skaicius, prasome ivesti du failus skaitymui ir du failus rasymui, ivedus /? gausite programos paaiskinima $"
    newline            db 10, 13, '$'
        
    buff     db 20 dup('$')  
    buff2    db 20 dup('$')
    sbuff    db 20 dup('$')
    rezbuff  db 20 dup('$')   
        
    fhandle    dw ?  
    f2handle   dw ?
    shandle    dw ?
    rhandle    dw ?  
    
    failo1_dydis    db ?
    failo2_dydis    db ?
    rez_failo_dydis db ?
    didesnis_pirmas db ?                     
       
.code

start:
    mov ax, @data
    mov ds, ax
    
pasisveikinimas:
	mov ah, 9
	mov dx, offset pasisveikinimo_tekstas
	int 21h   
	
    mov ah, 09h
    mov dx, offset newLine    
    int 21h  

pirmas_failas:   
    mov bx, 82h       
	mov si, offset duom1_vardas 
	
	cmp byte ptr es:[80h], 0 
	je link_pagalba
	cmp es:[bx], '?/' 
	jne ar_pavyko_atidaryti 
	cmp byte ptr es:[bx+2], 13 
	je link_pagalba
	                                                              
ar_pavyko_atidaryti:  
	cmp byte ptr es:[bx], ' ' 
	je duom1_atidarymas
	mov dl, byte ptr es:[bx]
	mov [si], dl	
	inc bx 
	inc si
	jmp ar_pavyko_atidaryti 
 
duom1_atidarymas:
    mov ah, 3Dh
    mov al, 00
    mov dx, offset duom1_vardas
    int     21h 
    
    jc link_klaida
    mov fhandle,  ax  
    jmp antras_failas
    
link_pagalba:    
    jmp pagalba
    
link_klaida:
    jmp klaida                    

antras_failas:		
	add bx, 1
	mov si, offset duom2_vardas
	cmp es:[bx], '?/' 
	jne ar_pavyko_atidaryti2 
	cmp byte ptr es:[bx+2], 13 
	je link_pagalba
		                                                              
ar_pavyko_atidaryti2:  
    cmp byte ptr es:[bx], ' ' 
	je duom2_atidarymas 
	mov dl, byte ptr es:[bx]
	mov [si], dl	
	inc bx 
	inc si
	jmp ar_pavyko_atidaryti2   
duom2_atidarymas:   
    mov ah, 3Dh
    mov al, 00
    mov dx, offset duom2_vardas
    int     21h
    jc  klaida 
    mov f2handle,  ax              

swich_failas:	
	add bx, 1
	mov si, offset swich	
	cmp es:[bx], '?/' 
	jne ar_pavyko_sukurti1 
	cmp byte ptr es:[bx+2], 13 
	je pagalba 
	
ar_pavyko_sukurti1:  
	cmp byte ptr es:[bx], ' ' 
	je swich_sukurimas 	
	mov dl, byte ptr es:[bx]
	mov [si], dl	
	inc bx 
	inc si
	jmp ar_pavyko_sukurti1 	                                                              
swich_sukurimas: 
    mov ah, 3Ch
    mov cx, 0 
    mov dx, offset swich
    int     21h 
    jc klaida 
    mov shandle,  ax
    
rez_failas:		
	add bx, 1
	mov si, offset rez_vardas	
	cmp es:[bx], '?/' 
	jne ar_pavyko_sukurti
	jmp pagalba 
	
ar_pavyko_sukurti:  
	cmp byte ptr es:[bx], 13 
	je rez_sukurimas 
	mov dl, byte ptr es:[bx]
	mov [si], dl	
	inc bx 
	inc si
	jmp ar_pavyko_sukurti 	                                                              
rez_sukurimas:
    mov ah, 3Ch
    mov cx, 0 
    mov dx, offset rez_vardas
    int     21h
    jc klaida  
    mov rhandle,  ax
    jmp skaitymas1

pagalba:
	mov ah, 9
	mov dx, offset pagalbos_tekstas
	int 21h
	jmp pabaiga 	
klaida:
    mov ah, 9
	mov dx, offset klaidos_tekstas
	int 21h
	jmp pabaiga                

skaitymas1:
    mov bx, fhandle
    mov si, offset buff
    call    skaityk 
    add failo1_dydis, al
    cmp ax, 0
    je link_uzdarymo       
    
    jmp duomenu1_ilgis       

skaitymas2:
    mov bx, f2handle 
    mov si, offset buff2
    call    skaityk 
    add failo2_dydis, al
    cmp ax, 0
    je      link_uzdarymo    
    
    jmp duomenu2_ilgis 
            
duomenu1_ilgis:
    cmp ax, 20
    je skaitymas1
    jmp skaitymas2
    
duomenu2_ilgis:
    cmp ax, 20
    je skaitymas2
    
    jmp darbas_su_duomenimis 

link_uzdarymo:
    jmp uzdarytiRasymui 
    
darbas_su_duomenimis:    
    mov cl, failo1_dydis 
    
    mov di, offset buff
    
    add di, cx 
    
    dec di
        
    mov cl, failo2_dydis  
    
    mov si, offset buff2
    
    add si, cx 
    
    dec si    
    
    call tikrink_duom_failu_dydzius
      
    jb antras_atimti_pirmas
    
    ja pirmas_atimti_antras
    
    push di 
    push si 
    push ax
    
    mov di, offset buff
     
    mov si, offset buff2 
    
tikrinimo_ciklas:
    mov ah, [di]
    
    mov al, [si] 
    
    cmp ah, al
    
    ja pirmas_didesnis
    
    jb antras_didesnis
    
    inc si
    
    inc di
    
    loop tikrinimo_ciklas     
    
pirmas_didesnis:
    mov didesnis_pirmas, 1
    
    pop ax
    pop si
    pop di
    
pirmas_atimti_antras:
    xor bx, bx
    
    xor dx, dx
    
    mov cl, failo1_dydis
        
ciklas1:
    mov ah, [di]
    
    mov dh, ah 
    
    call ascii_to_hex
    
    mov ah, dh
    
    mov al, [si]
    
    mov dh, al
    
    call ascii_to_hex
    
    mov al, dh 
    
    call veiksmai_su_skaiciais
    
    jmp dedam_i_buff
     
antras_didesnis:    
    mov didesnis_pirmas, 0    
    pop ax
    pop si
    pop di
    
antras_atimti_pirmas:    
    xor bx, bx    
    xor dx, dx
    
    mov cl, failo2_dydis     
    
ciklas2: 
    mov ah, [si]
    
    mov dh, ah 
    
    call ascii_to_hex
    
    mov ah, dh
    
    mov al, [di]
    
    mov dh, al 
    
    call ascii_to_hex
    
    mov al, dh 
    
    call veiksmai_su_skaiciais     
       
dedam_i_buff:
            
    call rasyk      
    
    inc rez_failo_dydis  

    dec di             
    
    dec si          
              
    
    call tikrink_duom_failu_dydzius 
                              
    
    jb kartoti_antra_cikla
    
    ja kartoti_pirma_cikla
        
    cmp didesnis_pirmas, 0
    
    je kartoti_antra_cikla 
    
    kartoti_pirma_cikla:
          
	loop ciklas1
	
	jmp skaitymas_swich 
	
kartoti_antra_cikla:
	loop ciklas2
	
skaitymas_swich:    
    mov ah, 42h
	mov al, 0
	mov bx, shandle
	mov cx, 0
	mov dx, 0
	int 21h
    
    mov si, offset sbuff
    call    skaityk 
    cmp ax, 0
    je      uzdarytiRasymui 
    
    mov si, offset sbuff 
     
    cmp ax, 20
    je skaitymas_swich
    
    
sukeitimo_pradzia:
	mov cl, rez_failo_dydis  
    
    mov si, offset sbuff
    
    add si, cx 
   
    dec si    
           
    tarpas:
     
    mov ah, [si] 
           
    cmp ah, 30h
    
    jne sukeitimo_ciklas
    
    dec si
    
    dec cl
    
    jmp tarpas 
    
	
sukeitimo_ciklas:	
    mov ah, [si]
	
	call sukeisk 
	
	dec si
	
	loop sukeitimo_ciklas
	
uzdarytiSwich: 
    mov ah, 3Eh
    mov bx, shandle
    int 21h
	     
uzdarytiRasymui: 
    mov ah, 3Eh
    mov bx, rhandle
    int 21h 
   
uzdarykSkaitymui:
    mov ah, 3Eh
    mov bx, fhandle
    int 21h   
   
uzdarykSkaitymui2:
    mov ah, 3Eh
    mov bx, f2handle
    int 21h 
    
sekminga_pabaiga:    
    mov ah, 9h
    mov dx, offset succses
    int 21h
    jmp pabaiga

pabaiga:               
    mov ax, 4c00h
    mov al, 0
    int     21h        

proc veiksmai_su_skaiciais
    
    call ar_al_0
    
tesiam:   
    cmp dl, 1
    
    jne atimties_pradzia
    
    cmp ah, 0
    
    je grazinu_ir_vel_skolinuosi
    
    sub ah, 1
    
    mov dl, 0
    
    jmp atimties_pradzia
    
grazinu_ir_vel_skolinuosi:    
    mov ah, 0Fh        
    
    mov dl, 1          
    
atimties_pradzia:    
    cmp ah, al      
    
    jae atimtis          
    
    add ah, 10h    
    
    xor dx, dx     
    
    mov dl, 1     
    
atimtis:      
    sub ah, al
    
    ret
    
    veiksmai_su_skaiciais endp

proc ar_al_0
     
    cmp al, 0Fh
    
    ja nulis
    
    cmp al, 0Ah
    
    jb ar_skaicius
    
    ret
    
nulis:    
    mov al, 0
    
    ret
    
ar_skaicius:    
    cmp al, 09h
    
    ja nulis
            
    cmp al, 0h
    
    jb nulis
    
    ret 
     
    ar_al_0 endp

proc tikrink_duom_failu_dydzius     
    
    push dx
    
    mov dl, failo1_dydis  
    
    cmp dl, failo2_dydis  
    
    pop dx
    
    ret
    
    tikrink_duom_failu_dydzius endp
   
proc skaityk            
    push cx
    push dx
    
    mov ah, 3Fh
    mov cx, 20d 
    mov dx, si
    int     21h
               
    pop dx
    pop cx
    ret
           
    skaityk endp  
                                  
proc ascii_to_hex     
    cmp dh, 3Ah
    
    jb skaicius
    
    sub dh, 37h
    
    ret
    
    skaicius:
    
    sub dh, 30h
   
    ret 
    
    ascii_to_hex endp

proc hex_to_ascii    
    cmp ah, 0Ah
    
    jb sk
    
    add ah, 37h
    
    ret
    
    sk:
    
    add ah, 30h 
    
    ret
    
    hex_to_ascii endp

proc sukeisk
    push cx
    push ax
    
    mov cl, 1 
            
    mov ds:[rezbuff], ah 
    
    mov ah, 40h
    mov bx, rhandle
    mov dx, offset rezbuff
    int 21h 
    
    pop ax
    pop cx
                       
    ret 
    
    sukeisk endp 
      
proc rasyk     
    call hex_to_ascii  
    
    mov ds:[sbuff], ah 
    
    push dx
    push ax
    push cx         
    
    mov cl, 1  
    
    mov ah, 40h
    mov bx, shandle
    mov dx, offset sbuff
    int 21h
     
    pop cx 
    pop ax
    pop dx
                       
    ret           
              
    rasyk endp 

end start