                .ORIG   x3000
                ; Free Register
                AND     R2, R2, #0
                AND     R3, R3, #0
                AND     R4, R4, #0      
                AND     R5, R5, #0
                AND     R6, R6, #0   
                AND     R7, R7, #0
                ; Load starting username input address into R1
                LD     R1, USER_INPUT_ADDR
                
                ; Load username prompt address into R0
START1          LEA     R0, PROMPT_USER
                TRAP    x22
                BR      AGAIN

PROMPT_USER     .STRINGZ    "Please enter your username: "
USER_INPUT_ADDR .FILL       x329C

AGAIN           LD      R2, NEGENTER    ; load neg-enter
                TRAP    x20
                TRAP    x21
                ADD     R3, R0, R2      ; Check for enter key
                BRz     CONT
                STR     R0, R1, #0      ; Store input into username input
                ADD     R1, R1, #1      ; Increment input address
                ADD     R4, R4, #1      ; Increment the chars counter (length)
                ADD     R5, R4, #-16    ; Check for maximum length
                BRp     TOO_MANY_CHARS
                BR      AGAIN

TOO_MANY_CHARS  LEA     R0, LEN_WARNING
                TRAP    x22             ; Print message for too many char
                BR      CLEAR1
CLEARRET1       BR      START1
                
NEGENTER        .FILL   xFFF6       ; -x000A
LEN_WARNING     .STRINGZ "You have exceed the maximum 16 characters"

CONT            LD     R5, USERNAME1_ADDR
                LD     R2, USER_INDEX_ADDR
                LDR     R3, R2, #0
                ADD     R3, R3, #1
                STR     R3, R2, #0
                BR      FIND_USERNAME
RETURN1         ADD     R7, R7, #-1      ; R7 is the boolean expresion for if true
                BRz      CONT2           ; Branch to password asking
                
                
                LD     R5, USERNAME2_ADDR
                LD     R2, USER_INDEX_ADDR
                LDR     R3, R2, #0
                ADD     R3, R3, #1
                STR     R3, R2, #0
                BR      FIND_USERNAME
RETURN2         ADD     R7, R7, #-1      ; R7 is the boolean expresion for if true
                BRz      CONT2           ; Branch to password asking
                
                
                LD     R5, USERNAME3_ADDR
                LD     R2, USER_INDEX_ADDR
                LDR     R3, R2, #0
                ADD     R3, R3, #1
                STR     R3, R2, #0
                BR      FIND_USERNAME
RETURN3         ADD     R7, R7, #-1      ; R7 is the boolean expresion for if true
                BRz     CONT2           ; Branch to password asking
                BR      REPROMPT_USER

USERNAME1_ADDR  .FILL   x326E
USERNAME2_ADDR  .FILL   x327E
USERNAME3_ADDR  .FILL   x328D
USER_INDEX_ADDR .FILL   x329B

; Check if the username input is in the username database
FIND_USERNAME
                AND     R7, R7, #0  ; Free R7 use as boolean var
                AND     R3, R3, #0  ; Free R3
                ; Check if the length of the two is the same
                AND     R6, R6, #0
                ADD     R6, R6, R5
LOOP            LDR     R2, R6, #0  ; Load Usernamex into R2
                BRz     NEXT        ; Finish if done w/ string
                ADD     R3, R3, #1
                ADD     R6, R6, #1
                BR      LOOP
            
NEXT            NOT     R3, R3
                ADD     R3, R3, #1
                ADD     R3, R3, R4  ; Check if usernamex and username input is the same length
                BRz     CHECKING    ; Move to checking section if same legnth
                LD      R2, USER_INDEX_ADDR
                LDR     R3, R2, #0
                ADD     R6, R3, #-1
                BRz     RETURN1
                ADD     R6, R3, #-2
                BRz     RETURN2
                ADD     R6, R3, #-3
                BRZ     RETURN3
            
            
CHECKING        LD      R2, USER_INPUT_ADDR   ; Load start of username input address into R2
AGAIN1          LDR     R3, R2, #0  ; Load char of R2 into R3
                BRz     YES_FIND
                LDR     R6, R5, #0  ; Load char of R5 into R6
                NOT     R3, R3      ; Negate R3
                ADD     R3, R3, #1
                ADD     R3, R3, R6  ; Check if same char
                BRnp    NO_FIND
                ADD     R2, R2, #1  ; Increment username input address
                ADD     R5, R5, #1  ; increment usernamex address
                BR      AGAIN1

NO_FIND         LD     R2, USER_INDEX_ADDR
                LDR     R3, R2, #0
                ADD     R6, R3, #-1
                BRz     RETURN1
                ADD     R6, R3, #-2
                BRz     RETURN2
                ADD     R6, R3, #-3
                BRz     RETURN3
        
