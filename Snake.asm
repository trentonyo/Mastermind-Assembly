TITLE SnakeXenia.asm

; Link to github code: https://github.com/itzzhammy/Snake_Xenia_Game_Assembely_Language
; Snake game created in MASM x86. 
; Where the primary obstacle is phrased as Apple by the symbol “@”. 

; Registers used in the program: 	
	;1)	eax, esi, edx, ebx, ecx, edx 
	;2)	ax, bx, al , dl, dh, ah 
	
; Classification of registers:
	;1)	EAX, AX, AH, AL: They are used as the accumulator registers. They are used for input and output. They also carry out arithmetic instructions. 
	;2)	EBX, BX: They are used as the base registers. They are the basic pointer address to access memory. 
	;3)	ECX: They are used as the Counter registers. They are used as the loop counter for shifting values. 
	;4)	EDX, DH and DL: They are used as the Data registers. Used to store data and arithmetic instructions.
	;5)	ESI: It is used as memory array addressing and setting out values to the pointer memory address
	
; Procedures:
	;1)	Main Procedure
	;2)	EatApple (obstacle)
	;3)	AddNodes 
	;4)	Configure
	;5)	CrashSnake
	;6)	GameSpeed
	
; Problems with game:
	;1) Speed function does not work properly as it works after 11th apple is eaten
	;2) When running snake to the obstacle it leaves the shadow of the previous snake movement
	;3) Too much time delay with the keyboard
	;4) Should use more delay functions
	;5) Should use delete function to clear out the shadow of the previous movement (only happens sometimes)

INCLUDE Irvine32.inc


.data
	String1		BYTE "*********WELCOME TO SNAKE XENIA **********",0
	String2		BYTE "Your Score is: ",0				   	
	String3		BYTE "GAME OVER! Play Again?(Y/N)",0						
	String4		BYTE "Game speed is :",0  					
	x_head 		BYTE ?								; Variable that holds the "x" of the head of the snake.
	y_head 		BYTE ?								; Variable that holds the "y" of the head of the snake.
	head 		BYTE 2					
	node 		BYTE "#"							
	x_apple		BYTE ?								; Variable that holds the "x" of the apple.
	y_apple		BYTE ?								; Variable that holds the "y" of the apple.
	appleeaten	BYTE 0								; Apple eaten or not?
	direction 	BYTE 0  							
	olddirection 	BYTE 0								
	bricks1 	BYTE "±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±",0
	bricks2 	BYTE "±						 	±",0
	apple		BYTE "@"							; Character for apple.
	x_tail		BYTE ?								; Variable that holds the "x" of the tail of the snake. 
	y_tail		byte ?								; Variable that holds the "x" of the tail of the snake. 
	Nodes_X		BYTE 735 DUP(0)	
	Nodes_Y		BYTE 735 DUP(0)	
	NumOfNodes	DWORD 0								; The number of nodes snake has.
	score		DWORD 0								
	speed		WORD 0
	
	
