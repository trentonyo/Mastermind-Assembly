 TITLE Mastermind			(AddTwo.asm)

; Author(s) : Trenton Young
; Course / Project ID  CS 271 / Final Project
; Description: Play Mastermind! The classic codebreaker game!


INCLUDE Irvine32.inc

; (insert constant definitions here)
TRUE = 1
FALSE = 0

HIT = 2
BLOW = 1
MISS = 0

CR = 13
LF = 10

USER_NAME_LEN = 24

ROUNDS = 8
CODE_LENGTH = 4

COLS = ROUNDS                       ; Semantic equivalents for the game array
ROWS = CODE_LENGTH                  ;

COLORS = 8                          ; Number of colored pegs the game uses


; --------------------------------------------------------
mPrint          MACRO str
; Author:       Trenton Young
; Description:  Basic wrapper for Irvine's WriteString
;
; Use:          Pass a string, not the OFFSET
; --------------------------------------------------------
    push        EDX

    mov         EDX, OFFSET str
    call        WriteString

    pop         EDX
ENDM

; --------------------------------------------------------
mArand          MACRO _low, _high, _target
; Author:       Trenton Young
; Description:  Random range from Irvine's WriteString,
;               output is stored in given register
;
; Use:          _low and _high may be literals, _target may
;               be a register
; --------------------------------------------------------
    push        EAX

    mov         EAX, _high
    sub         EAX, _low
    inc         EAX
    call        RandomRange
    add         EAX, _low

    mov         _target, EAX

    pop         EAX
ENDM

; --------------------------------------------------------
mArrayFlatten   MACRO _ROW, _COL, _baseAddress, _size, _rowSize, _target
; Author:       Trenton Young
; Description:  calculates address of index in 2D array given
;               row and column
;
; Use:          Address is stored in _target which may be
;               a register
; --------------------------------------------------------
    push        EAX
    push        EBX
    push        EDX

    mov         EAX, _ROW
    mov         EBX, _rowSize
    mul         EBX

    mov         EBX, _COL
    add         EAX, EBX

    mov         EBX, _size
    mul         EBX

    mov         EBX, _baseAddress
    add         EAX, EBX

    mov         _target, EAX

    pop         EDX
    pop         EBX
    pop         EAX
ENDM

; --------------------------------------------------------
mGotoXY         MACRO _x, _y
; Author:       Trenton Young
; Description:  Simple wrapper for Irvine Library's gotoxy,
;               does not preserve dl or dh
;
; Use:          Pass an X and Y value (0-indexed) to move
;               the cursor
; --------------------------------------------------------
    mov         dl, _x
    dec         dl
    mov         dh, _y
    dec         dh
    call        Gotoxy

    pop         EDX
ENDM

; --------------------------------------------------------
mPlacePeg       MACRO _x, _y, _color
; Author:       Trenton Young
; Description:  Draws a peg of the specified color at the
;               specified location
;
; Use:          Pass an X and Y value (0-indexed) and a color
;               code from the predefined palettes
; --------------------------------------------------------
    mGotoXY     _x, _y

    push        _color
    call        SetColorFromPalette

    mPrint      GUI_gameboard_pegs
ENDM

; --------------------------------------------------------
mPlaceFeedback  MACRO _x, _y, _feedback
; Author:       Trenton Young
; Description:  Simple wrapper for placing feedback pegs
;
; Use:          Pass an X and Y value (0-indexed) and a
;               value for the feedback (see PlaceFeedback PROC)
; --------------------------------------------------------
    push        _x
    push        _y
    push        _feedback
    call        PlaceFeedback
ENDM





.data

; (Graphics)                Define any ASCII art strings here

GUI_gameboard_A             BYTE        "     |>-~-~-~-~-~-~-~-~-~-~-<|                                                   ", CR, LF, 0
GUI_gameboard_B             BYTE        "#####|  M A S T E R M I N D  |###################################################", CR, LF, 0
GUI_gameboard_C             BYTE        "#    |_______________________|                                       #          #", CR, LF, 0
GUI_gameboard_DE            BYTE        "#     ..      ..      ..      ..      ..      ..      ..      ..     #          #", CR, LF, 0
GUI_gameboard_SPACE         BYTE        "#                                                                    #          #", CR, LF, 0  ; Line will be repeated
GUI_gameboard_PEG           BYTE        "#    [  ]    [  ]    [  ]    [  ]    [  ]    [  ]    [  ]    [  ]    #   [XX]   #", CR, LF, 0  ; Line will be repeated
GUI_gameboard_ACCENT        BYTE        "#    ----    ----    ----    ----    ----    ----    ----    ----    #          #", CR, LF, 0
GUI_gameboard_Z             BYTE        "#################################################################################", 0

