 TITLE Mastermind			(finalProject.asm)

; Author(s) : Trenton Young, Hla Htun, Brayden, Cameron Kroeker
; Course / Project ID  CS 271 / Final Project
; Description: Play Mastermind! The classic codebreaker game!


INCLUDE Irvine32.inc

; (insert constant definitions here)
TRUE    = 1
FALSE   = 0

HIT     = 2
BLOW    = 1
MISS    = 0

CR = 13
LF = 10

USER_NAME_LEN = 24

ROUNDS      = 8
CODE_LENGTH = 4

COLS = ROUNDS                       ; Semantic equivalents for the game array
ROWS = CODE_LENGTH                  ;

COLORS = 8                          ; Number of colored pegs the game uses

OUT_OF_RANGE_1 = 100
OUT_OF_RANGE_2 = 200

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
; Description:  Random range [_low.._high] from Irvine's lib,
;               output is stored in given register
;
; Use:          _low (inclusive) and _high  (inclusive) may be
;               literals, _target may be a register
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

; --------------------------------------------------------
mIsArrayElementEqual  MACRO _iArray, _isEqual
; Author:       Hla Htun
; Description:  Checks if an array has all equal values
;
; Use:          Pass an array and a value to hold 0 or 1 (true or false)
;               for when an array has one same value in each index
; --------------------------------------------------------
    push 0
    push OFFSET _iArray
    push TYPE _iArray
    call ArrayAt
    mov EBX, EAX

    mov ECX, 1
    loopArraym:
        push ECX
        push OFFSET _iArray
        push TYPE _iArray
        call ArrayAt
        cmp EBX, EAX
        JNE isNotEqual
        cmp ECX, 3
        JE isEqual
        add ECX, 1
        mov EBX, EAX
        JMP loopArraym

    isEqual:
        mov _isEqual, 1
        JMP goBackNow

    isNotEqual:
        mov _isEqual, 0
        JMP goBackNow


    goBackNow:

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

YES                         BYTE        "y"
NO                          BYTE        "n"
greeting    				BYTE		"Let's play MASTERMIND, ", 0
exclamation                 BYTE        "!", LF, LF, 0
selectColor    				BYTE		"Select a color for a peg using the arrow keys, and press enter when done.", CR, LF, 0
invalidCharMsg              BYTE        "Invalid input, try again.", LF, 0

rules_placeholder           BYTE        "Them's the rules.", CR, LF, 0

prompt_rules                BYTE        "Would you like me to tell you the rules of MASTERMIND? (y/n)", 0
prompt_duplicates           BYTE        "Would you like to allow duplicates in the solution code?", CR, LF, "   WARNING: This significantly increases the challenge of the game. (y/n)", 0

; (Gamestate)               Variables defining gameplay

current_round               DWORD        0

solution                    DWORD       CODE_LENGTH DUP(OUT_OF_RANGE_2)
game_matrix                 DWORD       CODE_LENGTH DUP(ROUNDS DUP(?))
; Created for key inputs.Will hold current user's guess
user_guess                  DWORD       CODE_LENGTH DUP(OUT_OF_RANGE_1)

userHasWon                  DWORD       FALSE
allowDuplicates             DWORD       FALSE

; Hits and Blows            hits and blows will be stored in these variables
hits                        DWORD       0
blows                       DWORD       0
helperVar1                  DWORD       ?
T_HelperVar                 DWORD       ?
matches                     DWORD       ?

currX                       DWORD       7               ; Helper var for GetUserCode. Stores current X coordinate. FOR START OF GAME, SET TO 7 ; TODO can probably be calculated on the fly (from test phase) - Trenton Young
currY                       DWORD       7               ; Helper var for GetUserCode. Stores current Y coordinate. FOR START OF GAME, SET TO 7
currIndex                   DWORD       0               ; Helper var for GetUserCode. Will store current array index.