.code
main PROC
	begin::
		pushad						; pushing all registers to begin procedure
		call Clrscr					; clearing out screen to avoid any memory collating with screen 
		mov ax,90        			; moves the value 90 into ax (accumulator) register for the angle 
		mov speed,ax	 			; moves the ax register value which is 90 into speed
		mov eax,0	 				; initializing eax register which is zero 
		mov score,eax	 			; initializing score with eax register which is zero
		mov eax,0	 				; moving zero again in eax register
		mov NumOfNodes,eax 			; initializing number of nodes with eax register which is zero
		mov al,0					; moves the value zero into al (accumulator) register for the apple counter
		mov appleeaten,al			; initializing the apple (obstacle counter)
		popad						; popping out all registers
		mov dl, 14					; placing the pointer at the column section initialized as Dl ( in left middle corner) 
		mov dh, 2					; Placing the pointer at the row section initialized as DH
		call Gotoxy					; placing it on the screen (screen size 80 x 25)
		mov eax, white+(blue*16)	; Text Color of Welcome Note
		call SetTextColor			; setting Text color using built in library function
		mov edx, OFFSET String1		; Printing Welcome Note(String1)
		call WriteString			; printing welcome note on the screen
		mov dl, 0					; placing the pointer at the column section initialized as Dl
		mov dh, 8					; Placing the pointer at the row section initialized as DH
		call Gotoxy			
		mov eax, green				; Green Color
		call SetTextColor			; Text Color GameSpeed Note(String4)
		mov edx, OFFSET String4		; showing game speed
		call WriteString
		mov dl, 14					; placing the pointer at the column section initialized as Dl					
		mov dh, 4					; Placing the pointer at the row section initialized as DH
		call Gotoxy					; calling gotoxy function to place it
		mov eax, cyan+(black*16)	; Background Color
		call SetTextColor			; setting text color
		mov edx, OFFSET bricks1		; Bricks(walls)
		call WriteString			; setting up wall bricks by at the corners
		mov ah, 20					; function to display it on the boundaries
		
	Wall:							; Wall Printing
		mov dl, 14					; setting up wall
		mov dh, ah					; moving dh into Ah 
		call Gotoxy			
		dec ah						; decrementing ah to locate it around all the boundary
		mov edx, OFFSET bricks2		; placing it by "+"
		call WriteString			; writing it to the screen
		cmp ah, 4					; comparing it by 4 until reaches the end of horizontal screen
		jg Wall						; jumping to wall (looping again)
		mov dl, 14					; moving value graph (14) on column 
		mov dh, 21					; moving value graph (21) on row 
		call Gotoxy
		mov edx, OFFSET bricks1		; Printing Pattern
		call WriteString
		
	RandomX:
		mov eax,36					; moving value of 36 into eax register
		mov x_head, al				; moving al register value into x_head
		mov esi, OFFSET Nodes_X		; bounds of the zone. Nodes_x is an array of 735 BYTE DUP(0)
		mov [esi], al				; moving al value into [esi] (memory address array as the counter)
		mov dl, al					; the coordinate is located into the array.
		
	RandomY:
		mov eax,12					; moving value of 12 into eax (accumulator)
		mov y_head, al				; specified according to the bounds of the zone, then the coordinate is located into the array.
		mov esi, OFFSET Nodes_Y		; moving Nodes_Y (an array of 735 bytes) into esi (memory address array as the counter)
		mov [esi], al				; moving al into esi  counter
		mov dh, al					; moving al into dh (row) which is the y_head
		call Gotoxy					; calling built in library gotoxy
		mov al, head				; moving al as the head counter
		call WriteChar				; writing the element
		
	Start:
		call CrashSnake				; Control if the snake eats itself.
		call ReadKey				; Read a key from the keyboard.
		jz SameDirection			; If no key is pressed the current direction be applied.
		cmp ah, 51H					; Keys except arrows
		jg Start					; looping around start by comparing the value 51H 
		cmp ah, 47H					; comparing value by 47H which is hexadecimal
		jl Start					; looping around to the start 
		call Move					; Start to move
		call Configure				; Some configurations about the snake.
		call PrintNodes				; Print the snake on the screen with its nodes.
		jmp Start					; jumping to start again
		
	SameDirection:
		mov ah, direction			; The label to specify the current direction.
		call Move					; Continue moving
		call Configure				; by controlling your configuration
		call PrintNodes				; and by printing yourself on the screen.
		jmp Start					; Jumping around start to check everything again				
	main ENDP
	
	
