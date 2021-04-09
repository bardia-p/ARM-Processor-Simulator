    B   Main      ; Your last "Main" in SYSC3006. There will be cake.

;-----------------------------------------------------------------------;
;------------- INITIALIZATION & CONSTANTS SECTION ----------------------;
;-----------------------------------------------------------------------;
; ISR Vector Table  (Lecture 20 slide 53)
;   The Switch peripheral is device 6, as predefined by the Debugger 
;   System Memory Map. Note that we still need to allocate the rest of 
;   the unused vectors (set them to empty), because the Debugger will
;   query address 7 for the ISR that handles the Switch's interrupt 
;   signal (INT6).
v0 DCD            ; device 0 unused (triggered by INT0)
v1 DCD            ; device 1 unused (triggered by INT1)
v2 DCD            ; device 2 unused (triggered by INT2)
v3 DCD            ; device 3 unused (triggered by INT3) 
v4 DCD            ; device 4 unused (triggered by INT4)
v5 DCD            ; device 5 unused (triggered by INT5)
v6 DCD  SwitchISR ; device 6 SWITCH (triggered by INT6)
v7 DCD            ; device 7 unused (triggered by INT7)

; All IO addresses are predefined by the Debugger (see lab document/slides).
IObaseAddress DCD #0x80000000 ; Base IO Address (peripherals will offset from this)
EQU IOLED,             #0x100 ; Address offset to the LED peripheral
EQU IOswitch,          #0x200 ; Address offset to the Switch peripheral
EQU IOswitchIntEnable, #0x201 ; Address offset to enable Switch interrupts 
EQU IOswitchIntClear,  #0x202 ; Address offset to clear Switch interrupts
                              ;  (see Switch Interrupts pg.6 in lab document)
EQU IOhexControl,      #0x300 ; Address offset to the Hex Display control port
EQU IOhexData,         #0x301 ; Address offset to the Hex Display data port