; Game Rules
RULES_1                     BYTE        CR, LF, "Rules:", CR, LF, 0
RULES_GAP                   BYTE        "    - ", 0
RULES_2                     BYTE        "The program randomly places 4 pegs in a certain order", CR, LF, 0
RULES_3                     BYTE        "Your goal is to guess the exact positions and colors of each of those pegs before you run out of attempts!", CR, LF, 0
RULES_4                     BYTE        "You'll make guesses by selecting colors from a choice of 8 (red, gray, green, blue, yellow, cyan, magenta, brown)", CR, LF, 0
RULES_5                     BYTE        "Use ( <- ) left or ( -> ) right arrow keys to switch between different color choices", CR, LF, 0
RULES_6                     BYTE        "Use Enter/Return key to confirm your choice", CR, LF, 0
RULES_7                     BYTE        "You can also ( ", 24, " ) up or ( " , 25, " ) down arrow keys to go back and forth between input fields", CR, LF, 0
RULES_8                     BYTE        "Correct guess (right color and position) also known as a 'hit' will be displayed as 'o'", CR, LF, 0
RULES_9                     BYTE        "Semi-correct guess (right color but not position) also known as a 'blow' will be displayed as '*'", CR, LF, 0
RULES_10                    BYTE        "Wrong guess also known as a 'miss' will be displayed as '.'", CR, LF, LF, 0

H_HelperVar1                DWORD       ?               ; Helper var for GameTurn (Place feedback loop counter)
H_HelperVar2                DWORD       ?               ; Helper var for GameTurn (Place feedback loop counter)
H_HelperVarX                DWORD       ?               ; Helper var for GameTurn - Holds the x coordinate for placing the feedback
H_HelperVarY                DWORD       ?               ; Helper var for GameTurn - Holds the y coordinate for placing the feedback
H_HelperVarMovY             DWORD       ?               ; Helper var for GameTurn - Helps decide whether to reset X to original position or not and increment Y by 1

hasWon                      DWORD       ?

Celebration                 BYTE        "   Great job! You correctly guessed the color and position of each of the pegs!", CR, LF, 0

Loser                       BYTE        "   Uh..oh! You've ran out of attempts :(", CR, LF, 0

prompt_tryAgain             BYTE        "   Would you like to try again? (y/n)", CR, LF, 0

farewell                    BYTE        LF, "Thank you for playing our game!" , LF, "Programmed by Trenton Young, Brayden Aldrich, Hla Htun and Cameron Kroeker", LF, LF, 0

prompt_userName             BYTE        "Please type your name: ", 0
userName                    BYTE        ?

;   FPU AND RECURSIVE REQUIREMENT STRINGS
REQ_question                BYTE        "Our game doesn't use the FPU or recursive procedures. Would you like to see two simple outputs for these? (y/n)", 0
REQ_moveon                  BYTE        "Press enter to move on...", 0
FPU_intro_string		    BYTE   	    LF, "Let's do some FPU addition to start.", CR, LF, LF, 0
FPU_getUserFirstNum 	    BYTE 	    "   Please type your first real number: ", 0
FPU_getUserSecNum 		    BYTE 	    "   Please type your second real number: ", 0
FPU_result 				    BYTE 	    LF, "   The sum of the two real numbers is: ", 0
REC_intro 				    BYTE 	    "Now let's recursively sum numbers!", CR, LF, LF, 0
REC_getN			        BYTE 	    "   Choose a number from [2-500]: ", 0
REC_n                       DWORD       ?
REC_final                   BYTE        LF, "   Using recursion, I found that the sum is: ",0
REC_answer				    DWORD 	    ?


.code
main PROC; (insert executable instructions here)

; --------------------------------------------------------
FPUandREC:
;
;   There are 2 functions:
;   1) Get 2 real numbers from user and do an FPU addition
;   2) Get a number from the user and sum all numbers up to desired number
;
; --------------------------------------------------------
    pushad
    push            OFFSET REQ_question
    call            PromptMsg
    cmp             EAX, FALSE                      ; check if user doesn't wanna see this
    je              _end

    
    call            AddFPU                          ; Call AddFPU proc

    mPrint          REC_intro                       
    ; Get a valid number from user
    start:                                          
        mPrint          REC_getN
        call            Readint
        cmp             EAX, 2
        jl              _invalid
        cmp             EAX, 500
        jg              _invalid
        jmp             _valid
    _invalid:

        mPrint          invalidCharMsg
        jmp             start

    _valid:
        mov             REC_n, EAX                  
        mov             EAX, 0
        mov             ECX, REC_n  
        call            RSum                        ; Using the EAX and ECX recursively sum the numbers    
        mPrint          REC_final
        call            Writedec
        call            Crlf
        call            Crlf
        mPrint          REQ_moveon
    ; loop until user hits the enter key
    _l:
        mov         EAX, 50
        call        Delay
        call        ReadKey
        jz          _l

    movzx           EDX, DX
    cmp             EDX, 13
    je              _end
    jmp             _l
    
    _end:
    popad



