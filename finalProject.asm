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
    push        EDX

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
GUI_feedback_miss           BYTE        ".", 0

;                                       ~ pegs color palette                                                                     ~      ~ feedback color palette  ~
MAP_background_color        DWORD       red,        gray,       green,      blue,       yellow,     cyan,       magenta,    brown,      white,      white,      white
MAP_text_color              DWORD       white,      white,      black,      white,      black,      black,      black,      white,      black,      gray,       red
;                                       0           1           2           3           4           5           6           7           8 [miss]    9 [blow]    10 [hit]

; (Localizations)           Define any messages to be displayed here

greeting    				BYTE		"Let's play MASTERMIND!", CR, LF, 0

; (Gamestate)               Variables defining gameplay

current_round               BYTE        0

solution                    BYTE        CODE_LENGTH DUP(?)
game_matrix                 BYTE        CODE_LENGTH DUP(ROUNDS DUP(?))

; Hits and Blows            hits and blows will be stored in these variables
hits                        DWORD       ?
blows                       DWORD       ?
uArray                      DWORD       5, 10, 1, 2       ; user guesses
solArray                    DWORD       10, 5, 2, 1       ; peg positions?
helperVar1                  DWORD       ?
matches                     DWORD       ?                 ; inverse of blows

; Hits and Blows temporary helper variables   - feel free to delete after
msgHh1                      BYTE        "Comparing arrays", LF, 0
msgHh2                      BYTE        "User array: ", 0
msgHh3                      BYTE        LF, "Solution array: ", 0
msgHh4                      BYTE        LF, "hits: ", 0
msgHh5                      BYTE        LF, "blows: ", 0
msgSpace                    BYTE        " ", 0
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


; End of program steps
mGotoXY         1, 20

push            8
call            SetColorFromPalette

; comparing uArray and solArray - updates hits and blows
push            OFFSET solArray
push            OFFSET uArray
push            blows
push            hits
call            CheckSimilar
invoke EXITProcess, 0		; exit to operating system
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
CheckSimilar PROC
; Author:           Hla Htun
; Description:      Takes in two arrays along with 'hits' and 'blows' variable.
;                   Counts the number of indices with identical values between
;                   arrays (i.e. hits)
;                   Next, counts the number of values shared between arrays
;                   subtracts hits from blows and returns each value
;                   Finally updates the hits and blows variables
;
; Parameters:
;                   push OFFSET solArray        [20]
;                   push OFFSET uArray          [16]
;                   push blows                  [12]
;                   push hits                   [8]
;                   call
; Postconditions:   Returns the number of hits and blows
; -------------------------------------------------------- -
    push    EBP
    mPrint msgHh1
    mPrint msgHh2

    mov     ECX, 0
    PrintuArray:
        push ECX
        push OFFSET uArray
        push TYPE uArray
        call ArrayAt
        call WriteDec
        mov helperVar1, EAX
        mPrint msgSpace

        push ECX
        push OFFSET solArray
        push TYPE solArray
        call ArrayAt
        mov EBX, helperVar1
        cmp EBX, EAX
        JE isAHit
        JMP notAHit
        isAHit:
            add hits, 1

        notAHit:
            ; ECX => i
            ; EBX => j
            mov EBX, 0
            loop2ndArray:
                push EBX
                push OFFSET solArray
                push TYPE solArray
                call ArrayAt
                cmp EAX, helperVar1
                JE isAMatch
                cmp EBX, 3
                JE outOfisThisInArray
                add EBX, 1
                JMP loop2ndArray

            isAMatch:
                add matches, 1
                JMP outOfisThisInArray


        outOfisThisInArray:
            cmp ECX, 3
            JE outOfPrintuArray
            add ECX, 1
            JMP PrintuArray

outOfPrintuArray:

    mPrint msgHh3

    mov     ECX, 0
    PrintsolArray:
            push ECX
            push OFFSET solArray
            push TYPE solArray
            call ArrayAt
            call WriteDec
            mPrint msgSpace
            cmp ECX, 3
            JE outOfPrintsolArray
            add ECX, 1
            JMP PrintsolArray

outOfPrintsolArray:
    mPrint msgHh4

    ; update hits
    mov EAX, hits
    call WriteDec

    mPrint msgHh5

    mov EAX, matches
    sub EAX, hits
    call WriteDec

    pop     EBP
    ret
CheckSimilar ENDP

END main
