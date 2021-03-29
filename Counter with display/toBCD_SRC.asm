; Equate the word 'breakpoint' with the value 0xFFFFFFFF
 ; This is a directive for the Assembler pre-processor.
 ; Prior to assembly, the pre-processor will replace every 
 ; instance of the word 'breakpoint' with the value #0xFFFFFFFF.
 ; Why do this? a) Convenience: it's easier to remember and 
 ; type out 'breakpoint' than it is to type out the numeral
 ; #0xFFFFFFFF; and b) It improves code readability by clarifying
 ; the intention behind the seemingly arbitrary number 0xFFFFFFFF

    EQU breakpoint, #0xFFFFFFFF

Main
    MOV R1, #0          ; R1 is the ticks counter. Initialize to 0.

 ; for (R1 = 0; R1<100; R1++) {
TickAgain
    ; BCD-encoding
    DIV  R0 , R1 , #10  ; generate BCD digits (review DIV instruction in lab doc if needed)
    AND  R4 , R0, #0xFFFF  ; Store the tens digit in R4
    LSR  R12, R0, #16  ; Store the units digit in R12
    
    ; Loop test
    ADD  R1, R1, #1     ; Increment ticks count
    CMP  R1, #100       ; Under 100 ticks?
    BNE  TickAgain            ;  If so: tick again
    MOV  R1, #0         ;   else: reset counter to 0
    B  TickAgain            ;         then tick again
; } end for loop

    DCD breakpoint     ; Equivalent to DCD #0xFFFFFFFF