; --------------------------------------------------------
ProgramSetup:
;
; Runs functions that set the environment to expected parameters,
; seeds the random number generator, initiates the FPU, sets the
; text and background color
; --------------------------------------------------------
    finit
    call            Randomize

    push            8
    call            SetColorFromPalette


InitialGreeting:
;
; Prompts the user for their name then greets them
; --------------------------------------------------------
    call            Clrscr
    call            getName
; --------------------------------------------------------
PromptForRules:
;
; Prompts the user asking if they would like the rules of the
; game to be displayed
; --------------------------------------------------------

    push            OFFSET prompt_rules
    call            PromptMsg

;   If the user does not want the rules displayed
    call            Crlf
    cmp             EAX, FALSE
    je              NewGamestate
    JMP             DisplayRules

; --------------------------------------------------------
DisplayRules:
; Author: Hla Htun
; Prints the rules of the game and then waits for the user to
; press a key before continuing, to give them a chance to read
; --------------------------------------------------------
    mPrint      OFFSET RULES_1
    mPrint      OFFSET RULES_GAP
    mPrint      OFFSET RULES_2
    mPrint      OFFSET RULES_GAP
    mPrint      OFFSET RULES_3
    mPrint      OFFSET RULES_GAP
    mPrint      OFFSET RULES_4
    mPrint      OFFSET RULES_GAP
    mPrint      OFFSET RULES_5
    mPrint      OFFSET RULES_GAP
    mPrint      OFFSET RULES_6
    mPrint      OFFSET RULES_GAP
    mPrint      OFFSET RULES_7
    mPrint      OFFSET RULES_GAP
    mPrint      OFFSET RULES_8
    mPrint      OFFSET RULES_GAP
    mPrint      OFFSET RULES_9
    mPrint      OFFSET RULES_GAP
    mPrint      OFFSET RULES_10

    call        WaitMsg
    call        Clrscr
; --------------------------------------------------------
; If the user has won the game, then they may allow for duplicates
; in the solution code
NewGameState:
; Allow the user to choose if they want to allow duplicate
; colors in the code, let user know that there may be more
; than two of any given color if they agree.
; Also resets variables to its initial state
    mov             H_HelperVar1, 0
    mov             H_HelperVar2, 0
    mov             H_HelperVarX, 7
    mov             H_HelperVarY, 4
    mov             H_HelperVarMovY, 0
    mov             hasWon, 0
    mov             currX, 7
    mov             currY, 7
    mov             currIndex, 0

    push            OFFSET prompt_duplicates
    call            PromptMsg

    ; Store the user's decision
    mov             allowDuplicates, EAX

; --------------------------------------------------------
GenerateGamestate:
;
; Print a new gameboard, set the round to zero, and generate a new
; solution code
; --------------------------------------------------------

    call            DrawNewGameboard
    mov             current_round, 0

    push            allowDuplicates
    push            TYPE solution
    push            OFFSET solution
    call            GenerateCode


; --------------------------------------------------------
mov                 ECX, ROUNDS
GameTurn:
; Authors: Hla Htun, Brayden
; Get the user's input, check against the solution, give the
; user feedback, and repeat until the user is out of turns or
; guesses the solution
; --------------------------------------------------------

    ; Get input from the user
    push            OFFSET user_guess
    call            GetUserCode

    ; Check the user's move against solution
    push            OFFSET blows
    push            OFFSET hits
    call            CheckSimilar

    ; Draws feedbacks
    push            ECX
    call            PlaceFeedbackGameTurn

    ; Debug for PlaceFeedbackGameTurn and CheckSimilar
    ;mGotoXY         1, 25
    ;call            debugHH

    cmp             hits, 4
    JE              WinnerCelebration

    cmp             current_round, 7
    JE              LoserAdmonishment

    ; If no endgame conditions are met, the user takes another turn
    inc             current_round
    add             currX, 8
    mov             currIndex, 0
    loop            GameTurn


