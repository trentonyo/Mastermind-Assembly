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

mSwap           MACRO       a, b
    push        EAX
    push        EBX

    mov         EAX, a
    mov         EBX, b

    mov         b, EAX
    mov         a, EBX

    pop         EBX
    pop         EAX
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

GUI_gameboard_peg           BYTE        "-@", 0         ; ASCII for a game peg

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


exit; exit to operating system
main ENDP

; (insert additional procedures here)

; -------------------------------------------------------- -
GetUserTemps PROC uses ECX EDX ESI
;
; Prompts user for the temperatures they want converted
; Preconditions: Define a global DWORD array of size MAX_ARGS called users_temp_arr
; Postconditions: Updates users_temp_arr array in memory
; -------------------------------------------------------- -

; get temperatures(first because it has different validation)
;mov			ECX, MAX_ARGS					; Loop a number of times equal to the maximum arguments allowed
;mov			ESI, 0
;
;_getTempInput:
;	mov			EDX, OFFSET	instruct_temp
;	call		WriteString
;
;_skipTempInstruct:
;	fld			MIN_F						; ST(0) = MIN_F
;	call		ReadFloat					; ST(0) = input, ST(1) = MIN_F
;
;
;	fcomi		ST(0), ST(1)				; Compare User input to MIN_F  for validation
;	jb			_invalidTempInput
;
;
;	fstp		[users_temp_arr + ESI]		; Pop the user input into the temperature array
;	fstp		ST(0)						; Pop the comparison value (Credit to PhiS on StackOverflow : https://stackoverflow.com/a/4810464)
;
;	add			ESI, 4						; Increment the index by 4 bytes(the size of a real4)
;
;	loop		_getTempInput
;	jmp			_exitTempInput
;
;	_invalidTempInput:
;		push		EDX
;		mov			EDX, OFFSET	reinstr_temp
;		call		WriteString
;		pop			EDX
;		jmp			_skipTempInstruct
;_exitTempInput:
;
ret
GetUserTemps ENDP


END main