YES_FIND        ADD     R7, R7 , #1 ; Change boolean to true
                LD     R2, USER_INDEX_ADDR
                LDR     R3, R2, #0
                ADD     R6, R3, #-1
                BRz     RETURN1
                ADD     R6, R3, #-2
                BRz     RETURN2
                ADD     R6, R3, #-3
                BRZ     RETURN3
            

REPROMPT_USER   LD      R2, USER_INDEX_ADDR
                AND     R3, R3, #0
                STR     R3, R2, #0      ; Reset user_index
                LEA     R0, ERROR_MES1
                TRAP    x22             ; Print out error message
                AND     R0, R0, #0
                ADD     R0, R0, #10
                PUTc
                LD      R2, ERROR_COUNT_ADDR ; Load error count address into R2
                LDR     R3, R2, #0      ; Load error count value into R3
                ADD     R3, R3, #1      ; Add 1 each time enter wrong username
                STR     R3, R2, #0      ; Store the new value after increment
                ADD     R5, R3, #-3     ; Check if error is 3
                BRz     END_PROGRAM
                BR      CLEAR2           ; Jump to clear username clear subroutine
CLEARRET2       BR      START1
END_PROGRAM     LEA     R0, ERROR_MES2  
                TRAP    x22             ; Print out quiting message
                HALT

ERROR_COUNT_ADDR .FILL      x3290
ERROR_MES1      .STRINGZ    "Wrong username, please try again"
ERROR_MES2      .STRINGZ    "You have enter the username wrong 3 time, now quitting"


; Function to clear the username input from memory (R4 is the length of the input)
CLEAR1
                AND     R2, R2, #0
                STR     R2, R1, #0        ; Clear the value inside R1 location
                ADD     R1, R1, #-1     ; Decrement the counter
                ADD     R4, R4, #-1     ; Decrement the length
                BRp     CLEAR1
                BR      CLEARRET1

; Function to clear the username input from memory (R4 is the length of the input)
CLEAR2
                AND     R2, R2, #0
                STR     R2, R1, #0        ; Clear the value inside R1 location
                ADD     R1, R1, #-1     ; Decrement the counter
                ADD     R4, R4, #-1     ; Decrement the length
                BRp     CLEAR2
                BR      CLEARRET2                

CONT2           LD     R2, ERROR_COUNT_ADDR
                AND     R3, R3, #0
                STR     R3, R2, #0      ; Reset error counter
                LD      R1, PASS_INPUT_ADDR
                AND     R4, R4, #0

PASS_INPUT_ADDR .FILL   x32B5
START2          LEA     R0, PROMPT_PASS
                TRAP    x22
                BR      AGAIN2
                
PROMPT_PASS .STRINGZ    "Please enter your password: "

AGAIN2          LD      R2, NEGENTER2    ; load neg-enter
                TRAP    x20
                TRAP    x21
                ADD     R3, R0, R2
                BRz     CONT3
                BR      ENCRYPTED
ENCRYPRET       STR     R0, R1, #0
                ADD     R1, R1, #1
                ADD     R4, R4, #1
                ADD     R5, R4, #-16
                BRp     TOO_MANY_CHARS2
                BR      AGAIN2

NEGENTER2       .FILL   xFFF6       ; -x000A
TOO_MANY_CHARS2 LEA     R0, LEN_WARNING2
                TRAP    x22
                BR      CLEAR3
CLEARRET3       BR      START2

LEN_WARNING2    .STRINGZ "You have exceed the maximum 16 characters"

CLEAR3
                AND     R2, R2, #0
                STR     R2, R1, #0        ; Clear the value inside R1 location
                ADD     R1, R1, #-1     ; Decrement the counter
                ADD     R4, R4, #-1     ; Decrement the length
                BRp     CLEAR3
                BR      CLEARRET3 
; Function to encrypted the input char before storing                
ENCRYPTED
                LD      R2, SIXTYFIVE
                ADD     R3, R0, R2  ; Check if char is smaller than a (65)
                BRn     NON_CHAR    ; If yes then non_char
                LD      R2, NINTY   
                ADD     R3, R0, R2  ; Check if char is larger than z (90)
                BRp     NEXT2        ; If yes then not lowercase
                LD      R2, THIRTYTWO  
                ADD     R0, R0, R2  ; Change lowercase to uppercase by adding 20
                BR      ENCRYPRET
NEXT2           LD      R2, NINTYSEV 
                ADD     R3, R0, R2  ; Check if char is smaller than A (97)
                BRn     NON_CHAR    ; If yes then non char
                LD      R2, ONETWOTWO
                ADD     R3, R0, R2  ; Check if char is larger than Z (122)
                BRp     NON_CHAR    ; If yes then non char
                LD      R2, THIRTYTWO
                NOT     R2, R2
                ADD     R2, R2, #1
                ADD     R0, R0, R2      ; Change uppercase to lowercase by subtract 20
NON_CHAR        BR      ENCRYPRET

THIRTYTWO        .FILL   #32
SIXTYFIVE       .FILL   #-65
NINTY           .FILL   #-90
NINTYSEV        .FILL   #-97
ONETWOTWO       .FILL   #-122


