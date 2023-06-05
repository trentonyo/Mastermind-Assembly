TITLE Mastermind			(AddTwo.asm)

; Author(s) : Trenton Young
; Course / Project ID  CS 271 / Final Project
; Description: Play Mastermind! The classic codebreaker game!


INCLUDE Irvine32.inc

; (insert constant definitions here)
TRUE = 1
FALSE = 0

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
ENDM

.data

; (Graphics)                Define any ASCII art strings here

GUI_gameboard_A             BYTE        "     |>-~-~-~-~-~-~-~-~-~-~-<|                                   ", CR, LF, 0
GUI_gameboard_B             BYTE        "#####|  M A S T E R M I N D  |###################################", CR, LF, 0
GUI_gameboard_C             BYTE        "#    |_______________________|                       #          #", CR, LF, 0
GUI_gameboard_DE            BYTE        "#     ..      ..      ..      ..      ..      ..     #          #", CR, LF, 0
GUI_gameboard_SPACE         BYTE        "#                                                    #          #", CR, LF, 0  ; Line will be repeated
GUI_gameboard_PEG           BYTE        "#    [  ]    [  ]    [  ]    [  ]    [  ]    [  ]    #   [XX]   #", CR, LF, 0  ; Line will be repeated
GUI_gameboard_ACCENT        BYTE        "#    ----    ----    ----    ----    ----    ----    #          #", CR, LF, 0
GUI_gameboard_Z             BYTE        "#################################################################", 0

GUI_gameboard_pegs          BYTE        "-@", 0         ; ASCII for a game peg

GUI_feedback_hit            BYTE        "o", 0
GUI_feedback_blow           BYTE        "*", 0
GUI_feedback_none           BYTE        ".", 0

MAP_background_color        DWORD       red,            gray,           green,          blue,           yellow,         cyan,           magenta,        brown
MAP_text_color              DWORD       white,          white,          black,          white,          black,          black,          black,          white

; (Localizations)           Define any messages to be displayed here

greeting    				BYTE		"Let's play MASTERMIND!", CR, LF, 0

; (Gamestate)               Variables defining gameplay

current_round               BYTE        0

solution                    BYTE        CODE_LENGTH DUP(?)
game_matrix                 BYTE        CODE_LENGTH DUP(ROUNDS DUP(?))

.code
main PROC; (insert executable instructions here)


; --------------------------------------------------------
setup:
;
; Runs functions that set the environment to expected
; --------------------------------------------------------
finit
call        Randomize

; --------------------------------------------------------
gameplay:
;
; Runs the gameloop TODO contains test code right now
; --------------------------------------------------------

call        DrawNewGameboard

mGotoXY     7, 7
mPrint      GUI_gameboard_pegs

mGotoXY     1, 20

push        FALSE
push        TYPE solution
push        OFFSET solution
call        GenerateCode

call        ListenUser
call        CheckSimilar
exit; exit to operating system
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
    push    EBP
    push    EBP, ESP



    pop     EBP
    ret
CheckSimilar ENDP

END main