Move PROC USES eax edx
	mov direction, ah				; Game Speed is calculated and
	call GameSpeed					; printed on the screen.
	mov ax, speed
	movzx eax, ax					; It is done by delaying the motion
	call Delay						; of the snake.
	mov dl, 0						; The calculated speed is printed
	mov dh, 9						; on the screen.
	call Gotoxy						; Initializing the pointer of the game snake
	mov ax, speed				
	movzx eax, ax					; moves the unsigned values into a register and extends zero val to it 
	call WriteInt					; Here is the speed of the game.
	mov dl, x_head					; transferring the pointer as x_head and y_head
	mov dh, y_head
	call Gotoxy						; calling the x and y procedure to pin point the obstacle	
	mov al, ' '				
	call WriteChar					; When apple (obstacle is eaten) then it is attached to the pointer head(snake head)
	call EatApple					; calls to get to eat the apple 
	mov ah, direction				; The direction is passed to register "ah".
	mov al, olddirection			; The old direction is passed to register "al".
	cmp dl, 64						; If the head of the snake is located ob the bounds of the wall,unfortunately the game ends.
	jge GameOver					; jumps to game over if the head collides with the wall
	cmp dl, 14						; 64 - 16 dimensions are the wall boundary
	jle GameOver
	cmp dh, 21						;21 is also a wall boundary 
	jge GameOver
	cmp dh, 4
	jle GameOver
	cmp ah, 48H						; Controlling the motion of the obstacle if its upward
	je Up							; jumping to the function of up 
	cmp ah, 50H						; Controlling the motion of the obstacle if its downward
	je Down							; jumping to the function of down 
	cmp ah, 4DH						; Controlling the motion of the obstacle if its right side
	je Right						; jumping to the right side 
	cmp ah, 4BH						; Controlling the motion of the obstacle if its left side
	je Left							; jumping to the left side 
	jmp Finish
		
	Up:	
		mov olddirection, 48H		; The motion of the snake is
		cmp al, 50H					; This is being controlled by the keys to change direction
		je Down						; upwards now.
		dec dh						; decreasing DH as it is decreasing row to go upwards
		jmp UpdateHeadLoc			; jumps to update the head of the obstacle
		
	Down:
		mov olddirection, 50H		; The motion of the snake is
		cmp al, 48H					; Changing directions by keys
		je Up						; downwards now.
		inc dh						; increasing dh to go downwards as dh is rows
		jmp UpdateHeadLoc			; needs to update the head of the obstacle
		
	Right:
		mov olddirection, 4DH		; The motion of the snake is
		cmp al, 4BH					; changing directions by keys being used as input
		je Left						; leftwards now.
		inc dl						; incrementing column row
		jmp UpdateHeadLoc			; needs to update the head of the obstacle
		
	Left:
		mov olddirection, 4BH		; The motion of the snake is
		cmp al, 4DH
		je Right					; rightwards now.
		dec dl						; decreasing DL which is the column
		jmp UpdateHeadLoc
		
	UpdateHeadLoc:
		mov x_head, dl				; The head of the snake is
		mov y_head, dh				; updating the head of the snake as the position is being changed
		call Gotoxy					; located on the updated location.
		mov al, head
		call WriteChar				; Writing the head(front of the obstacle on the screen)
		
	Finish:
		ret							; returning the address of head and the dl and Dh of the section
		
	GameOver:
		mov dl, x_head				; If any error occurs the game ends
		mov dh, y_head
		call Gotoxy					; by this label.
		mov al, head				; Moving the address into the head
		call WriteChar				; Writing the head to end of the game 
		mov eax, 1000
		call Delay					; After a short delay,  "GAME OVER!!!" message is displayed
		mov dl, 33					; Changing the location of the obstacle to column [33]
		mov dh, 13					; on the screen and is returned to OS.
		call Gotoxy					; calling the built in library to place it
		mov eax, white+(red*16)		; Set Text Color of "GAME OVER!!!"
		call SetTextColor			; Changing the color of the text using built in library 
		mov edx, OFFSET String3		; Print Offset String3
		call WriteString	
		mov dl, 20				
		mov dh, 24
		pushad						; Pushing all the registers to the end
		call readchar
		cmp al,'y'					; Prompting for new game by comparing it by y or no (it does not work)
		popad
		je begin					; If prompted yes then jumps to the game section begin again
		call Gotoxy					; Setting up the board
		exit
