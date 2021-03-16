   B    SkipOverVariables

   
Arr_Size  DCD #3  ; Arr is an array of 3 words
Arr
   DCD  #20       ; first (0-th) element of Arr = 20
   DCD  #-4       ; second (1-th) element of Arr = -4 
   DCD  #0        ; third (2-th) element of Arr = 0

SkipOverVariables
   MOV  R2, Arr          ; first element of the array is recorded in R2
   LDR  R3, [ Arr_Size ] ; Length of the array is recorded in R3
   CMP  R3, #0           ; Check to see if the length of the array is 0
   BEQ  Done             ; If it is end the program
   SUB  R3, R3, #1       ; Decrease the length of the array by one

Loop   
   LDR  R5, [R2, R3 ]    ; Grab the array element at R3 so R5 = Arr[R3]
   ADD  R5, R5, #10      ; Add 10 to R5 which is Arr[R3]
   STR  R5, [R2, R3]     ; Set R5 to Arr[R3] again so Arr[R3] = R5
   SUB  R3, R3, #1       ; Decrease R3 by 1
   BPL  Loop             ; If R3 is less than 0 end the loop

Done
   DCD  #0xFFFFFFFF     ; breakpoint instruction