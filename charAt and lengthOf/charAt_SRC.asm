    MOV R13, #0x800  ; initialize the stack pointer (points to end of Main Mem)
    B Main

ExampleString        ; start of packed string 
	DCD	#0x53595343	; ‘S’=0x53   ‘Y’=0x59   ‘S’=0x53   ‘C’=0x43
	DCD	#0x20333030
	DCD	#0x36210000	; 1st 00 is the null-terminator, 2nd 00 is just padding to fill the word

;  char   CharAt ( &( PackedString[] ), uint charIndex  )
;  accepts    R0 = address of PackedString[] (by reference), 
;             R1 = charIndex (by value)
;  returns    R0 = PackedString[ charIndex ]
CharAt
  PUSH {R1,R2,R3,R4, R14}    ; save registers (SYSC 3006 Register Preservation convention)

; ----   start of block copied from Fragment 1   ----

; R2 = offset to word containing indexed character
  LSR   R2, R1, #2		; divide index by 4
; R3 = word containing indexed character
  LDR   R3, [ R0, R2 ]
; R1 = offset of character within word R3  (offset = 0, 1, 2, or 3)
  AND   R1, R1, #3

; Need to shift character from current position to least significant byte  
;    That is: in a loop, shift the entire word 8 bits at a time until the
; 	      character reaches least significant byte
; R1 = number of digit shifts needed  
  MOV   R4, #3
  SUB   R1, R4, R1
  BEQ   DoneShiftLoop   ; if 0 shifts needed, then done shifting

; shift character into least significant byte
ShiftLoop
  LSR   R3, R3, #8
  SUB   R1, R1, #1
  BNE   ShiftLoop

DoneShiftLoop
; R3 now has indexed character in least significant byte, 
;   but may have additional characters in higher bits 
; R0 = indexed character with higher bits cleared
  AND   R0, R3, #255 

; ----   end of block copied from Fragment 1   ----
  POP {R1,R2,R3,R4, R15 }    ; restore registers and return (SYSC 3006 Register Preservation convention)


Main
  
; R2 will be used as a character index into ExampleString
; R2 = 0     
  MOV  R2, #0

; for ( R0 = CharAt( &(ExampleString), R2 ); R0 != null; R0 = CharAt( &(ExampleString), ++R2 ) )
TestFor
  ; Set up parameters before calling CharAt
  ; get address of ExampleString
	LEA  R0, [ ExampleString ]  ; Prepare R0 (i.e. the first parameter of CharAt() )
  ; get character index 
    MOV  R1, R2 		    ; Prepare R1 (i.e. the second parameter of CharAt() )
    
    BL   CharAt    		    ; R0 = CharAt( &(ExampleString), R2 )
    
    CMP  R0, #0	; if R0 = null (i.e. #0) ... then done for loop
    BEQ  DoneFor

    ADD  R2, R2, #1
    B    TestFor   ; get and test next char

DoneFor
; at this point, R2 contains the number of characters in ExampleString

  DCD  #0xFFFFFFFF		; stop