Move ENDP
	
	
EatApple PROC USES eax edx
	NewApple:
		mov al, appleeaten			; After each apple is eaten
		cmp al, 0					; comparing it with zero
		jne NotEaten				; another apple is located randomly
	
	RandomX:
		mov appleeaten, 1			; on the screen.
		mov eax, 64					; Randomizing the range for the new apple being placed
		call RandomRange			; The "x" and the "y" of the new apple
		cmp al, 15					; comparing it with the 15
		jl RandomX					; are randomly specified and
		mov x_apple, al				; placing the apple on the X coordinate 
		mov dl, al					; printed on the screen.
	
	RandomY:
		mov eax, 18					; Random placement for the new apple at y coordinator
		call RandomRange			; getting the random number within the range 
		cmp al, 5	
		jl RandomY					; if the number is not within the range/then start the function again
		mov y_apple, al
		mov dh, al					; moving the al to DH which is row
		call Gotoxy
		mov al, apple
		call WriteChar				; Writing the apple on the screen/grid 
		mov al, dl
	
	NotEaten:
		mov al, x_head				; If the current apple on the screen
		mov ah, y_head				; transferring the head into the al/ah registers 
		mov dl, x_apple				; is not eaten,this means the head didn't
		mov dh, y_apple				; to check with the current apple 
		cmp ax, dx					; pass over the apple and eat it,another
		jne Finish					; if not eaten then jump to finish
		mov eax, NumOfNodes			; apple is not produced.
		inc eax						; apple is incremented
		mov NumOfNodes, eax			; Number Of Nodes of the snake is updated.
		mov appleeaten, 0			; There's no apple eaten yet.
		call AddNodes				; Update and add nodes to the snake.
		call GameScore				; Game Score is updated after each eaten apple.
		mov dl, 30					; transferring the to the pointer(obstacle)
		mov dh, 23
		call Gotoxy					; calling built in library function 
		mov edx, OFFSET String2		; Game Score is printed on the screen.
		call WriteString
		mov eax, score				; moving score into eax 
		call WriteInt				; Writing the score int 
		jmp Finish					; jumping to finish 
	
	Finish:
		ret							; returning the address
EatApple ENDP
	
	
AddNodes PROC USES eax ebx ecx esi
	mov ebx, NumOfNodes				; The procedure to control the
	cmp ebx, 1						; Comparing the nodes to add new nodes to be eaten
	jge Continue					; addition of the nodes and update the 
	mov esi, OFFSET Nodes_X			; getting the X node and y node and transferring it to the head
	mov al, x_head					; number of nodes.
	mov [esi], al
	mov al, [esi]					; Transferring Y node to the register
	mov esi, OFFSET Nodes_Y			; pasting it to esi memory address array 
	mov al, y_head
	mov [esi], al				
	mov al, [esi]					; Storing the score (1 or 0 to check the apple)
	jmp Finish
	
	Continue:						; If appleeaten is "0" then
		mov al, appleeaten			; the current apple was eaten and
		movzx eax, al				; if it is "1",
		cmp al, 0					; then the apple was not eaten.
		jne NotEaten				; jumping to the function not eaten
		
	Eaten:
		mov ecx, NumOfNodes			; Number of the nodes is
		inc ecx						; passed to register "ecx".
	
	ShiftRight:
		mov ebx, ecx				; The Shift Right operation
		mov esi, OFFSET Nodes_X		; moving the nodes_x into esi
		mov al, [esi+ebx-1]			; to make accommodation for
		mov [esi+ebx], al
		mov esi, OFFSET Nodes_Y		; new node. All of the nodes are
		mov al, [esi+ebx-1]			; moving the nodes_Y into esi and decrementing it by 1 to shift to the right side
		mov [esi+ebx], al			; shifted right and
		Loop ShiftRight
		mov esi, OFFSET Nodes_X		; the new node is placed by putting the values into the node X and Y 
		mov al, x_apple			
		mov [esi], al				; located to its place.
		mov esi, OFFSET Nodes_Y
		mov al, y_apple
		mov [esi], al	
		
	NotEaten:
		call Configure				; The nodes of the snake are
		call PrintNodes				; updated on each move and printed
	
	Finish:							; on the screen.
		ret							; returning to the main function
AddNodes ENDP


Configure PROC USES eax ebx ecx esi
	mov esi, OFFSET Nodes_X			; The configuration of the snake is
	mov al, [esi]					; getting the snake coordinates to the registers to configure it
	mov x_tail, al					; done by this procedure.
	mov esi, OFFSET Nodes_Y			; getting x and y nodes of the snake 
	mov al, [esi]					; The old tail is saved to be erased.
	mov y_tail, al					; replacing the old nodes 
	mov ebx, 1
	mov ecx, NumOfNodes
	inc ecx							; incrementing the nodes by one
	
	ShiftLeft:
		mov esi, OFFSET Nodes_X		; This Shift Left operation is applied to renew the locations of each nodes
		mov al, [esi+ebx]
		mov [esi+ebx-1], al			; shifting the snake to left side as the user direct to the left direction
		mov esi, OFFSET Nodes_Y
		mov al, [esi+ebx]			; getting the X nodes and Y nodes
		mov [esi+ebx-1], al			; Decrementing the column to shift left
		mov al, [esi]				 
		inc ebx						; Incrementing the row 
			
		Loop ShiftLeft				 
		mov ebx, NumOfNodes
		mov esi, OFFSET Nodes_X		; shifting the nodes again
		mov al, x_head
		mov [esi+ebx], al
		mov al, [esi]
		mov esi, OFFSET Nodes_Y		; transferring the values again into x and y nodes
		mov al, y_head
		mov [esi+ebx], al			; saving the location of the snake
		ret
