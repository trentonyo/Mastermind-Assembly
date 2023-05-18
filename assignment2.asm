TITLE Fibonnaci Numbers - Assignment 2			(AddTwo.asm)

; Author(s) : Trenton Young
; Course / Project ID  CS 271 / Assignment 2	Date: 4 / 25 / 2023
; Description: Fibonacci number generator


INCLUDE Irvine32.inc

; (insert constant definitions here)
LIMIT_HI = 46
LIMIT_LO = 1

CR = 13
LF = 10

USER_NAME_LEN = 24

NUM_COLUMNS = 5

.data

; (Localizations)
ec1				BYTE		"**EC         : Displays the numbers in aligned columns.", CR, LF, 0
ec2				BYTE		"**EC (Maybe?): Used constants to define the carriage", CR, LF, "**             return and line feed codes for multiline", CR, LF, "**             strings with a single print.", CR, LF, 0
ec3				BYTE		"**EC (Maybe?): Program prompts user to go again which", CR, LF, "**             preserves the user's name and prompts for", CR, LF, "**             another number of terms.", CR, LF, CR, LF, 0

header			BYTE		"Fibonacci Numbers", CR, LF, "Programmed by Trenton Young", CR, LF, CR, LF, 0

prompt_name		BYTE		"- Hi, I'm Leo! What's your name? ", 0

greeting		BYTE		CR, LF, "- Hello, ", 0

instruction 	BYTE		CR, LF, "- Enter the number of Fibonacci terms to be displayed:", CR, LF, "  (Give as an integer in the range ", 0
reinstruct		BYTE		CR, LF, "- Oops, that number is out of range!", CR, LF, "  (Give an integer within the inclusive range ", 0
try_again		BYTE		"- That was fun! Do you want to go again?", CR, LF, "  (Enter 1 to go again, anything else or [Enter] to quit): ", 0
outro			BYTE		CR, LF, "- Thanks so much, until next time ", 0

sadface			BYTE		"): ", 0
exclaim_break	BYTE		"!", CR, LF, 0
space_string	BYTE		" ", 0

limit_range1	BYTE		"[", 0
limit_range2	BYTE		" .. ", 0
limit_range3	BYTE		"]", 0

; (User variables)
users_name		BYTE		USER_NAME_LEN DUP(0)

users_n			DWORD		?

fib_n1			DWORD		0
fib_n2			DWORD		1
fib_tmp			DWORD		?

tab_width		DWORD		15
column			DWORD		0

num_length		DWORD		0	; Incremented in a do/while, so initialized to 0
pretty_help		DWORD		?   ; Helper variable for preserving loop counter in nested loop during subprocess PrettyPrintSpaces

.code
main PROC ; (insert executable instructions here)

; -------------------------------------------------------- 
introduction:
; 
; Displays extra credit messages, assignment title, and author. Gets the user's name
; -------------------------------------------------------- 

	mov			EDX,				OFFSET ec1
	call		WriteString
	mov			EDX,				OFFSET ec2
	call		WriteString
	mov			EDX,				OFFSET ec3
	call		WriteString

	mov			EDX,				OFFSET header
	call		WriteString

	mov			EDX,				OFFSET prompt_name
	call		WriteString

	mov			EDX,				OFFSET users_name
	mov			ECX,				USER_NAME_LEN
	call		ReadString

	mov			EDX,				OFFSET greeting
	call		WriteString
	mov			EDX,				OFFSET users_name
	call		WriteString
	mov			EDX,				OFFSET exclaim_break
	call		WriteString

; --------------------------------------------------------
userInstructions:
;
; Displays the instructions for the first time to the user
; --------------------------------------------------------

	mov			EDX,				OFFSET instruction
	call		WriteString

	call		PrintLimit
	
	mov			EDX,				OFFSET sadface			; Sadface is to close parentheses and display a colon with a space '): ', get it?
	call		WriteString

	jmp			getUserData

; --------------------------------------------------------
repromptUser:
;
; Displays the reminder instructions for the user (skipped
; over on the first run, returned to if out of range at 
; getUserData)
; --------------------------------------------------------

	mov			EDX,				OFFSET reinstruct
	call		WriteString

	call		PrintLimit
	
	mov			EDX,				OFFSET sadface			; Sadface is to close parentheses and display a colon with a space '): ', get it?
	call		WriteString

; --------------------------------------------------------
getUserData:
;
; Receives and validates user input, may jump back to the
; reminder instruction if user provides invalid input
; (POST-TEST LOOP)
; --------------------------------------------------------

	call		ReadInt										; Get user input, stores it in EAX
	
	cmp			EAX,				LIMIT_LO
	jl			repromptUser								; If the user enters something lower than the lower limit, try again
	
	cmp			EAX,				LIMIT_HI
	ja			repromptUser								; If the user enters something greater than the upper limit, try again

	mov			users_n,			EAX

