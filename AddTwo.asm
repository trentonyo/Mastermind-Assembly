TITLE Metric Converter - Assignment 3			(AddTwo.asm)

; Author(s) : Trenton Young
; Course / Project ID  CS 271 / Assignment 3	Date: 5 / 16 / 2023
; Description: Tool to convert between Fahrenheit / Celsius and Miles / Kilometers


INCLUDE Irvine32.inc

; (insert constant definitions here)
CR = 13
LF = 10

USER_NAME_LEN = 24

MAX_ARGS = 3; The largest number of arguments allowed per conversion(SOFT CAP : must be less than 10)
CHAR_MAX_ARGS = MAX_ARGS + 48

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

; (Conversion)

MIN_F			REAL4		-459.67f ; Absolute zero in Fahrenheit (update reinstr_temp if you change this or if the laws of thermodynamics change for some reason)
MIN_POS			REAL4		0.0f ; Zero for positive number validation

KM_RATIO		REAL4		1.60934f
ML_RATIO		REAL4		29.5735f
KG_RATIO		REAL4		0.453592f

C_CONST			REAL4		32.0f
C_RATIO			REAL4		0.5555555555555555555555555555f

; (Localizations)
ec1				BYTE		"**EC         : Performs four different conversions.", CR, LF, 0
ec2				BYTE		"**EC (Maybe?): Displays the conversions in aligned columns.", CR, LF, 0
ec3				BYTE		"**EC (Maybe?): Used constants to define the carriage", CR, LF, "**             return and line feed codes for multiline", CR, LF, "**             strings with a single print.", CR, LF, 0
ec4				BYTE		"**EC (Maybe?): Program prompts user to go again which", CR, LF, "**             preserves the user's name and prompts for", CR, LF, "**             another number of terms.", CR, LF, 0
ec5				BYTE		"**EC (Maybe?): Allows the user to convert up to ", CHAR_MAX_ARGS, " values", CR, LF, "**             per conversion with arrays.", CR, LF, 0
ec6				BYTE		"**EC (Maybe?): Validates input of temperatures to conform", CR, LF, "**             with the laws of physics, uses absolute value", CR, LF, "**             of inputs for others (no negatives).", CR, LF, CR, LF, 0

header			BYTE		"Metric Converter", CR, LF, "Programmed by Trenton Young", CR, LF, CR, LF, 0

prompt_name		BYTE		"- Hi, I'm Milli! What's your name? ", 0

greeting		BYTE		CR, LF, "- Hello, ", 0

regreet			BYTE		CR, LF, CR, LF, "- Okay, let's convert some more values!", CR, LF, CR, LF, 0

label_dist		BYTE		"** Conversion: Miles to Kilometers           **", CR, LF, 0
label_temp		BYTE		"** Conversion: Degrees Fahrenheit to Celsius **", CR, LF, 0
label_vol		BYTE		"** Conversion: Fluid Ounces to Milliliters   **", CR, LF, 0
label_mass		BYTE		"** Conversion: Earth-pounds to Kilograms     **", CR, LF, 0

instruct_dist 	BYTE		"- Enter a distance (in miles)                 : ", 0
instruct_temp 	BYTE		"- Enter a temperature (in degrees Fahrenheit) : ", 0
instruct_vol 	BYTE		"- Enter a volume (in fluid ounces)            : ", 0
instruct_mass 	BYTE		"- Enter a weight (in earth-pounds)            : ", 0

reinstr_positv	BYTE		CR, LF, "- Oops, that number is out of range!", CR, LF, "  (Give a positive number)                    : ", 0
reinstr_temp	BYTE		CR, LF, "- Oops, that number is out of range!", CR, LF, "  (Give a number greater than -459.67)        : ", 0

try_again		BYTE		"- That was fun! Do you want to go again?", CR, LF, "  (Enter 1 to go again, anything else or [Enter] to quit): ", 0
outro			BYTE		CR, LF, "- Thanks so much, until next time ", 0

sadface			BYTE		"): ", 0
exclaim_break	BYTE		"!", CR, LF, 0
space_string	BYTE		" ", 0

km_string		BYTE		" km", 0
ml_string		BYTE		" mL", 0
kg_string		BYTE		" kg", 0
c_string		BYTE		" C ", 0
							  
mile_string		BYTE		" mi", 0
oz_string		BYTE		" oz", 0
lb_string		BYTE		" lb", 0
f_string		BYTE		" F ", 0

equal_string	BYTE		" = ", 0

; (User variables)
users_name		BYTE		USER_NAME_LEN DUP(0)

users_dist_arr	REAL4		MAX_ARGS DUP(?)
users_temp_arr	REAL4		MAX_ARGS DUP(?)
users_vol_arr	REAL4		MAX_ARGS DUP(?)
users_mass_arr	REAL4		MAX_ARGS DUP(?)