; --------------------------------------------------------
WinnerCelebration:
; Author: Hla Htun
; Notify the user that they have won
; --------------------------------------------------------
    mGotoXY     1, 19
    mPrint      Celebration
    mov         hasWon, TRUE
    JMP         PromptForPlayAgain
; --------------------------------------------------------
LoserAdmonishment:
; Author: Hla Htun
; Notify the user that they are a loser
; --------------------------------------------------------
    call PrintSolution
    mGotoXY     1, 19
    mPrint      Loser
    JMP         PromptForPlayAgain

; --------------------------------------------------------
PromptForPlayAgain:
; Author: Hla Htun
; Prompt the user to play the game again
; --------------------------------------------------------
    push        OFFSET prompt_tryAgain
    call        PromptMsg

    cmp         EAX, TRUE
    JE          ProgramSetup

_Farewell:
    mPrint      farewell

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
; Postconditions:   Target will contain the new code,
;                   user_guess and solution will be mutated
; -------------------------------------------------------- -
push        EBP
mov         EBP, ESP    ; register-indirect initialization

push        EAX
push        EBX
push        ECX
push        EDX

mov         EAX, 0
mov         ECX, CODE_LENGTH
mov         T_HelperVar, 0
;inc         ECX

_clearCheckArrays:
    mov     user_guess[EAX], OUT_OF_RANGE_1
    mov     solution[EAX], OUT_OF_RANGE_2

    add     EAX, TYPE user_guess
    loop    _clearCheckArrays

    mov     T_HelperVar, 0            ; initialize index accumulator

_stackFrame:
    mov     ECX, CODE_LENGTH
    mov     EDX, [EBP + 16]         ; [OPTIONAL] if TRUE, will allow duplicates in code
    mov     EBX, [EBP + 12]         ; TYPE of target array
    mov     EAX, [EBP + 8]          ; OFFSET of target array

_generateCode:
    mov     EDX, [EBP + 16]         ; Reclaim the duplicate flag
    push    ECX                     ; Preserve loop counter

    push    EAX
    mov     EAX, COLORS
    dec     EAX
    mArand  0, EAX, ECX             ; Get a random number and store to ECX
    pop     EAX

    cmp     EDX, TRUE
    je     _allowDuplicates

    ; ELSE, check if random number is already in code
    mov     EDX, ECX                ; EDX is now random number
    pop     ECX                     ; ECX is loop counter again

    _checkCode:
        mov             user_guess[0], EDX      ; Store the current candidate in user_guess[0]

        ; comparing user_guess(candidate, index, ?, ?) and solution(accepted codes) elements - updates hits and blows
        push            OFFSET blows
        push            OFFSET hits
        call            CheckSimilar

        cmp             hits, 0
        jg              _generateCode
        cmp             blows, 0
        jg              _generateCode       ; check if the candidate has already been selected, run generate code over if so

        push            EBX
        mov             EBX, T_HelperVar
        mov             solution[EBX], EDX  ; store the accepted candidate in the next slot of the solution array
        pop             EBX

        push            EAX
        mov             EAX, TYPE user_guess
        add             T_HelperVar, EAX    ; increment index accumulator
        pop             EAX


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
; Author:           Hla Htun (Trenton Young made small contribution)
; Description:      Uses two arrays along with 'hits' and 'blows' variable.
;                   Counts the number of indices with identical values between
;                   arrays (i.e. hits)
;                   Next, counts the number of values shared between arrays
;                   subtracts hits from blows and returns each value
;                   Finally updates the hits and blows variables
;
; Parameters:
;                   push OFFSET blows       [12]
;                   push OFFSEt hits        [8]
;                   call
;
; Preconditions:    Must have user_guess and solution as global variables
;                   Both of the arrays must have a size of 4
;                   Additional global variables needed:
;                   helperVar1, matches
;
; Postconditions:   Returns the number of hits and blows
; -------------------------------------------------------- -
    push    EBP
    mov     EBP, ESP

    push    EAX
    push    EBX
    push    ECX

    mov     EAX, 0
    mov     EBX, [EBP + 8]
    mov     [EBX], EAX      ; initializing hits variable
    mov     EBX, [EBP + 12]
    mov     [EBX], EAX      ; initializing blows variable
    mov     matches, EAX

    ; two loop counters
    ; ECX => i
    ; EBX => j
    mov     ECX, 0
    PrintUserGuess:
        push    ECX
        push    OFFSET user_guess
        push    TYPE user_guess
        call    ArrayAt
        mov     helperVar1, EAX

        push    ECX
        push    OFFSET solution
        push    TYPE solution
        call    ArrayAt
        mov     EBX, helperVar1
        cmp     EBX, EAX
        JE      isAHit
        JMP     notAHit
        isAHit:
            add hits, 1
            JMP outOfisThisInArray

        notAHit:
            mov     helperVar1, EAX
            mov     EBX, hits
            loop2ndArray:
                push    EBX
                push    OFFSET user_guess
                push    TYPE user_guess
                call    ArrayAt
                cmp     EAX, helperVar1
                JE      isAMatch
                cmp     EBX, 3
                JE      outOfisThisInArray
                add     EBX, 1
                JMP     loop2ndArray

            isAMatch:
                add     matches, 1
                JMP     outOfisThisInArray


        outOfisThisInArray:
            cmp     ECX, 3
            JE      outOfPrintUserGuess
            add     ECX, 1
            JMP     PrintUserGuess

