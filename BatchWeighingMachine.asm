#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; add your code here
         jmp     st1 
         nop
         dw      0000
         dw      0000
         dw      ad_isr
         dw      0000
		 
		 db     1012 dup(0)  
		 
;dat1 db 11
;dat2 db 71


;This is the start of the main program

st1:	cli
MOV AX,0200H ; / MOV AX,SEG BUF1
MOV DS,AX   
MOV ES,AX
MOV SS,AX
MOV SP,0FFFEH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; FOR REFERENCE PURPOSES
;portA1 equ 0000h ; 8255 ports interfaced with ADC of Load Cell
;portB1 equ 0002h ; 8255 ports interfaced with ADC of Load Cell
;portC1 equ 0004h ; 8255 ports interfaced with ADC of Load Cell
;cwr1 equ 0006h ; 8255 ports interfaced with ADC of Load Cell
;portA2 equ 0008h ;8255 ports interfaced with 7 segment LEDs and buzzer
;portB2 equ 000Ah ;8255 ports interfaced with 7 segment LEDs and buzzer
;portC2 equ 000Ch ;8255 ports interfaced with 7 segment LEDs and buzzer
;cwr2 equ 000Eh ;8255 ports interfaced with 7 segment LEDs


lea si,inp1

;initialize 8255(ADC) with control word=98H
mov al,98h 
out 06h,al

x1:
in al,04h
;lea si,sw
;mov [si],al
and al,00100000b
cmp al,00100000b
jnz x1

; set pointer to the first of the 3 adresses where we want to store the inputs(wts)
lea si,inp1 


;select channel0
mov al,00h
out 02h,al

; set pc0 ie ALE 
mov al,01h
out 04h,al

;give soc
mov al,03h
out 04h,al

nop
nop
nop
nop

;make soc 0
mov al,01h
out 04h,al

;make ale 0
mov al,00h
out 04h,al

;give delay,isr is called
;
;
call delay_1ms

;select channel1
mov al,01h
out 02h,al

; set pc0 ie ALE 
mov al,01h
out 04h,al

;give soc
mov al,03h
out 04h,al

nop
nop
nop
nop

;make soc 0
mov al,01h
out 04h,al

;make ale 0
mov al,00h
out 04h,al

;give delay,isr is called
;
;
call delay_1ms


;select channel2
mov al,02h
out 02h,al

; set pc0 ie ALE 
mov al,01h
out 04h,al

;give soc
mov al,03h
out 04h,al

nop
nop
nop
nop

;make soc 0
mov al,01h
out 04h,al

;make ale 0
mov al,00h
out 04h,al

;give delay,isr is called
;
;
call delay_1ms

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
781 IS THE CONVERSION FACTOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Converting Algorithm

mov ax,781
mov cx,0000h
mov cl,inp1
mul cx
mov cx,1000
div cx

;Lower part in outp11 
lea si,outp11
mov [si],ax

;upper part in outp12
lea si,outp12
mov [si],dx

mov ax,781
mov cx,0000h
mov cl,inp2
mul cx
mov cx,1000
div cx

;Lower part in outp21 
lea si,outp21
mov [si],ax
lea si,outp22
mov [si],dx

mov ax,781
mov cx,0000h
mov cl,inp3
mul cx
mov cx,1000
div cx
lea si,outp31
mov [si],ax
lea si,outp32
mov [si],dx 

lea si,outp11
mov bx,[si]
lea si,outp21
add bx,[si]
lea si,outp31
add bx,[si]
                            
lea si,outp12
mov ax,[si]
lea si,outp22
add ax,[si]
lea si,outp32
add ax,[si]

mov dx,0
mov cx,1000
div cx
add bx,ax ; total quo in bx,total rem in dx

lea si,finalrem
mov [si],dx

mov cl,3
mov ax,bx
div cl

lea si,avgquo
mov [si],ax

mov cx,1000
mov al,ah
mov ah,0
mul cx          ;mul rem by 1000 to later add it with the prev rem

lea si,finalrem
add ax,[si]

mov cx,3
mov dx,0
div cx
                                      ; dx has decimal
mov dx,ax
lea si,avgquo
mov cl,[si]
mov ch,0

mov bx,cx                                ;bx has integer

lea si,avgdec
mov [si],dx

cmp bx,0063h
jb find

cmp bx,0063h
ja buzza

cmp dx,0000h
je find

buzza:
mov al,00000001b
out 0ch,al
jmp buzza
 
 find:
mov ax,bx
mov bh,0ah
div bh

lea si,tens
mov [si],al

lea si,units
mov [si],ah

lea si,dec3
mov ax,dx
mov cx,3
mov bx,000ah

x7:
mov dx,0
div bx
mov [si],dl
dec si
dec si
loop x7 

;starting the display process
start:
		mov al,00001110b
		out 0eh,al


;first digit
				
		mov al,81h
		out 0eh,al    

		
		lea si,tens
		mov al,[si]  ;moving the first digit to al	
		out 08h,al 	;moving the first digit into the port
            			;A of 8255(2) which is connected to 7447

		
		mov al,00000001b
		out 0ah,al		;value is made displayed on first led


        call delay1
        
        mov al,00000000b
		out 0ah,al	
;second digit
               
              
        lea si,units       
		mov al,[si]  ;moving the second digit to al
		out 08h,al 	;moving the second digit into the port
						;A of 8255(2) which is connected to 7447


		mov al,00000010b
		out 0ah,al		;value is made displayed on second led
    

     call delay1
        
        
        mov al,00000000b
		out 0ah,al	         
;first decimal digit
            
               
        lea si,dec1       
		mov al,[si]  ;moving the first decimal digit to al
		out 08h,al	;moving the first decimal into the port
						;A of 8255(2) which is connected to 7447
		
		mov al,00000100b
		out 0ah,al		;value is made displayed on third led
		
           call delay1 
       
        mov al,00000000b
		out 0ah,al	           
         
           
;second decimal digit
     
        
        lea si,dec2
		mov al,[si]  ;moving the second decimal digit to al
		out 08h, al 	;moving the first digit into the port

						;A of 8255(2) which is connected to 7447
		mov al,00001000b
		out 0ah,al		;value is made displayed on fourth led
	    
             call delay1
        
        mov al,00000000b
		out 0ah,al	
	 
		jmp start

 

delay_ms proc
mov dx,2200h
cc1:
dec dx
JNZ cc1
ret
endp

delay_1ms proc
mov dx,2200h
cc2:
dec dx
JNZ cc2
ret
endp
delay_3s proc;8086 clock of 5Mhz
mov dx,0FFFFh
cc :
dec dx
JNZ cc
ret
endp
;end

sub1:	  push      cx
          mov		cx,10 ; delay generated will be approx 0.45 secs
x3:		  loop		x3 
          pop       cx
		  ret

delay1    proc   near 
          
          push cx 
          mov cx,1
      ps1: nop 
          loop ps1 
          pop cx 
          ret 
delay1    endp  


ad_isr:
mov al,00001000b
out 04h,al
in al,00h
mov [si],al
inc si
iret     

org 1000h
inp1 db dup(0)
inp2 db dup(0)
inp3 db dup(0)
outp11 dw dup(0)
outp12 dw dup(0) ; rem in higher byte
outp21 dw dup(0)
outp22 dw dup(0)
outp31 dw dup(0)
outp32 dw dup(0)
finalrem dw dup(0) 
avgquo dw dup(0)
avgdec dw dup(0)
tens db dup(0)
units db dup(0)
dec1 dw dup(0)
dec2 dw dup(0)
dec3 dw dup(0) 
sw db dup(0)