convr_dist_arr	REAL4		MAX_ARGS DUP(?)
convr_temp_arr	REAL4		MAX_ARGS DUP(?)
convr_vol_arr	REAL4		MAX_ARGS DUP(?)
convr_mass_arr	REAL4		MAX_ARGS DUP(?)

tab_width		DWORD		19
column			DWORD		0

num_length		DWORD		15; All floats are 15

; TODO TESTING

user_a          DWORD       42
user_b          DWORD       100

; TODO TESTING


.code
main PROC; (insert executable instructions here)

; TODO TESTING

mov             EAX, user_a
call            WriteDec
call            Crlf
mov             EAX, user_b
call            WriteDec

call            Crlf
call            Crlf

mSwap           user_a, user_b

mov             EAX, user_a
call            WriteDec
call            Crlf
mov             EAX, user_b
call            WriteDec

call            Crlf
call            Crlf

; TODO TESTING


; --------------------------------------------------------
setup:
;
; Runs functions that set the environment to expected
; --------------------------------------------------------
finit

; --------------------------------------------------------
introduction:
;
; Displays extra credit messages, assignment title, and author.
; Also gets the user's name and greets them.
; --------------------------------------------------------

mov			EDX, OFFSET ec1
call		WriteString
mov			EDX, OFFSET ec2
call		WriteString
mov			EDX, OFFSET ec3
call		WriteString
mov			EDX, OFFSET ec4
call		WriteString
mov			EDX, OFFSET ec5
call		WriteString
mov			EDX, OFFSET ec6
call		WriteString

mov			EDX, OFFSET header
call		WriteString

mov			EDX, OFFSET prompt_name
call		WriteString

mov			EDX, OFFSET users_name
mov			ECX, USER_NAME_LEN
call		ReadString

mov			EDX, OFFSET greeting
call		WriteString
mov			EDX, OFFSET users_name
call		WriteString
mov			EDX, OFFSET exclaim_break
call		WriteString

jmp			_skipRegreet

; --------------------------------------------------------
getUserData:
;
; Gets all values in imperial(standard) to convert.
; --------------------------------------------------------

mov			EDX, OFFSET regreet 
call		WriteString
_skipRegreet:

call GetUserTemps


;-----------------------------

mov			ECX, MAX_ARGS; Loop a number of times equal to the maximum arguments allowed
mov			ESI, 0

_getDistInput:
	mov			EDX, OFFSET	instruct_dist
	call		WriteString
	
_skipDistInstruct:
	call		ReadFloat					; ST(0) = input	
	fabs									; ST(0) = absolute value of input (no negatives)
			
	fstp		[users_dist_arr + ESI]		; Pop the user input into the distance array

	add			ESI, 4						; Increment the index by 4 bytes(the size of a real4)
	
	loop		_getDistInput
	jmp			_exitDistInput

	_invalidDistInput:
		push		EDX
		mov			EDX, OFFSET	reinstr_positv
		call		WriteString
		pop			EDX 
		jmp			_skipDistInstruct
_exitDistInput :


;-----------------------------

mov			ECX, MAX_ARGS; Loop a number of times equal to the maximum arguments allowed
mov			ESI, 0

_getVolInput:
	mov			EDX, OFFSET	instruct_vol
	call		WriteString
	
_skipVolInstruct:
	call		ReadFloat					; ST(0) = input	
	fabs									; ST(0) = absolute value of input (no negatives)
			
	fstp		[users_vol_arr + ESI]		; Pop the user input into the volume array

	add			ESI, 4						; Increment the index by 4 bytes(the size of a real4)
	
	loop		_getVolInput
	jmp			_exitVolInput

	_invalidVolInput:
		push		EDX
		mov			EDX, OFFSET	reinstr_positv
		call		WriteString
		pop			EDX 
		jmp			_skipVolInstruct
_exitVolInput :


;-----------------------------

mov			ECX, MAX_ARGS; Loop a number of times equal to the maximum arguments allowed
mov			ESI, 0

_getMassInput:
	mov			EDX, OFFSET	instruct_mass
	call		WriteString
	
_skipMassInstruct:
	call		ReadFloat					; ST(0) = input	
	fabs									; ST(0) = absolute value of input (no negatives)
			
	fstp		[users_mass_arr + ESI]		; Pop the user input into the mass array

	add			ESI, 4						; Increment the index by 4 bytes(the size of a real4)
	
	loop		_getMassInput
	jmp			_exitMassInput

	_invalidMassInput:
		push		EDX
		mov			EDX, OFFSET	reinstr_positv
		call		WriteString
		pop			EDX 
		jmp			_skipMassInstruct
_exitMassInput :


;fld			users_dist_arr[0]
;call		WriteFloat
;call		Crlf
;fld			users_dist_arr[4]
;call		WriteFloat
;call		Crlf
;fld			users_dist_arr[8]
;call		WriteFloat
;call		Crlf

