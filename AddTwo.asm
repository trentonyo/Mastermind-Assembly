TITLE Mastermind			(AddTwo.asm)

; Author(s) : Trenton Young
; Course / Project ID  CS 271 / Final Project
; Description: Play Mastermind! The classic codebreaker game!


INCLUDE Irvine32.inc

; (insert constant definitions here)
CR = 13
LF = 10

USER_NAME_LEN = 24

ROUNDS = 8
CODE_LENGTH = 4

COLS = ROUNDS                       ; Semantic equivalents for the game array
ROWS = CODE_LENGTH                  ;

COLORS = 8                          ; Number of colored pegs the game uses


; --------------------------------------------------------
mPrint              MACRO str
; Author:       Trenton Young
; Description:  Basic wrapper for Irvine's WriteString
;
; Use:          Pass a string, not the OFFSET
; --------------------------------------------------------
    push                EDX

    mov                 EDX, OFFSET str
    call                WriteString

    pop                 EDX
ENDM

; --------------------------------------------------------
mArand              MACRO _low, _high, _target
; Author:       Trenton Young
; Description:  Random range from Irvine's WriteString,
;               output is stored in given register
;
; Use:          _low and _high may be literals, _target may
;               be a register
; --------------------------------------------------------
    push    EAX

    mov     EAX, _high
    sub     EAX, _low
    inc     EAX
    call    RandomRange
    add     EAX, _low

    mov     _target, EAX

    pop     EAX
ENDM

.data

; (Graphics)        Define any ASCII art strings here

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

; (Localizations)
;ec1				BYTE		"**EC         : Performs four different conversions.", CR, LF, 0


.code
main PROC; (insert executable instructions here)


; --------------------------------------------------------
setup:
;
; Runs functions that set the environment to expected
; --------------------------------------------------------
finit

call        DrawNewGameboard

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


END main
