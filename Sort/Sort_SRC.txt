    B    SkipOverVariables

; Arr3 is an array of 5 words
Arr_Size DCD   #5   
Arr  DCD  #9  ; first (0-th) element of Arr
     DCD  #-4
     DCD  #0
     DCD  #-8
     DCD  #6 
    
SkipOverVariables

   ; use R0 for address of Arr
   MOV  R0, Arr
   
   ; for ( i = 0; i < Arr_size; i++ )
   MOV  R1, #0    ; use R1 for i: initialize = 0
   LDR  R3, [ Arr_Size ]   ; use R3 for Arr_Size
   
test_outer
   CMP  R1, R3
   BGE  done_outer
   
   ; {  ; swap Arr[ i ] with smallest remaining in unsorted portion of array
   ; tempSmall = Arr[ i ]  ; initially assume first element is smallest remaining
   LDR  R4, [R0, R1]    ; use R4 as tempSmall
   
   ; for ( j = i + 1; j  < Arr_size; j++ )
   ADD  R2, R1, #1    ; use R2 for j: initialize 

test_inner
   CMP  R2, R3
   BGE  done_inner

   ; {  if ( Arr[ j ] <  tempSmall )
   LDR R5, [R0, R2 ]
   CMP  R4, R5
   BGE done_if 
       ; {   ; swap  Arr[ i ] and Arr[ j ]!
         
   STR R5, [ R0, R1 ] ; Arr[ i ] =  Arr[ j ]  
   STR R4, [ R0, R2 ]    ; Arr[ j ] = tempSmall
   MOV R4, R5       ; tempSmall = Arr[ i ]

       ; }
done_if 
   ; }   
  ADD  R2, R2, #1
  B    test_inner    ; done inner body
   
done_inner
; }  
  ADD  R1, R1, #1
  B    test_outer    ; done outer body

done_outer
   DCD  #0xFFFFFFFF    ; breakpoint instruction