outOfPrintUserGuess:
    mov     EBX, [EBP + 8]
    mov     EAX, hits
    mov     [EBX], EAX      ; saving to hits variable

    mov     EAX, matches

    mov     EBX, [EBP + 12]
    mov     [EBX], EAX      ; saving to blows variable

    pop     ECX
    pop     EBX
    pop     EAX

    pop     EBP
    ret     8
CheckSimilar ENDP


; -------------------------------------------------------- -
PrintSolution PROC
; Author:           Cameron Kroeker (Trenton Young made small contribution)
; Description:      Prints the solution pegs into the [xx] spot on the table
;
; Parameters:
;
; Preconditions: Must have solution Array filled with at least 4 bytes. Gameboard must be printed before PROC is called.
; Postconditions:  Color is set to white, EAX is set to 0.
; -------------------------------------------------------- -
push    EAX
push    EDI

mov EDI, 0              ; Set EDI to 0

    ; Print the value stored in list[0]

mov EAX, solution[EDI]
mPlacePeg       75, 7, EAX

mov EAX, solution[EDI+4]
mPlacePeg       75, 9, EAX

mov EAX, solution[EDI+8]
mPlacePeg       75, 11, EAX

mov EAX, solution[EDI+12]
mPlacePeg       75, 13, EAX

;Set color back to White
push            8
call            SetColorFromPalette


mov EAX, 0

pop     EDI
pop     EAX

ret
PrintSolution ENDP


; -------------------------------------------------------- -
GetUserCode PROC
; Author:           Brayden Aldrich
; Description:      Gets user inputs via arrow keys and the enter key,
;                   dynamically displays these choices, then stores desired color
;                   into user_guess
;
; Helper Variables: currX, currIndex, user_guess
;
; Parameters:       push OFFSET array
;                   call
;
; Postconditions:   Updated user_guess
; -------------------------------------------------------- -
push            EBP
mov             EBP, ESP

push            EAX
push            EBX
push            ECX
push            EDX

_init_variables:
    mov             EDI, [EBP + 8]      ; Array offset
    mGotoXY         1, 17               ; Move cursor to (1,17). This is where the directions will be displayed.
    mov             ECX, 0
    mov             [EDI], ECX
    mov             [EDI + 4], ECX
    mov             [EDI + 8], ECX
    mov             [EDI + 12], ECX


_string:
    mPrint          selectColor

; Initialize the screen and ECX to show a color before the user hits the arrow keys.
_preloop:

