    EQU breakpoint, #0xFFFFFFFF
    EQU endOfStack,  #0x800     
    B   Main

; All I/O addresses are predefined by the Debugger:
IOswitchAddress     DCD #0x80000200 ; Address to query the Switch IO component
IOhexControlAddress DCD #0x80000300 ; Address to toggle the Hex Display IO component on or off
IOhexDataAddress    DCD #0x80000301 ; Address to change the Hex Display values

; This subroutine needs to be called once to turn the Digit Displays on.
ToggleDisplayOn
    PUSH { R0, R1, R14 }
    LDR  R0, [ IOhexControlAddress ]; get Hex Display IO address
    MOV  R1, #0b11                  ; 2 bits on = turns both hex digit displays on
    STR  R1, [R0]                   ; Send the 2 bits control signal to the display
    POP  { R0, R1, R15 }                                    

Main
    MOV  R13, endOfStack ; initialize Stack Pointer
    MOV  R1 , #0         ; R1 is the ticks counter. Initialize to 0
    BL  ToggleDisplayOn ; Turn the Display on (once)
    
 ; for (R1 = 0; -1<R1<100; R1++ or R1-- depending on Switch state) {
TickAgain
    ; BCD-encoding [ same as your Fragment 1 soln ]
    DIV  R0 , R1 , #10      ; generate BCD digits (review DIV instruction in lab doc if needed)
    AND  R4 , R0,  #0xFFFF  ; Store the tens digit in R4
    LSR  R12, R0,  #16      ; Store the units digit in R12

    ; Format the decimal digits (R4, R12) for the Hex Display IO component    
    LSL  R6 , R4 , #4   ; shift the tens digits to second-least significant nybble
    ADD  R6 , R6, R12   ; combine both digits into R6's least significant byte 
                        ;   Bits 0-3: units digit.   Bits 4-7: tens digit.
    LDR  R3, [ IOhexDataAddress ]   ; load Hex Display data control address
    STR  R6, [R3]       ; display the formatted value
    
    ; Detect current Switch IO component state [from Fragment 2 solution]
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
