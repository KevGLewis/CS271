TITLE Program Template     (template.asm)

; Author: Kevin Lewis (lewikevi)
; Course / Project ID CS271                Date:7/10/2017
; Description: Program calculates a series of Fibonacci Numbers based on the User's request

INCLUDE Irvine32.inc

UPPER_LIMIT = 46	;Max Number of Fibonacci Values that the user can ask for
MAX_ITEMS_ROW	= 5		;Max number of terms in a row

.data

intro_1		BYTE	"Fibonacci Numbers", 0
intro_2		BYTE	"Programmed by Kevin Lewis", 0
instr_1		BYTE	"What's your name? ", 0
user_name	BYTE	30	DUP(?)
instr_2		BYTE	"Hello, ", 0
instr_3		BYTE	"Enter the numer of fibonacci terms to be displayed", 0
instr_4		BYTE	"Give the number as an integer in the range [1 .. 46]", 0
instr_5		BYTE	"How many fibonacci terms do you want? ", 0
error_1		BYTE	"Out of range. Enter a number in [1 .. 46]", 0
numb_term	BYTE	?			;Will store the number of terms to be displayed (less than 47)
prev_1		DWORD	?			;Stores the 2nd previous fibonacci term
prev_2		DWORD	?			;Stores the 1st previous fibonacci term
max_row		DWORD	5			;Maximum number of values in a row
add_sp_1	BYTE	" ", 0		;Add one space for alignment purposes
add_sp_2	BYTE	"  ", 0		;Adds two spaces for alignment purposes
add_sp_3	BYTE	"   ", 0	;Adds three spaces for alignment purposes
add_sp_4	BYTE	"    ", 0 	;Add spaces to first fibonacci term
num_digit	DWORD	?			;Stores the number of digits a number has
num_spaces	DWORD	?			;Stores the number of required spaces
goodBye_1	BYTE	"Results certified by Kevin Lewis", 0
goodBye_2	BYTE	"Goodbye, ", 0

.code
main PROC

; introduction
	mov		edx, OFFSET	intro_1
	call	WriteString
	call	CrLf

	mov		edx, OFFSET intro_2
	call	WriteString
	call	CrLf
	call	CrLf

; Get the User's name
	mov		edx, OFFSET instr_1
	call	WriteString
	
	mov		edx, OFFSET user_name
	mov		ecx, SIZEOF	user_name
	call	ReadString
	
; userInstructions
	mov		edx, OFFSET instr_2
	call	WriteString

	mov		edx, OFFSET user_name		;Say Hello to the user
	call	WriteString
	call	CrLf

	mov		edx, OFFSET instr_3
	call	WriteString
	call	CrLf

	mov		edx, OFFSET instr_4
	call	WriteString
	call	CrLf
	call	CrLf

	jmp		instructions

; getUserData
error:									;Jump back to this point if user's value doesn't validate
	mov		edx, OFFSET error_1
	call	WriteString
	call	CrLf

instructions:
	mov		edx, OFFSET instr_5
	call	WriteString
	call	ReadDec
	mov		edx, eax

; Validate User's Number (Must be between 0 and 46)
	cmp		eax, 1
	jb		error
	cmp		eax, UPPER_LIMIT
	jnbe	error

	mov		numb_term, al			;Store the number of terms we want to display
	call	CrLf

; displayFibs
	
	; Display the first fibonacci value, 1 Set up the prev terms
	mov		ecx, eax
	mov		ebx, 0
	mov		eax, 1
	call	WriteDec
	
	mov		edx, OFFSET add_sp_4	;Adds spaces to keep number aligned
	call	WriteString

	mov		prev_2, ebx				;Set up the second term in the sequence
	mov		prev_1, eax				;Set up the first term in the sequenece

	dec		ecx						;We displayed the first term outside of the loop

;Check if the number of terms requested was one, if so, skip the rest of the terms 
	cmp		ecx, 0
	je		goodBye

fibCompute:

	; Check if we need to move to the next line
	mov		edx, 0
	mov		eax, ecx
	mov		ebx, max_row
	div		ebx					;See if we are at the max number of values in a row

	cmp		edx, 0
	ja		no_CrLf

	call	CrLf				;Move to the next line if at the end of a row

no_CrLf:

	mov		eax, prev_2
	mov		ebx, prev_1
	add		eax, ebx
	call	WriteDec
	
	; Store the values
	mov		prev_2, ebx
	mov		prev_1, eax
	
	;Determine how many digits the number has. 5-num digits spaces

	mov		num_digit, 0

digitCount:						;Divide the fibonacci number by 10 in a loop until it equals zero
	mov		edx, 0
	mov		ebx, 10
	div		ebx					;Divide number by 10
	inc		num_digit			;Increase the num of digits for each loop
	cmp		eax, 0				;If there is nothing remaining, jump out of the loop
	je		add_spaces
	jmp		digitCount

add_spaces:
	mov		eax, num_digit		
	mov		edx, OFFSET add_sp_1
	call	WriteString
	inc		num_digit
	cmp		num_digit, 5
	je		finish_loop
	jmp		add_spaces

finish_loop:
	mov		num_spaces, eax
	loop	fibCompute

goodBye:	
	call	CrLf

; farewell
	call	CrLf
	mov		edx, OFFSET goodBye_1
	call	WriteString
	call	CrLf

	mov		edx, OFFSET goodBye_2
	call	WriteString

	mov		edx, OFFSET	user_name	;Include the user's name in the farewell address
	call	WriteString
	call	CrLf
	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
