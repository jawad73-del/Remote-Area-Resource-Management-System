include 'emu8086.inc'
.model small
.stack 100h

MAXREC  equ 5
NAMELEN equ 10

.data
;FILE
filename    db "database.txt",0
fileHandle  dw ?

;MENU
menu db 13,10,'----- MENU -----',13,10
     db '1. Add Record',13,10
     db '2. Update Record',13,10
     db '3. Delete Record',13,10
     db '4. Display Records',13,10
     db '5. Exit',13,10
     db 'Choice: $'

head db 13,10,'Sr Name       FM  W  F  P',13,10,'$'

;MSG
msgInvalid db 13,10,'Invalid choice!$'
msgSr      db 13,10,'Enter Sr (1-9): $'
msgName    db 13,10,'Enter Name (10 chars): $'
msgFam     db 13,10,'Family Members: $'
msgWater   db 13,10,'Water: $'
msgFlour   db 13,10,'Flour: $'
msgPulse   db 13,10,'Pulse: $'
dupMsg     db 13,10,'Duplicate Sr not allowed!$'
nfMsg      db 13,10,'Record not found!$'

totFamMsg   db 13,10,'Total Family Members: $'
totWaterMsg db 13,10,'Total Water: $'
totFlourMsg db 13,10,'Total Flour: $'
totPulseMsg db 13,10,'Total Pulse: $'

; DATA 
srArr      db MAXREC dup(0)
nameArr    db MAXREC*NAMELEN dup(' ')
famArr     db MAXREC dup(0)
waterArr   db MAXREC dup(0)
flourArr   db MAXREC dup(0)
pulseArr   db MAXREC dup(0)
count      dw 0

;TOTALS
totalFam    dw 0
totalWater  dw 0
totalFlour  dw 0
totalPulse  dw 0
 
charBuf db ?
.code
main proc
    mov ax,@data
    mov ds,ax

;call LoadFromFile

menuLoop:
    lea dx,menu
    mov ah,09h
    int 21h

    mov ah,01h
    int 21h

    cmp al,'1' 
    je addRec
    cmp al,'2' 
    je updateRec
    cmp al,'3' 
    je deleteRec
    cmp al,'4' 
    je displayRec
    cmp al,'5' 
    je exitProgram

    lea dx,msgInvalid
    mov ah,09h
    int 21h
    jmp menuLoop

;ADD 
addRec:
    mov bx,count
    cmp bx,MAXREC
    jae menuLoop

    lea dx,msgSr
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'

    mov si,0
chkDup:
    cmp si,count
    je storeSr
    cmp srArr[si],al
    je dupErr
    inc si
    jmp chkDup

dupErr:
    lea dx,dupMsg
    mov ah,09h
    int 21h
    jmp menuLoop

storeSr:
    mov srArr[bx],al

    lea dx,msgName
    mov ah,09h
    int 21h
    mov ax,bx
    mov cx,NAMELEN
    mul cx
    mov si,ax
    mov cx,NAMELEN
nameIn:
    mov ah,01h
    int 21h
    mov nameArr[si],al
    inc si
    loop nameIn

    lea dx,msgFam
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'
    mov famArr[bx],al

    lea dx,msgWater
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'
    mov waterArr[bx],al

    lea dx,msgFlour
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'
    mov flourArr[bx],al

    lea dx,msgPulse
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'
    mov pulseArr[bx],al
    PrintN
    Print 'Record Added Successfully'
    inc count
    call SaveToFile
    jmp menuLoop

;UPDATE
updateRec:
    lea dx,msgSr
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'

    mov si,0
findUpd:
    cmp si,count
    je notFound
    cmp srArr[si],al
    je doUpdate
    inc si
    jmp findUpd

doUpdate:
    lea dx,msgName
    mov ah,09h
    int 21h
    mov ax,si
    mov cx,NAMELEN
    mul cx
    mov di,ax
    mov cx,NAMELEN
updName:
    mov ah,01h
    int 21h
    mov nameArr[di],al
    inc di
    loop updName

    lea dx,msgFam
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'
    mov famArr[si],al

    lea dx,msgWater
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'
    mov waterArr[si],al

    lea dx,msgFlour
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'
    mov flourArr[si],al

    lea dx,msgPulse
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'
    mov pulseArr[si],al
    
    PrintN
    Print 'Record Update Successfully'
    call SaveToFile
    jmp menuLoop

notFound:
    lea dx,nfMsg
    mov ah,09h
    int 21h
    jmp menuLoop

;DELETE 
deleteRec:
    lea dx,msgSr
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    sub al,'0'
    mov si,0
         PrintN
    Print 'Record Delete Successfully'
findDel:
    cmp si,count
    je menuLoop
    cmp srArr[si],al
    je delOk
    inc si
    jmp findDel
 
delOk:
    mov srArr[si],0
    call SaveToFile
    jmp menuLoop
    