; --------------------------------------------------------
setTabWidth:
;
; Checks the users_n to see how long the longest term will
; be, increments the tab_width accordingly.
;
; Starts with the widest possible tab width, then works
; down to find the narrowest (while being at least 5)
; --------------------------------------------------------

	cmp			users_n,			44
	ja			displayFibs
	dec			tab_width
	
	cmp			users_n,			39
	ja			displayFibs
	dec			tab_width
	
	cmp			users_n,			35
	ja			displayFibs
	dec			tab_width
	
	cmp			users_n,			30
	ja			displayFibs
	dec			tab_width

	cmp			users_n,			25
	ja			displayFibs
	dec			tab_width
	
	cmp			users_n,			20
	ja			displayFibs
	dec			tab_width

; --------------------------------------------------------
displayFibs:
;
; Calculates Fibonacci terms and displays them, aligning
; into columns according to the input of the user
; (COUNTED LOOP)
; --------------------------------------------------------

	mov			ECX,				users_n					; Initiate loop counter to the users' input

	calculateTerm:
		mov		EAX,				fib_n2					; Print fib_n2 with whitespace
		call	PrettyPrintSpaces 

		mov		EAX,				fib_n2 
		call	WriteDec

		add		EAX,				fib_n1					; add fib_n1 onto EAX(which contains fib_n2) to calculate the next

		mov		EBX,				fib_n2					; using EBX as a temp, move fib_n2 back to fib_n1
		mov		fib_n1,				EBX

		mov		fib_n2,				EAX						; pull the next term from EAX and store it into fib_n2
	
		inc		column										; keep track of the number of terms printed so far, increment and rollover when the limit is reached
		cmp		column,				NUM_COLUMNS
		jb		same_column
			call	Crlf
			mov		column,			0
		same_column:

	loop calculateTerm

; --------------------------------------------------------
farewell:
;
; Prompts user to go again and /or displays ending message
; --------------------------------------------------------

; Reset all initial variables
	mov			fib_n1,				0
	mov			fib_n2,				1
	mov			tab_width,			15
	mov			column,				0
	mov			num_length,			0

; Prompt user to go again
	call		Crlf
	mov			EDX,				OFFSET try_again
	call		WriteString

	call		ReadInt
	cmp			EAX,				1
	je			userInstructions							; If the user enters 1, return to the continuing prompt

	mov			EDX,				OFFSET	outro
	call		WriteString									; Prints the string outro with two newlines if the user did not choose to repeat the program
	mov			EDX,				OFFSET users_name
	call		WriteString
	mov			EDX,				OFFSET exclaim_break
	call		WriteString


exit; exit to operating system
main ENDP

; (insert additional procedures here)
; -------------------------------------------------------- -
PrintLimit PROC
;
; Prints a formatted range defined by the constants LIMIT_HI and LIMIT_LO
; Preconditions: LIMIT_HI, LIMIT_LO, limit_range1, limit_range2, and limit_range3 are all defined
; Postconditions: EDX will be 0 and EAX will be the value of LIMIT_HI
; -------------------------------------------------------- -

mov			EDX,				OFFSET limit_range1
call		WriteString
mov			EAX,				LIMIT_LO
call		WriteDec
mov			EDX,				OFFSET limit_range2
call		WriteString
mov			EAX,				LIMIT_HI
call		WriteDec
mov			EDX,				OFFSET limit_range3
call		WriteString

ret
PrintLimit ENDP


; -------------------------------------------------------- -
PrettyPrintSpaces PROC
;
; Prints the leading whitespace for tabulation of a number
; Preconditions: number to print is in EAX, WILL MUTATE
; Postconditions: EAX will be ?, EBX will be 10, ECX will be preserved (what it was before call), EDX will be 0
; -------------------------------------------------------- -

; preserve ECX
mov			pretty_help,		ECX


; do; find num_length
; divide num by 10
; inc num_length
; while num >= 10

mov			EBX,				10
findNumLength:
	cdq
	div		EBX
	inc		num_length

	cmp		EAX,				1
	jae		findNumLength


; for tab_width - num_length
; print SPACE
; endfor 
mov			EAX,				tab_width
sub			EAX,				num_length 
mov			ECX,				EAX 

mov			EDX,				OFFSET space_string
printSpace:
	call	WriteString
	loop	printSpace

; recall ECX, reset num_length
mov			ECX,				pretty_help
mov			num_length,			0

ret
PrettyPrintSpaces ENDP

END main