GUI_gameboard_pegs          BYTE        "-@", 0         ; ASCII for a game peg

GUI_feedback_hit            BYTE        "o", 0
GUI_feedback_blow           BYTE        "*", 0
GUI_feedback_miss           BYTE        ".", 0

;                                       ~ pegs color palette                                                                     ~      ~ feedback color palette  ~
MAP_background_color        DWORD       red,        gray,       green,      blue,       yellow,     cyan,       magenta,    brown,      white,      white,      white
MAP_text_color              DWORD       white,      white,      black,      white,      black,      black,      black,      white,      black,      gray,       red
;                                       0           1           2           3           4           5           6           7           8 [miss]    9 [blow]    10 [hit]

; (Localizations)           Define any messages to be displayed here

greeting    				BYTE		"Let's play MASTERMIND!", CR, LF, 0
selectColor    				BYTE		"Select a color for a peg using the arrow keys, and press enter when done.", CR, LF, 0

; (Gamestate)               Variables defining gameplay

current_round               BYTE        0

solution                    BYTE        CODE_LENGTH DUP(?)
game_matrix                 BYTE        CODE_LENGTH DUP(ROUNDS DUP(?))

userArray                   DWORD       4 DUP(?)
currX                       DWORD       1
currIndex                   DWORD       0
.code
main PROC; (insert executable instructions here)


; --------------------------------------------------------
setup:
;
; Runs functions that set the environment to expected
; --------------------------------------------------------
finit
call            Randomize

push            8
call            SetColorFromPalette

; --------------------------------------------------------
gameplay:
;
; Runs the gameloop TODO contains test code right now
; --------------------------------------------------------

call            DrawNewGameboard

mPlacePeg       7, 7, 2
mPlacePeg       7, 9, 5
mPlacePeg       7, 11, 1
mPlacePeg       7, 13, 4

mPlaceFeedback  7, 4, HIT
mPlaceFeedback  8, 4, BLOW
mPlaceFeedback  7, 5, BLOW


push            FALSE
push            TYPE solution
push            OFFSET solution
call            GenerateCode

; push            OFFSET userArray
; call            ListenUser
; call            CheckSimilar

push            OFFSET userArray
call            GetUserCode
; End of program steps
mGotoXY         1, 20

push            8
call            SetColorFromPalette
exit                                    ; exit to operating system
main ENDP

; (insert additional procedures here)

; -------------------------------------------------------- -
DrawNewGameboard PROC
; Author:           Trenton Young
; Description:      Simply clears the screen and draws a new gameboard
;
; Preconditions:    Define global gameboard strings
; Postconditions:   Screen is cleared, new gameboard is written
; -------------------------------------------------------- -
push        ECX

call        Clrscr

mPrint      GUI_gameboard_A
mPrint      GUI_gameboard_B
mPrint      GUI_gameboard_C
mPrint      GUI_gameboard_DE
mPrint      GUI_gameboard_DE

mov         ECX, ROWS
_printPlayArea:
    mPrint      GUI_gameboard_SPACE
    mPrint      GUI_gameboard_PEG

    loop        _printPlayArea

mPrint      GUI_gameboard_ACCENT
mPrint      GUI_gameboard_SPACE
mPrint      GUI_gameboard_Z

pop         ECX

ret
DrawNewGameboard ENDP

; -------------------------------------------------------- -
GenerateCode PROC
; Author:           Trenton Young
; Description:      Generates a code of the length defined by the
;                   const CODE_LENGTH, if TRUE is passed as a
;                   parameter, will allow duplicates
;
; Parameters:       push TRUE/FALSE * optional
;                   push TYPE target
;                   push OFFSET target
;                   call
;
; Preconditions:    Define global const CODE_LENGTH
; Postconditions:   Target will contain the new code
; -------------------------------------------------------- -
push        EBP
mov         EBP, ESP    ; register-indirect initialization

push        EAX
push        EBX
push        ECX
push        EDX

_stackFrame:
    mov     ECX, CODE_LENGTH
    mov     EDX, [EBP + 16]         ; [OPTIONAL] if TRUE, will allow duplicates in code
    mov     EBX, [EBP + 12]         ; TYPE of target array
    mov     EAX, [EBP + 8]          ; OFFSET of target array