; ---------------------------- -


; --------------------------------------------------------
convertToKM:
;
; Performs the miles/kilometers conversion
; --------------------------------------------------------

mov			ECX, MAX_ARGS; Loop a number of times equal to the maximum arguments allowed
mov			ESI, 0
	
_convertDist:			
	fld			[users_dist_arr + ESI]		; Load the next element in the distance array
	fld			KM_RATIO					; Load the kilometer ratio and multiply
	fmul

	fstp		[convr_dist_arr + ESI]		; Pop the user input into the converted distance array

	add			ESI, 4						; Increment the index by 4 bytes (the size of a real4)
	
	loop		_convertDist
_exitConvertDist :


; --------------------------------------------------------
convertToCelsius:
;
; Performs the fahrenheit / celsius conversion
; --------------------------------------------------------

mov			ECX, MAX_ARGS; Loop a number of times equal to the maximum arguments allowed
mov			ESI, 0
	
_convertTemp:			
	fld			[users_temp_arr + ESI]		; Load the next element in the temperature array
	fld			C_CONST						; Load the constant for converting celsius, subtract
	fsub
		
	fld			C_RATIO						; Load the kilometer ratio and multiply
	fmul

	fstp		[convr_temp_arr + ESI]		; Pop the user input into the converted temperature array

	add			ESI, 4						; Increment the index by 4 bytes (the size of a real4)
	
	loop		_convertTemp
_exitConvertTemp :
	

; --------------------------------------------------------
convertToML:
;
; Performs the ounces / milliliters conversion
; --------------------------------------------------------

mov			ECX, MAX_ARGS; Loop a number of times equal to the maximum arguments allowed
mov			ESI, 0
	
_convertVol:				
	fld			[users_vol_arr + ESI]		; Load the next element in the volume array
	fld			ML_RATIO					; Load the milliliter ratio and multiply
	fmul

	fstp		[convr_vol_arr + ESI]		; Pop the user input into the converted volume array

	add			ESI, 4						; Increment the index by 4 bytes (the size of a real4)
	
	loop		_convertVol
_exitConvertVol :


; --------------------------------------------------------
convertToKG:
;
; Performs the pounds / kilograms conversion
; --------------------------------------------------------

mov			ECX, MAX_ARGS; Loop a number of times equal to the maximum arguments allowed
mov			ESI, 0
	
_convertMass:				
	fld			[users_mass_arr + ESI]		; Load the next element in the mass array
	fld			KG_RATIO					; Load the kilogram ratio and multiply
	fmul

	fstp		[convr_mass_arr + ESI]		; Pop the user input into the converted mass array

	add			ESI, 4						; Increment the index by 4 bytes (the size of a real4)
	
	loop		_convertMass
_exitConvertMass :
		

; --------------------------------------------------------
displayConvertedData:
;
; Displays converted values
; label_dist
; label_temp
; label_vol
; label_mass
; --------------------------------------------------------

call		Crlf
call		Crlf

mov			ECX, MAX_ARGS					; Initiate loop counter to the users
mov			ESI, 0

mov			EDX, OFFSET label_dist
call		WriteString

displayDistConversion:
	call		PrettyPrintSpaces
	
	fld			users_dist_arr[ESI]
	call		WriteFloat
	fstp		ST(0)
		
	mov			EDX, OFFSET mile_string
	call		WriteString 

		
	mov			EDX, OFFSET equal_string
	call		WriteString 

		
	call		PrettyPrintSpaces
	
	fld			convr_dist_arr[ESI]
	call		WriteFloat
	fstp		ST(0)

	mov			EDX, OFFSET km_string
	call		WriteString 

	add			ESI, 4
	call		Crlf

	loop displayDistConversion

		
mov			ECX, MAX_ARGS					; Initiate loop counter to the users
mov			ESI, 0

mov			EDX, OFFSET label_temp
call		WriteString

displayTempConversion:
	call		PrettyPrintSpaces
	
	fld			users_temp_arr[ESI]
	call		WriteFloat
	fstp		ST(0)
		
	mov			EDX, OFFSET f_string
	call		WriteString 

		
	mov			EDX, OFFSET equal_string
	call		WriteString 

		
	call		PrettyPrintSpaces
	
	fld			convr_temp_arr[ESI]
	call		WriteFloat
	fstp		ST(0)

	mov			EDX, OFFSET c_string
	call		WriteString 

	add			ESI, 4
	call		Crlf

	loop displayTempConversion

		
		
mov			ECX, MAX_ARGS					; Initiate loop counter to the users
mov			ESI, 0

mov			EDX, OFFSET label_vol
call		WriteString

