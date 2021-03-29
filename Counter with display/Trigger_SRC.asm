    EQU breakpoint, #0xFFFFFFFF
    B   Main

IOswitchAddress DCD #0x80000200 ; Address to query the Switch IO component
                                ; (this IO address is predefined by the Debugger)

Main
    MOV  R1, #0         ; R1 is the ticks counter. Initialize to 0.

 ; for (R1 = 0; -1<R1<100; R1++ or R1-- depending on Switch state) {
TickAgain
    ; BCD-encoding [ same as your Fragment 1 soln ]
    DIV  R0 , R1 , #10  ; generate BCD digits (review DIV instruction in lab doc if needed)
    AND  R4 , R0, #0xFFFF  ; Store the tens digit in R4
    LSR  R12, R0, #16   ; Store the units digit in R12

    ; Detect current Switch IO component state
    LDR  R3, [IOswitchAddress]  ; load IOswitch address into R3
    LDR  R2, [R3]       ; read Switch state (0 or 1) into R2
    CMP  R2, #1         ; (0=increment ticks;  1=decrement ticks)
    BEQ  decrement

    ; Loop test [ same as your Fragment 1 soln ]    
    ADD  R1, R1, #1     ; Increment ticks count
    CMP  R1, #100       ; Under 100 ticks?
    BNE  TickAgain            ;  If so: tick again
    MOV  R1, #0         ;   else: reset counter to 0
    B  TickAgain        ;         then tick again
    
decrement
    ; insert complete instructions (with their respective operands)
    SUB R1, R1, #1      ; Decrement ticks count
    CMP R1, #0          ; Greater than or equal to 0 ticks?
    BGE TickAgain       ;   If so: tick again
    MOV R1, #99          ;    else: reset counter to 99
    B TickAgain         ;          then tick again
; } end for loop

    DCD breakpoint     ; Equivalent to DCD #0xFFFFFFFF