;DISPLAY
displayRec:
    mov totalFam,0
    mov totalWater,0
    mov totalFlour,0
    mov totalPulse,0

    lea dx,head
    mov ah,09h
    int 21h

    mov si,0
dispLoop:
    cmp si,count
    je showTotals
    cmp srArr[si],0
    je nextRec

    mov dl,srArr[si]
    add dl,'0'
    mov ah,02h
    int 21h
    print ' '

    push si
    mov ax,si
    mov cx,NAMELEN
    mul cx
    mov di,ax
    mov cx,NAMELEN
pName:
    mov dl,nameArr[di]
    mov ah,02h
    int 21h
    inc di
    loop pName
    pop si

    print ' '
    mov al,famArr[si]
    cbw
    add totalFam,ax
    call PrintAX

    print ' '
    mov al,waterArr[si]
    cbw
    add totalWater,ax
    call PrintAX

    print ' '
    mov al,flourArr[si]
    cbw
    add totalFlour,ax
    call PrintAX

    print ' '
    mov al,pulseArr[si]
    cbw
    add totalPulse,ax
    call PrintAX

    PrintN
nextRec:
    inc si
    jmp dispLoop

showTotals:
    lea dx,totFamMsg
    mov ah,09h
    int 21h
    mov ax,totalFam
    call PrintAX

    lea dx,totWaterMsg
    mov ah,09h
    int 21h
    mov ax,totalWater
    call PrintAX

    lea dx,totFlourMsg
    mov ah,09h
    int 21h
    mov ax,totalFlour
    call PrintAX

    lea dx,totPulseMsg
    mov ah,09h
    int 21h
    mov ax,totalPulse
    call PrintAX
    jmp menuLoop

;PRINT NUMBER 
PrintAX proc
    push ax
    mov bx,10
    xor cx,cx
p1: xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jne p1
p2: pop dx
    add dl,'0'
    mov ah,02h
    int 21h
    loop p2
    pop ax
    ret
PrintAX endp
;WRITE ONE CHAR TO FILE
WriteChar proc
    mov charBuf,al
    mov ah,40h
    mov cx,1
    lea dx,charBuf
    int 21h
    ret
WriteChar endp

;WRITE ONE DIGIT(0-9)
WriteDigit proc
    add al,'0'   
    call WriteChar
    ret
WriteDigit endp
;FILE HANDLING
;SAVE TO FILE (ASCII TEXT)
SaveToFile proc
;create file
    mov ah,3Ch
    lea dx,filename
    xor cx,cx
    int 21h
    mov fileHandle,ax

    mov bx,fileHandle
    mov si,0           

saveLoop:
    cmp si,count
    je closeFile

;SR
    mov al,srArr[si]
    call WriteDigit

    mov al,' '
    call WriteChar

;NAME(10 chars)
    mov ax,si
    mov cx,NAMELEN
    mul cx
    mov di,ax

    mov cx,NAMELEN
nameLoop:
    mov al,nameArr[di]
    call WriteChar
    inc di
    loop nameLoop

    mov al,' '
    call WriteChar

;FAMILY 
    mov al,famArr[si]
    call WriteDigit
    mov al,' '
    call WriteChar

;WATER
    mov al,waterArr[si]
    call WriteDigit
    mov al,' '
    call WriteChar

;FLOUR 
    mov al,flourArr[si]
    call WriteDigit
    mov al,' '
    call WriteChar

;PULSE 
    mov al,pulseArr[si]
    call WriteDigit

;NEW LINE
    mov al,13
    call WriteChar
    mov al,10
    call WriteChar

    inc si
    jmp saveLoop

closeFile:
    mov ah,3Eh
    mov bx,fileHandle
    int 21h
    ret
SaveToFile endp

LoadFromFile proc
    mov ah,3Dh
    lea dx,filename
    xor al,al
    int 21h
    jc noFile
    mov fileHandle,ax

    mov ah,3Fh
    mov bx,fileHandle
    mov cx,2
    lea dx,count
    int 21h

    mov ah,3Fh
    mov cx,MAXREC
    lea dx,srArr
    int 21h

    mov ah,3Fh
    mov cx,MAXREC*NAMELEN
    lea dx,nameArr
    int 21h

    mov ah,3Fh
    mov cx,MAXREC
    lea dx,famArr
    int 21h

    mov ah,3Fh
    mov cx,MAXREC
    lea dx,waterArr
    int 21h

    mov ah,3Fh
    mov cx,MAXREC
    lea dx,flourArr
    int 21h

    mov ah,3Fh
    mov cx,MAXREC
    lea dx,pulseArr
    int 21h

    mov ah,3Eh
    mov bx,fileHandle
    int 21h
noFile:
    ret
LoadFromFile endp

exitProgram:
    mov ah,4Ch
    int 21h
end main