displayVolConversion:
	call		PrettyPrintSpaces
	
	fld			users_vol_arr[ESI]
	call		WriteFloat
	fstp		ST(0)
		
	mov			EDX, OFFSET oz_string
	call		WriteString 

		
	mov			EDX, OFFSET equal_string
	call		WriteString 

		
	call		PrettyPrintSpaces
	
	fld			convr_vol_arr[ESI]
	call		WriteFloat
	fstp		ST(0)

	mov			EDX, OFFSET ml_string
	call		WriteString 

	add			ESI, 4
	call		Crlf

	loop displayVolConversion

		
mov			ECX, MAX_ARGS					; Initiate loop counter to the users
mov			ESI, 0

mov			EDX, OFFSET label_mass
call		WriteString

displayMassConversion:
	call		PrettyPrintSpaces
	
	fld			users_mass_arr[ESI]
	call		WriteFloat
	fstp		ST(0)
		
	mov			EDX, OFFSET lb_string
	call		WriteString 

		
	mov			EDX, OFFSET equal_string
	call		WriteString 

		
	call		PrettyPrintSpaces
	
	fld			convr_mass_arr[ESI]
	call		WriteFloat
	fstp		ST(0)

	mov			EDX, OFFSET kg_string
	call		WriteString 

	add			ESI, 4
	call		Crlf

	loop displayMassConversion



; --------------------------------------------------------
; farewell:
;
; Prompts user to go again and /or displays ending message
; --------------------------------------------------------

; Prompt user to go again
call		Crlf
mov			EDX, OFFSET try_again
call		WriteString

call		ReadInt
cmp			EAX, 1
je			getUserData						; If the user enters 1, return to the continuing prompt

mov			EDX, OFFSET	outro
call		WriteString						; Prints the string outro with two newlines if the user did not choose to repeat the program
mov			EDX, OFFSET users_name
call		WriteString
mov			EDX, OFFSET exclaim_break
call		WriteString


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
mov			ECX, MAX_ARGS					; Loop a number of times equal to the maximum arguments allowed
mov			ESI, 0

_getTempInput:
	mov			EDX, OFFSET	instruct_temp
	call		WriteString
	
_skipTempInstruct:
	fld			MIN_F						; ST(0) = MIN_F
	call		ReadFloat					; ST(0) = input, ST(1) = MIN_F
		

	fcomi		ST(0), ST(1)				; Compare User input to MIN_F  for validation
	jb			_invalidTempInput

	
	fstp		[users_temp_arr + ESI]		; Pop the user input into the temperature array
	fstp		ST(0)						; Pop the comparison value (Credit to PhiS on StackOverflow : https://stackoverflow.com/a/4810464)

	add			ESI, 4						; Increment the index by 4 bytes(the size of a real4)
	
	loop		_getTempInput
	jmp			_exitTempInput

	_invalidTempInput:
		push		EDX
		mov			EDX, OFFSET	reinstr_temp
		call		WriteString
		pop			EDX 
		jmp			_skipTempInstruct
_exitTempInput:

ret
GetUserTemps ENDP


; -------------------------------------------------------- -
GetUserInputs PROC uses ECX EDX ESI
;
; Prompts user for the other valeus they want converted
; Preconditions: Push a valid instruction string THEN a valid input array
; Postconditions: Updates users_temp_arr array in memory
; -------------------------------------------------------- -


mov			ECX, MAX_ARGS; Loop a number of times equal to the maximum arguments allowed
mov			ESI, 0

_getInput:
	mov			EDX, OFFSET	instruct_vol;TODO XXXXXXXXXXXXXX
	call		WriteString
	
_skipInstruct:
	call		ReadFloat					; ST(0) = input	
	fabs									; ST(0) = absolute value of input (no negatives)
			
	fstp		[users_vol_arr + ESI]; TODO XXXXXXXXXXXXXX; Pop the user input into the volume array

	add			ESI, 4						; Increment the index by 4 bytes(the size of a real4)
	
	loop		_getInput
	jmp			_exitInput

	_invalidInput:
		push		EDX
		mov			EDX, OFFSET	reinstr_positv
		call		WriteString
		pop			EDX 
		jmp			_skipInstruct
_exitInput :

ret
GetUserInputs ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; -------------------------------------------------------- -
PrettyPrintSpaces PROC uses EAX ECX EDX
;
; Prints the leading whitespace for tabulation of a number
; Preconditions: number to print is in EAX, WILL MUTATE
; Postconditions: EAX will be ? , EBX will be 10, ECX will be preserved(what it was before call), EDX will be 0
; -------------------------------------------------------- -


; for tab_width - num_length
; print SPACE
; endfor
mov			EAX, tab_width
sub			EAX, num_length
mov			ECX, EAX

mov			EDX, OFFSET space_string
printSpace :
call	WriteString
loop	printSpace

ret
PrettyPrintSpaces ENDP

END main
