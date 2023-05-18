TITLE Assignment 1     (AddTwo.asm)

; Author(s): Trenton Young
; Course / Project ID  CS 271               Date: 4/17/2023
; Description: Simple arithmetic tool

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

; (insert variable definitions here)

nameline	BYTE		"## Trenton Young (CS 271) - Simple Arithmetic Tool", 0

ec1			BYTE		"**EC           : Program repeats if user requests", 0
ec2			BYTE		"**EC           : Program validates that second input is less than first", 0
ec3			BYTE		"**EC (partial?): Program provides a floating point division, currently in scientific notation", 0

intro		BYTE		"Enter two numbers (the first larger than the second), and I'll show you the sum, difference, product, quotient and remainder, as well as a floating-point ratio.", 0
contn		BYTE		"Enter two more numbers, and I'll show you the sum, difference, product, quotient and remainder, and ratio again.", 0
repet		BYTE		"Impressed? Press 1 to go again (any other input or <enter> to quit): ", 0
outro		BYTE		"I bet you were impressed! Bye!", 0
reprm		BYTE		"Oops! The second number must be smaller, pick a number less than ", 0

prompts		BYTE		": ", 0
prompt1		BYTE		"  First number: ", 0
prompt2		BYTE		" Second number: ", 0

opequ		BYTE		" = ", 0
opadd		BYTE		" + ", 0
opsub		BYTE		" - ", 0
opmul		BYTE		" * ", 0
opdiv		BYTE		" / ", 0
opfdiv		BYTE		" ./. ", 0

oprem		BYTE		" remainder ", 0

num1		DWORD		?
num2		DWORD		?
num3		DWORD		?

.code
main PROC

introduction:

	mov			EDX,		OFFSET			nameline
	call		WriteString
	call		Crlf
	call		Crlf
	mov			EDX,		OFFSET			ec1
	call		WriteString
	call		Crlf
	mov			EDX,		OFFSET			ec2
	call		WriteString
	call		Crlf
	mov			EDX,		OFFSET			ec3
	call		WriteString
	call		Crlf
	call		Crlf

	mov			EDX,		OFFSET			intro
	call		WriteString
	call		Crlf
	call		Crlf
		
	jmp			userprompt1							; Prints the string intro with two newlines, skips to user prompt 

continuation:
	call		Crlf
	call		Crlf

	mov			EDX,		OFFSET		contn
	call		WriteString

	call		Crlf
	call		Crlf								; Prints the string contn with two newlines, this section is hit when the user continues using the program

userprompt1:
	mov			EDX,		OFFSET			prompt1 
	call		WriteString

	call		ReadInt								; Get user input
	mov			num1,		EAX						; Prints the string prompt1 and gets user input

userprompt2:
	mov			EDX,		OFFSET			prompt2 
	call		WriteString	

	jmp			validatenum2						; Prints the string prompt2 and gets user input, then jumps to validate that input

userreprompt2:
	mov			EDX,		OFFSET			reprm
	call		WriteString							; Writes the re-prompt for the user to choose a different value

	mov			EAX,		num1
	call		WriteDec							; Reminds the user which number their choice must be less than

	mov			EDX,		OFFSET			prompts
	call		WriteString							; Small formatting string to clean up the prompt

validatenum2:
	call		ReadInt								; Get user input
	mov			num2,		EAX

	call		Crlf;

	cmp			EAX,		num1					; Check if num2 is less than num1, if it is not then return to the re-prompt
	jae			userreprompt2

performadd:
	mov			EBP,		OFFSET			opadd	; Set the equation string to add
	call		writeequation

	mov			EAX,		num1
	mov			EBX,		num2
	add			EAX,		EBX

	call		WriteDec							; After the arithmetic is performed, print the answer at the end of the equation
	call		Crlf

performsub:
	mov			EBP,		OFFSET			opsub	; Set the equation string to subtract
	call		writeequation

	mov			EAX,		num1
	mov			EBX,		num2
	sub			EAX,		EBX						; After the arithmetic is performed, print the answer at the end of the equation

	call		WriteDec
	call		Crlf

performmul:
	mov			EBP,		OFFSET			opmul	; Set the equation string to multilpy
	call		writeequation

	mov			EAX,		num1
	mov			EBX,		num2
	mul			EBX									; After the arithmetic is performed, print the answer at the end of the equation

	call		WriteDec
	call		Crlf

performdiv:
	mov			EBP,		OFFSET			opdiv	; Set the equation string to divide
	call		writeequation

	mov			EAX,		num1
	mov			EBX,		num2
	cdq
	div			EBX

	mov			num3,		EDX						; Need to store the remainder in num3 because EDX is used for printing

	call		WriteDec

	mov			EDX,		OFFSET			oprem
	call		WriteString							; Print the word 'remainder'

	mov			EAX,		num3
	call		WriteDec							; After the arithmetic is performed, print the answer at the end of the equation

	call		Crlf



performfdiv:
	mov			EBP,		OFFSET			opfdiv	; Set the equation string to divide
	call		writeequation

	;mov			EAX,		num1
	;mov			EBX,		num2
	
	finit
	fild		num2
	fild		num1								; Push the numbers in reverse order (because stack)

	fdiv		ST, ST(1)

	call		WriteFloat

	call		Crlf


repeatprompt :
	call		Crlf
	mov			EDX,		OFFSET			repet
	call		WriteString

	call		ReadInt								; Get user input
	cmp			EAX,		1
	je			continuation						; If the user enters 1, return to the continuing prompt 

outroduction:
	mov			EDX,		OFFSET			outro
	call		WriteString
	call		Crlf
	call		Crlf								; Prints the string outro with two newlines if the user did not choose to repeat the program

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

; Precondition: a string is pointed to by EBP that contains the operator string (e.g. " + ")
; Postcondition: num1 and num2 are displayed with the operator and the equal sign (e.g. "4 + 2 = ")
writeequation PROC

	mov EAX, num1
	call WriteDec

	mov EDX, EBP
	call WriteString

	mov EAX, num2
	call WriteDec

	mov EDX, OFFSET opequ
	call WriteString

	ret

writeequation ENDP

END main