Configure ENDP


PrintNodes PROC USES eax ebx ecx edx esi
	mov dl, x_tail					; The coordinates of the nodes and the head are taken from the arrays and
	mov dh, y_tail					; moving the x and y tail on the nodes 
	call Gotoxy				 
	mov al, ' '						; placing the node on the screen 
	call WriteChar					; Printing it to the screen
	mov ecx, NumOfNodes
	inc ecx							; incrementing the number of nodes
	
	Print:
		mov ebx, ecx
		mov esi, OFFSET Nodes_X
		mov al, [esi+ebx-1]			; Printing loop for all the nodes of the snake
		mov dl, al
		mov esi, OFFSET Nodes_Y
		mov al, [esi+ebx-1]			; The addresses of the arrays are
		mov dh, al
		call Gotoxy					; enough to reach each node and head.
		mov edx, NumOfNodes			; The head is printed as its own character
		inc edx						; Incrementing the address
		cmp ecx, edx				; and the nodes are printed as they are.
		jne PrintNode				; Printing the nodes 
		mov al, head				
		jmp Printt
	
	PrintNode:
		mov al, node
	
	Printt:
		call WriteChar
		Loop Print
		ret
PrintNodes ENDP


CrashSnake PROC USES eax ebx ecx edx esi
	mov ecx, NumOfNodes				; This procedure controls if the
	cmp ecx, 3
	jle Finish						; snake eats any of its nodes.
	inc ecx
	
	Crash:							; If it eats any of its nodes or tail
		mov ebx, ecx	
		mov esi, OFFSET Nodes_X		; it crashes and the game ends.
		mov al, [esi+ebx-2]
		mov dl, al
		mov esi, OFFSET Nodes_Y		; The coordinates of the head are
		mov al, [esi+ebx-2]
		mov dh, al					; compared with the nodes and tail
		mov al, x_head
		mov ah, y_head				; which are held into the arrays that
		cmp dx, ax
		je Lengthh					; are named Nodes_X and Nodes_Y.
		jmp Endd
		
	Lengthh:						; The snake cannot eat its head so,
		mov edx, NumOfNodes
		inc edx						; after 3 nodes this control is started.
		cmp ecx, edx
		je Endd

	EndOfGame:
		mov dl, x_head				; If the snake eats its nodes or tail,
		mov dh, y_head
		call Gotoxy					; the game ends because of the crash.
		mov al, head
		call WriteChar
		mov dl, 33
		mov dh, 13					; The game ending signs are configured
		call Gotoxy
		mov edx, OFFSET String3		; and printed on the screen.
		call WriteString
		pushad
		call readchar
		cmp al,'y'
		je begin
		popad
		exit
	
	Endd:
		Loop Crash
	
	Finish:
		ret
CrashSnake ENDP


GameScore PROC USES eax				; This procedure controls
	mov eax, score
	add eax, 1						; the score of the game.
	mov score, eax					; Each eaten apple is "1" point.
	ret								; It is performed accoding to the
GameScore ENDP						; number of the apples eaten.


GameSpeed PROC USES eax ebx edx
	mov edx, 0				
	mov eax, score					; moving score into the register
	mov ebx, 10						; moving 10 into ebx
	div ebx							; if the score divided by 10 is more than one then the speed is increased
	cmp edx, 1
	jne Finish						; if its not equal to one then jumps to the finish section
	mov ax, speed					; else increase it by 10 
	mov bx, 10
	sub ax, bx						; After each 10 apple, the speed of the game increases.
	mov speed, ax
	mov eax,score					; moving ths score again into eax register		
	add eax,1
	mov score,eax 
	
	Finish:
		ret
GameSpeed ENDP


	exit
END main