mov             EBX, currY              ; init current y
mov             EAX, currX              ; init current x
mov             ECX, [EDI]
mPlacePeg       al, bl, ECX             ; place peg on coordinate

;  loop until user inputs a code

_loop:
    mov             EAX, 50
    call            Delay
    call            ReadKey
    jz              _loop

movzx           EDX, DX                 ; move key press code to edx
cmp             EDX, 37                 ; left
je              _decrease



cmp             EDX, 39                 ; right
je              _increase

cmp             EDX, 13                 ; enter
je              _enter

cmp             EDX, 40                 ; down
je              _enter

cmp             EDX, 38                 ; up
je              _up

cmp             EDX, 8                  ; backspace
je              _up

_increase:

add             ECX, 1                  ; increment color map
cmp             ECX, 8                  ; check if current index is too high

jge             _resetHigh
jmp             _getColorHigh

    _resetHigh:
    mov             ECX, 0              ; reset the color map to 0
    _getColorHigh:
    mov             EAX, currX          ; move the current x index into EAX so mPlacePeg can use AL
    mov             EBX, currY          ; move current y index into EBX so mPlacePeg can use BL
    mPlacePeg       al, bl, ECX
    mov             [EDI], ECX          ; mov current color into array[n]

jmp             _loop                   ; Loop until a new key press

_decrease:

cmp             ECX, 0
je              _resetLow
sub             ECX, 1
jmp             _getColorLow
    _resetLow:
    mov             ECX, 7              ; reset color to 7, looping to the top of the array
    _getColorLow:
    mov             EAX, currX          ; move current x index into EAX so it can be used in mPlacePeg
    mov             EBX, currY          ; move current y index to EBX to be used in mPlacePeg
    mPlacePeg       al, bl, ECX
    mov             [EDI], ECX          ; mov current color into array[n]

jmp             _loop                   ; Loop until a new key press

_enter:

cmp             currIndex, 3            ; Check if 4th peg
je              _onlyEnter              ; jump to check if downkey pressed
jmp             _break                  ; else continue on
_onlyEnter:
    cmp             EDX, 40             ; Check if downkey was pressed
    je              downKey             ; if so, jump to downKey
    jmp             _break              ; else continue on
    downKey:
        jmp             _preloop        ; jump to preloop to avoid accidental downkey entering users code
_break:

add             EDI, 4                  ; increment current index
mov             EAX, currY              ; move current y coordinate into eax
add             EAX, 2                  ; incease it by 2
mov             currY, EAX              ; store updated currY

inc             currIndex               ; increment current index in user_guess
cmp             currIndex, 4            ; check to see if it's over array limit
jge             _end
jmp             _preloop                ; loop to get a new number

_up:
    mov         EAX, currY
    cmp         EAX, 7                  ; compare current y coord with 7. If it's 7, just go back to looping.
    je          _loop
    sub         EAX, 2                  ; subtract 2 from currY to get to peg above currY
    mov         currY, EAX
    sub         EDI, 4                  ; move array pointer back to previous entry
    mov         EAX, currIndex
    sub         EAX, 1                  ; subtract 1 from currIndex
    mov         currIndex, EAX
    jmp         _preloop                ; go to preloop


_end:                                   ; break out of loop and return
push            8
call            SetColorFromPalette     ; set color back to white

mov             currY, 7                ; reset currY for next round
mov             EAX, currX              ; set currX to currX + 8 to get next round x coordinate
add             EAX, 8

pop             EDX
pop             ECX
pop             EBX
pop             EAX
pop             EBP
ret 4
GetUserCode ENDP


; -------------------------------------------------------- -
PromptMsg PROC
; Author:           Trenton Young
; Description:      Gets the user's input in the form of text
;                   input and then stores the corresponding
;                   boolean value in EAX
;
; Parameters:       push OFFSET message
;                   call
;
; Postconditions:   EAX will contain the TRUE or FALSE
; -------------------------------------------------------- -
push                EBP
mov                 EBP, ESP

push                ECX
push                EDX

_stackFrame:
    mov             EDX, [EBP + 8]          ; OFFSET message

call                WriteString
call                Crlf