EQU endOfStack, #0x800        ; initial SP value
EQU breakpoint, #0xFFFFFFFF ; breakpoint
LEDstate  DCD   #0          ; variable to store current LED state
                            ;   [The LED peripheral is a write-only device. So we
                            ;   can't query its current state like we did with
                            ;   the Switch. Instead, we'll use this LEDstate
                            ;   variable to keep track of the LED's state.]  	

;-----------------------------------------------------------------------;
;------------- SUBROUTINE DEFINITIONS SECTION --------------------------;
;-----------------------------------------------------------------------;
; void TurnDisplayOn()
; This subroutine needs to be called once to turn the Digit Displays on.
TurnDisplayOn
    PUSH { R1, R4, R14 }
    MOV  R1, #0b11             ; 2 bits on = turns both hex digit displays on
    LDR  R4, [IObaseAddress]   ; get base IO address
    STR  R1, [R4,IOhexControl] ; Send the 2 bits control signal to the display
    POP  { R1, R4, R15 }                                    

; void ClearLED()
; This subroutine clears the LED. Useful on startup.
ClearLED
    PUSH { R1, R4, R14 }
    MOV  R1, #0              
    LDR  R4, [IObaseAddress]           ; get base IO address
    STR  R1, [R4, IOLED]       ; Clear the LED peripheral
    STR  R1, [LEDstate]      ; Reset our LEDstate variable as well
    POP  { R1, R4, R15 }  

; void EnableSwitchInt()
; This subroutine enables interrupts from the Switch peripheral.
EnableSwitchInt
    PUSH { R1, R4, R14 }
    MOV  R1, #1              
    LDR  R4, [IObaseAddress]        ; get base IO address
    STR  R1, [R4, IOswitchIntClear] ; Clear any existing Switch interrupt
    STR  R1, [R4, IOswitchIntEnable]; Enable interrupts from Switch
    POP  { R1, R4, R15 }  

; void  DisplayCounter( uint Counter)
; This subroutine displays the content of parameter Counter.
;   parameter(s): R0 = Counter value to be displayed on HexDisplay
DisplayCounter
    PUSH { R1, R3, R4, R6, R12, R14 }
    ; BCD-encoding
    DIV  R1 , R0 , #10  ; generate BCD digits 
    AND  R4 , R1 , #0xF ; Store the tens digit in R4
    LSR  R12, R1 , #16  ; Store the units digit in R12
    ; Format the decimal digits (R4, R12) for the Hex Display IO component    
    LSL  R6 , R4 , #4   ; shift the tens digits to second-least significant nybble
    XOR  R6 , R6 , R12  ; combine both digits into R6's least significant byte 
                        ; Bits 0-3: units digit.   Bits 4-7: tens digit.
    LDR  R3, [IObaseAddress] ; get base IO Address
    STR  R6, [R3, IOhexData]  ; send R6 to the Hex Display peripheral
    POP  { R1, R3, R4, R6, R12, R15 }
    
; uint UpdateCounter (uint currentValue)
; This subroutine handles the counter update logic.
;   parameter(s):  R0 = current counter value (#0 to #99)
;   return:        R0 = updated counter value (#0 to #99)
UpdateCounter
    PUSH { R2, R3, R14 }
    ; Detect current Switch IO component state
    LDR  R3, [IObaseAddress]  ; load IOswitch address into a register
    LDR  R2, [R3, IOswitch]   ; read Switch state (0 or 1) 
    CMP  R2, #0         ; (0=increment;  1=decrement)
    BNE  decrement      
    ADD  R0, R0, #1     ; Increment ticks count
    CMP  R0, #100       ; Under 100 ticks?
    BLT  updateDone     ;   If so: update is done
    MOV  R0, #0         ;    else: reset counter to 0
    B    updateDone     ;          then update is done
decrement
    SUB  R0, R0, #1     ; Decrement ticks count
    CMP  R0, #0         ; Greater than or equal to 0 ticks?
    BGE  updateDone     ;   If so: update is done
    MOV  R0, #99        ;    else: reset counter to 99
    B    updateDone     ;          then update is done
updateDone              ; Counter update is done
    POP { R2, R3, R15 }

;-----------------------------------------------------------------------;
;--------- Interrupt Service Routine (ISR) SECTION ---------------------;
;-----------------------------------------------------------------------;
; void SwitchISR()
;   This ISR will handle an interrupt from the Switch peripheral (INT6).
;   We want it to toggle the LED
SwitchISR
    LDR R0, [LEDstate]      ; get current LED state (0=off, 1=on)
    NOT R0, R0;
    AND R0, R0, #0x1;            ; invert it (make up your own logic,
                            ;  as many/few instructions as you need)
    LDR R1, [IObaseAddress] ; get IO base address
    STR R0, [R1, IOLED]     ; set new LED state
    STR R0, [LEDstate]          ; update our LEDstate variable as well
    MOV R2, #0            
    STR R2,  [R1, IOswitchIntClear] ; clear the Switch interrupt signal
    RETI       ; done. Return from ISR (Lec 20 slide 57)
    
;-----------------------------------------------------------------------;
;------------------------ MAIN SECTION ---------------------------------;
;-----------------------------------------------------------------------;
Main
    MOV  R13, endOfStack ; initialize Stack Pointer
    MOV  R0, #0          ; R0 is the ticks counter. Initialize to 0 
    BL   ClearLED        ; Ensure LED is cleared on startup
    BL   TurnDisplayOn   ; Turn the Hex Display on (once)
    
    ; Enable Interrupts (Lecture 20 slide 65)
    BL   EnableSwitchInt ; Enable Interrupts from the Switch
    EI                  ; Enable Interrupts to the processor
    
; for (R0 = 0; -1<R0<100; R0++ or R0-- depending on Switch state) {
TickAgain
    BL  UpdateCounter    ; R0 = UpdateCounter(R0)
    BL  DisplayCounter   ; Display the updated value
    B   TickAgain        ; Loop indefinitely
; } end for loop

    DCD  breakpoint      ; The cake is a lie!
    
    
    
;                ,:/+/-
;                /M/              .,-=;//;-
;           .:/= ;MH/,    ,=/+%$XH@MM#@:
;          -$##@+$###@H@MMM#######H:.    -/H#
;     .,H@H@ X######@ -H#####@+-     -+H###@X
;      .,@##H;      +XM##M/,     =%@###@X;-
;    X%-  :M##########$.    .:%M###@%:
;    M##H,   +H@@@$/-.  ,;$M###@%,          -
;    M####M=,,---,.-%%H####M$:          ,+@##
;    @##################@/.         :%H##@$-
;    M###############H,         ;HM##M$=
;    #################.    .=$M##M$=
;    ################H..;XM##M$=          .:+
;    M###################@%=           =+@MH%
;    @#################M/.         =+H#X%=
;    =+M###############M,      ,/X#H+:,
;      .;XM###########H=   ,/X#H+:;
;         .=+HM#######M+/+HM@+=.
;             ,:/%XM####H/.
;                  ,.:=-.    