CONT3           LD      R2, USER_INDEX
                ADD     R3, R2, #-1
                BRz     PASS1
                ADD     R3, R2, #-2
                BRz     PASS2
                ADD     R3, R2 #-3
                BRz     PASS3
PASS1           LEA     R5, PASSWORD1
                BR      FIND_PASSWORD
RETURN4         ADD     R7, R7, #-1
                BRz     PRINTING
                BR      REPROMPT_PASS
                
PASS2           LEA     R5, PASSWORD2
                BR      FIND_PASSWORD
RETURN5         ADD     R7, R7, #-1
                BRz     PRINTING
                BR      REPROMPT_PASS
                
PASS3           LEA     R5, PASSWORD3
                BR      FIND_PASSWORD
RETURN6         ADD     R7, R7, #-1
                BRz     PRINTING
                BR      REPROMPT_PASS

FIND_PASSWORD
                AND     R7, R7, #0
                AND     R3, R3, #0
                AND     R6, R6, #0
                ADD     R6, R6, R5
LOOP2           LDR     R2, R6, #0
                BRz     NEXT3
                ADD     R3, R3, #1
                ADD     R6, R6, #1
                BR      LOOP2
                
NEXT3           NOT     R3, R3
                ADD     R3, R3, #1
                ADD     R3, R3, R4
                BRz     CHECKING2
                LEA     R2, USER_INDEX
                LDR     R5, R2, #0
                ADD     R3, R5, #-1
                BRz     RETURN4
                ADD     R3, R5, #-2
                BRz     RETURN5
                ADD     R3, R5, #-3
                BRz     RETURN6
                
CHECKING2       LEA     R2, PASS_INPUT
AGAIN3          LDR     R3, R2, #0
                BRz     YES_FIND2
                LDR     R6, R5, #0
                NOT     R3, R3
                ADD     R3, R3, #1
                ADD     R3, R3, R6
                BRnp    NO_FIND2
                ADD     R2, R2, #1
                ADD     R5, R5, #1
                BRp     AGAIN3
                
NO_FIND2        LEA     R2, USER_INDEX
                LDR     R3, R2, #0
                ADD     R6, R3, #-1
                BRz     RETURN4
                ADD     R6, R3, #-2
                BRz     RETURN5
                ADD     R6, R3, #-3
                BRz     RETURN6

YES_FIND2       ADD     R7, R7, #1
                LEA     R2, USER_INDEX
                LDR     R3, R2, #0
                ADD     R6, R3, #-1
                BRz     RETURN4
                ADD     R6, R3, #-2
                BRz     RETURN5
                ADD     R6, R3, #-3
                BRz     RETURN6

REPROMPT_PASS
                LEA     R0, ERROR_MES3
                TRAP    x22
                AND     R0, R0, #0
                ADD     R0, R0, #10
                PUTc
                LEA     R2, ERROR_COUNT
                LDR     R3, R2, #0
                ADD     R3, R3, #1
                STR     R3, R2, #0
                ADD     R5, R3, #-3
                BRz     END_PROGRAM2
                BR      CLEAR4
CLEARRET4       BR      START2
END_PROGRAM2    LEA     R0, ERROR_MES4
                TRAP    x22
                HALT

CLEAR4
                AND     R2, R2, #0
                STR     R2, R1, #0        ; Clear the value inside R1 location
                ADD     R1, R1, #-1     ; Decrement the counter
                ADD     R4, R4, #-1     ; Decrement the length
                BRp     CLEAR4
                BR      CLEARRET4
ERROR_MES3      .STRINGZ    "Wrong password, please try again"
ERROR_MES4      .STRINGZ    "You have enter the password wrong 3 times, now quitting"

PRINTING        LEA     R1, HELLO

AGAIN4          LDR     R2, R1, #0
                BRz     NEXT4
                ADD     R1, R1, #1
                BR      AGAIN4
NEXT4           LEA     R2, USER_INPUT
LOOP3           LDR     R3, R2, #0
                BRz     DONE
                STR     R3, R1, #0
                ADD     R1, R1, #1
                ADD     R2, R2, #1
                BR      LOOP3

DONE            LEA     R0, HELLO
                TRAP    x22
                TRAP    x25
                HALT




USERNAME1   .STRINGZ    "panteater"
PASSWORD1   .STRINGZ    "PETER"     ; peter
USERNAME2   .STRINGZ    "qv"
PASSWORD2   .STRINGZ    "HELLOTHERE!"   ; hellothere!
USERNAME3   .STRINGZ    "EECS20"
PASSWORD3   .STRINGZ    "hAPPy"         ; HappY
ERROR_COUNT .FILL       #0
USER_INDEX  .FILL       #0
USER_INPUT  .BLKW       #25
PASS_INPUT  .BLKW       #25
HELLO       .STRINGZ    "Hello, "
            .BLKW       #25

.END