jmp _endInvalid
_invalid:
    ; Set to error message color
    push            10
    call            SetColorFromPalette

    mov             EDX, OFFSET invalidCharMsg
    call            WriteString
    call            Crlf

    push            8
    call            SetColorFromPalette
_endInvalid:

call                ReadChar

movzx               EDX, YES
movzx               ECX, AL
cmp                 EDX, ECX
je                  _true

movzx               EDX, NO
movzx               ECX, AL
cmp                 EDX, ECX
je                  _false

jmp                 _invalid

_true:
    mov             EAX, TRUE
    jmp             _end

_false:
    mov             EAX, FALSE

_end:

pop                 EDX
pop                 ECX

pop                 EBP

ret 4
PromptMsg ENDP

; -------------------------------------------------------- -
PlaceFeedbackGameTurn PROC
; Author:           Hla Htun
; Description:      Places the feedback for specific round
;
; Parameters:       push    current_round    ; this is the nth round
;                   call
;
; Postconditions:   Feedbacks will be displayed on the GameBoard
;                   for that specific round
; -------------------------------------------------------- -
    push        EBP
    mov         EBP, ESP
    push        ECX
    push        EBX
    push        EAX

    mov         EAX, [EBP + 8]          ; current round number

    cmp         EAX, 8
    JE          _roundOne
    cmp         EAX, 7
    JE          _roundTwo
    cmp         EAX, 6
    JE          _roundThree
    cmp         EAX, 5
    JE          _roundFour
    cmp         EAX, 4
    JE          _roundFive
    cmp         EAX, 3
    JE          _roundSix
    cmp         EAX, 2
    JE          _roundSeven
    JMP         _roundEight

    _roundOne:
        mov     H_HelperVarX, 7         ; move cursor
        JMP     _printDraft
    _roundTwo:
        mov     H_HelperVarX, 15        ; move cursor
        JMP     _printDraft
    _roundThree:
        mov     H_HelperVarX, 23        ; move cursor
        JMP     _printDraft
    _roundFour:
        mov     H_HelperVarX, 31        ; move cursor
        JMP     _printDraft
    _roundFive:
        mov     H_HelperVarX, 39        ; move cursor
        JMP     _printDraft
    _roundSix:
        mov     H_HelperVarX, 47        ; move cursor
        JMP     _printDraft
    _roundSeven:
        mov     H_HelperVarX, 55        ; move cursor
        JMP     _printDraft
    _roundEight:
        mov     H_HelperVarX, 63            ; move cursor
        JMP     _printDraft

    _printDraft:
        mov     H_HelperVarY, 4
        mov     H_HelperVarMovY, 0
        cmp     hits, 0                     ; if no hits, don't draw
        JE      _outofPrintHitsHH

        mov     EBX, 0
        _printHitsHH:
            cmp     H_HelperVarMovY, 2      ; see if Y needs to be incremented
            JL      _continue1HH
            inc     H_HelperVarY
            sub     H_HelperVarX, 2
            mov     H_HelperVarMovY, 0
            _continue1HH:
                mPlaceFeedback H_HelperVarX, H_HelperVarY, HIT      ; draw hit
                inc     H_HelperVarX                                ; move X
                inc     H_HelperVarMovY                             ; increment MovY counter

            inc EBX
            cmp EBX, hits
            JGE _outofPrintHitsHH
            JMP _printHitsHH
        _outofPrintHitsHH:

        mov     H_HelperVarY, 4
        cmp     blows, 0                ; if no blows, don't draw
        JE      _outofPrintBlowsHH
        mov     EBX, 0
        _printBlowsHH:
            cmp     H_HelperVarMovY, 2  ; see if Y needs to be incremented
            JL      _continue2HH
            inc     H_HelperVarY
            sub     H_HelperVarX, 2
            mov     H_HelperVarMovY, 0
            _continue2HH:
                mPlaceFeedback H_HelperVarX, H_HelperVarY, BLOW     ; draw blow
                inc     H_HelperVarX                                ; move X
                inc     H_HelperVarMovY                             ; increment MovY counter

            inc EBX
            cmp EBX, blows
            JGE _outofPrintBlowsHH
            JMP _printBlowsHH
        _outofPrintBlowsHH:


    _outofPrintDraft:
        mov H_HelperVarY, 4

    pop         EAX
    pop         EBX
    pop         ECX
    pop         EBP