_generateCode:
    push    ECX                     ; Preserve loop counter

    mArand  1, COLORS, ECX          ; Get a random number and store to EDX

    cmp     EDX, TRUE
    je     _allowDuplicates

    ; ELSE, check if random number is already in code
    mov     EDX, ECX                ; EDX is now random number
    pop     ECX                     ; ECX is loop counter again

    ; TODO check code, can probably somehow use the code checking proc that needs to be written for gameplay

    push    ECX                     ; _allowDuplicates expects a floating loop counter
    mov     ECX, EDX                ; and for the random number to be stored in ECX
    mov     EDX, FALSE              ; reset EDX to FALSE, it was overwritten in this process and we know it to be false
    _allowDuplicates:
    mov     [EAX], ECX              ; Store in next index

    pop     ECX                     ; restore loop counter

    add     EAX, EBX                ; Increment index

    loop    _generateCode

pop         EDX
pop         ECX
pop         EBX
pop         EAX
pop         EBP

ret         12
GenerateCode ENDP


; -------------------------------------------------------- -
ArrayAt PROC
; Author:           Trenton Young
; Description:      Gets the nth element from an array and stores
;                   it in EAX
;
; Parameters:       push n
;                   push OFFSET array
;                   push TYPE array
;                   call
;
; Postconditions:   EAX will contain the value of array[n]
; -------------------------------------------------------- -
push                EBP
mov                 EBP, ESP

push                EBX
push                ECX
push                EDX

_stackFrame:
    mov             EAX, [EBP + 16]         ; n
    mov             EBX, [EBP + 12]         ; OFFSET array
    mov             ECX, [EBP + 8]          ; TYPE array

mul                 ECX                     ; Multiply n by the type of the array
add                 EBX, EAX                ; Get to array[n]
mov                 EAX, [EBX]              ; Save the value of array[n] to EAX

pop                 EDX
pop                 ECX
pop                 EBX

pop                 EBP

ret 12
ArrayAt ENDP


; -------------------------------------------------------- -
SetColorFromPalette PROC
; Author:           Trenton Young
; Description:      Sets the text color to predefined palette
;
; Parameters:       push n
;                   call
;
; Preconditions:    Parallel arrays for text and background colors
; Postconditions:   Text color is changed
; -------------------------------------------------------- -
push                EBP
mov                 EBP, ESP

push                EAX
push                EBX
push                ECX

_stackFrame:
    mov             ECX, [EBP + 8]          ; n

; Get the nth element of the background colormap
push                ECX
push                OFFSET MAP_background_color
push                TYPE MAP_background_color
call                ArrayAt

; Multiply by 16 to shift to background position
mov                 EBX, 16
mul                 EBX

; Preserve background in EBX
mov                 EBX, EAX

; Get the nth element of the foreground colormap
push                ECX
push                OFFSET MAP_text_color
push                TYPE MAP_text_color
call                ArrayAt

; Add the background mask back on to EAX
add                 EAX, EBX

; Finally, set the color
call                SetTextColor

pop                 ECX
pop                 EBX
pop                 EAX

pop                 EBP

ret 4
SetColorFromPalette ENDP

; -------------------------------------------------------- -
ListenUser PROC
; Author:           Hla Htun
; Description:      Takes in 4 user input and stores it in the array
;
; Parameters:
;                   push OFFSET userArray
;                   push TYPE userArray
;                   call
; Preconditions:    An array as a parameter to store the 4 user inputs
; Postconditions:   None. The array passed will be updated with the user input
; -------------------------------------------------------- -
    ; call readDec
    ; store to array

    ; loop until 4
    push EBP
    mov EBP, ESP
    pushad


    mov EDI, [EBP+8]
    mov ECX, 4
    askUser:
        call ReadInt
        mov [EDI], EAX
        cmp ECX, 0
        ;JE outOfAskUser
        sub ECX, 1
        JMP askUser

    popad
    pop EBP
    ret
ListenUser ENDP

; -------------------------------------------------------- -
CheckSimilar PROC
; Author:           Hla Htun
; Description:      Takes in two arrays. Counts the number of
;                   indices with identical values between arrays (i.e. hits)
;                   Next, counts the number of values shared between arrays
;                   subtracts hits from blows and returns each value
;
; Parameters:
;                   push OFFSET solArray
;                   push TYPE solArray
;                   push OFFSET userArray
;                   push TYPE userArray
;                   call
; Postconditions:   Returns the number of hits and blows, i.e. ret hits, blows
; -------------------------------------------------------- -
    ;push    EBP
    ;push    EBP, ESP



    ;pop     EBP
    ret
CheckSimilar ENDP

