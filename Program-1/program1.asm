.model small
.stack 100h
.data
    
    buffer  db 255, ?, 255 dup('$')  
    output  db 255*4 dup(" ")     
    msg1    db 'Enter: $'                                                           
    msg2    db 10, 13, 'Result: $'
    newLine db 10, 13, '$' 
    msg3    db 10, 13, 'Eilutes ilgis: $'

.code

start:

    mov ax, @data
    mov ds, ax                
    
    mov ah, 09h
    mov dx, offset msg1       
    int 21h
    
    mov ah, 0ah
    mov dx, offset buffer     
    int 21h 
    
    mov ah, 09h
    mov dx, offset newLine    
    int 21h 
    
    mov ah, 09h
    mov dx, offset msg2     
    int 21h     
             
    mov si, 0
    
ciklas:  
    mov bl, ds:[buffer + 1]   ; i bl registra perkeliamas ivestu elementu skaicius ; kas bus jeigu buffer +1 pakeisiu i buffer + 0 ir kodel  
    mov bh, 0                 
    cmp si, bx                ; tikrinama ar yra nors vienas elementas kuri reikia converuoti, jeigu ne sokam i pabaiga
    je pabaiga 
    
    mov bx, offset buffer + 2 ; i bx registra issisaugau bufferio pradzios baita  
    add bx, si                ; prie bx pridedame si kuris kiekvieno ciklo metu padideja vienetu ir taip zinome kuri simboli skaityti toliau   
    mov ah, ds:[bx]           ; i ah registra ikeliamas apdoroti norimas baitas
    inc si          
    cmp ah, 0ah               
    jb number1
    cmp ah, 64h
    jb number2   
    jmp number3
             
number1:

    add ah, 48                ; jeigu skaicius mazesnis uz 10, tai pridedame 48
    mov ds:[output], ah       ; i output perkeliamas simbolio desimtainis kodas
    mov ds:[output + 1], ' '  ; po skaiciaus sekantis elementas uzrasomas tarpo simboliu
    mov cx, 2                
    
    call isvestis
    
number2: 
    mov al, ah                 
    mov ah, 0                
    mov bh, 10                
    div bh                    
    add al, 48               
    mov ds:[output], al      
    add ah, 48                
    mov ds:[output + 1], ah   
    mov ds:[output + 2], ' '  
    mov cx, 3           
    call isvestis
    
number3:  

    mov al, ah
    mov ah, 0
    mov bh, 100
    div bh
    add al, 48     
    
    mov ds:[output], al
    mov bh, 10
    
    mov al, ah
    mov ah, 0
    
    div bh
       
    add al, 48
    mov ds:[output + 1], al  
    
    add ah, 48
    mov ds:[output + 2], ah  
    
    mov cx, 4 
    call isvestis
                 
isvestis proc 
          
    mov ah, 40h
    mov bx, 2 
    
    mov dx, offset output    
    int 21h                  ; atspausinamas i output irasytas skaicius atitinkantis ivesto simbolio desimtaine reiksme
    jmp ciklas               ; kartojamas ciklas
    
    isvestis endp 
    
pabaiga: 


    mov ah, 09h
    mov dx, offset msg3     
    int 21h
           
    mov ah, 02h    

    mov dx, si 
    add dx, 48 

    int 21h   

 
mov ax, 4c00h
int 21h
end start