ret
PlaceFeedbackGameTurn ENDP

; -------------------------------------------------------- -
debugHH     PROC
; Author:           Hla Htun
; Description:      Prints out user_guess and solution arrays
;                   along with the round number, hits and blows
;
; Parameters:       mGotoXY   1, 25     ; needs to move cursor
;                   call                ; below the GameBoard
;
; -------------------------------------------------------- -
    push    ECX
    push    EAX

    mov     AL, 'R'
    call    WriteChar
    mov     EAX, current_round
    add     EAX, 1
    call    WriteDec
    call    Crlf
    mov     ECX, 0
    _printHH:
         push       ECX
         push       OFFSET user_guess
         push       TYPE user_guess
         call       ArrayAt
         call       WriteDec
         mov        AL, '-'
         call       WriteChar
         cmp        ECX, 3
         JE         _outofPrintHH
         inc        ECX
         JMP        _printHH
    _outofPrintHH:
        call        Crlf


    mov     ECX, 0
    _printHH2:
         push       ECX
         push       OFFSET solution
         push       TYPE solution
         call       ArrayAt
         call       WriteDec
         mov        AL, '-'
         call       WriteChar
         cmp        ECX, 3
         JE         _outofPrintHH2
         inc        ECX
         JMP        _printHH2
    _outofPrintHH2:
        call        Crlf


    mGotoXY         1, 22
    _printHH3:
        mov     AL, 'H'
        call    WriteChar
        mov     EAX, hits
        call    WriteDec
        call    Crlf

        mov     AL, 'B'
        call    WriteChar
        mov     EAX, blows
        call    WriteDec
        call    Crlf

    _outofPrintHH3:

    _printHH4:

    _outofPrintHH4:
    pop     EAX
    pop     ECX
ret
debugHH     ENDP

; -------------------------------------------------------- -
getName PROC
; Author:           Cameron Kroeker
; Description:      Gets the user's input in the form of string
;                   and stores in DWORD Uname
;
; Parameters:       needs a variable DWORD named userName,
;                   needs variables BYTE prompt_userName,
;                   and BYTE greeting
;                   
;
; Postconditions:   Prompts the screen and set's userName to user
;                   input, then greets user with custom input.
; -------------------------------------------------------- -

     ;Uname DWORD ?
     ;namePrompt BYTE "Please enter your name: ",0
     ;greeting BYTE "Hello, "
    push            8
    call            SetColorFromPalette

    _getName:
	    mPrint  prompt_userName
        mov     EDX, OFFSET userName
        mov     ECX, 20             ; allowed size
        call    ReadString          ; stores user name in userName
        call    Clrscr

    _greetUser:
        mPrint     greeting
        mPrint     userName
        mPrint     exclamation

ret
getName ENDP

; -------------------------------------------------------- -
RSum PROC
; Author:           Brayden Aldrich
; Description:      Sums numbers [0...n] recursively.
;
; Parameters:       call RSum
;                   
; Postconditions:   Call Writedec to see output on console.
; -------------------------------------------------------- -
cmp 		ECX, 0
jz 			_end
add 		EAX, ECX
dec 		ECX
call 		RSum
_end:
mov 		REC_answer, EAX
ret
RSum endp

; -------------------------------------------------------- -
AddFPU PROC
; Author:           Brayden Aldrich
; Description:      Gets two real numbers from user and calculates their sum
;
; Parameters:       Call AddFPU
;                   
; Postconditions:   Sum outputted on console
; -------------------------------------------------------- -

finit
mov 	EDX, OFFSET FPU_intro_string
call 	WriteString
mov 	EDX, OFFSET FPU_getUserFirstNum
call 	WriteString
call 	ReadFloat
mov 	EDX, OFFSET FPU_getUserSecNum
call 	WriteString
call 	ReadFloat
FADD 	ST(0), ST(1)
mPrint  FPU_result
call 	WriteFloat
call    Crlf
call    Crlf

ret
AddFPU  ENDP

END main