; --------------------------------------------------------
PlaceFeedback PROC
; Author:       Trenton Young
; Description:  Draws a feedback peg at the specified location.
;               Pass an X and Y value (0-indexed) and a number
;               coinciding with the level of feedback
;               - 0: miss
;               - 1: blow
;               - 2: hit
;
; Parameters:   PUSH x
;               PUSH y
;               PUSH feedback
;               call
;
; --------------------------------------------------------
push            EBP
mov             EBP, ESP

push            EAX
push            EBX
push            ECX
push            EDX

_stackFrame:
    mov         ECX, [EBP + 16]         ; x
    mov         EBX, [EBP + 12]         ; y
    mov         EAX, [EBP + 8]          ; feedback

_moveCursor:
    push        EAX

    mov         EAX, EBX                ; insert y
    dec         EAX                     ; shift back for 1-indexing
    mov         EBX, 256
    mul         EBX                     ; shift y to subregister AH

    add         EAX, ECX                ; insert x to subregister AL
    dec         EAX                     ; shift back for 1-indexing

    mov         EDX, EAX                ; move y to DH, x to DL

    call        GotoXY
    pop         EAX

cmp             EAX, HIT
je              _hit

cmp             EAX, BLOW
je              _blow

_miss:
    push        8
    call        SetColorFromPalette
    mPrint      GUI_feedback_miss
    jmp         _done
_blow:
    push        9
    call        SetColorFromPalette
    mPrint      GUI_feedback_blow
    jmp         _done
_hit:
    push        10
    call        SetColorFromPalette
    mPrint      GUI_feedback_hit
    jmp         _done

_done:

pop             EDX
pop             ECX
pop             EBX
pop             EAX

pop             EBP

ret 12
PlaceFeedback ENDP

; -------------------------------------------------------- -
GetUserCode PROC
; Author:           Brayden Aldrich
; Description:      Gets user inputs via arrow keys and the enter key,
;                   dynamically displays these choices, then stores desired color
;                   into userArray
;
; Parameters:       push OFFSET array
;                   call
;                   
;                   
;
; Postconditions:   Updated userArray
; -------------------------------------------------------- -
push            EBP
mov             EBP, ESP

push            EAX
push            EBX
push            ECX
push            EDX

_init_variables:
    mov             EDI, [EBP + 8]      ; Array offset 
    mGotoXY         1, 17               ; Move cursor to (1,17). This is where the directions will be
                                        ; displayed.
_string:
    mPrint          selectColor

mGotoXY         1, 19                   ; Move cursor to (1, 19). This is where user will see their current choice

;  loop until user inputs a code
_loop:
    mov             EAX, 50
    call            Delay
    call            ReadKey
    jz              _loop

movzx           EDX, DX                 ; move key press code to edx

cmp             EDX, 37                 ; left
je              _decrease
cmp             EDX, 40                 ; down
je              _decrease

cmp             EDX, 38                 ; up
je              _increase
cmp             EDX, 39                 ; right
je              _increase

cmp             EDX, 13                 ; enter
je              _enter

_increase:

add             ECX, 1                  ; increment color map
cmp             ECX, 8                  ; check if current index is too high
jge             _resetHigh
jmp             _getColorHigh   

    _resetHigh: 
    mov             ECX, 0              ; reset the color map to 0
    _getColorHigh:
    mov             EAX, currX          ; move the current x index into EAX so
    mPlacePeg       al, 19, ECX         ; mPlacePeg can use AL. Index will not reach AH 
                                        ; ^ User's previous choices are displayed (currX, 19)
jmp             _loop                   ; Loop until a new key press

_decrease:

cmp             ECX, 0
je              _resetLow
sub             ECX, 1
jmp             _getColorLow
    _resetLow:
    mov             ECX, 7              ; reset color to 7, looping to the top of the array
    _getColorLow:
    mov             EAX, currX          ; move current x index into EAX so it can be used in
    mPlacePeg       al, 19, ECX         ; mPlacePeg
                                        ; ^ User's previous choices are displayed (currX, 19)
jmp             _loop                   ; Loop until a new key press

_enter:
inc             currIndex               ; increment current index in userArray
cmp             currIndex, 4            ; check to see if it's over array limit
jge             _end
mov             [EDI], ECX              ; add color number into current index    
add             EDI, 4                  ; increment current index
mov             EAX, currX              ; move current x coordinate into eax
add             EAX, 5                  ; incease it by 5
mov             currX, EAX              ; store updated currX
jmp             _loop                   ; loop to get a new number


_end:                                   ; break out of loop and return

pop            EDX
pop            ECX
pop            EBX
pop            EAX
pop            EBP
ret 4
GetUserCode ENDP

END main
