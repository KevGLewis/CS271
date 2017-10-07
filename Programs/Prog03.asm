TITLE Program #3     (Prog03.asm)

; Author: Kevin Lewis (LewiKevi)
; Course / Project ID    CS 271 / Programming Assignment #3  Date: 7/22/2017
; Description: Program calculates composite numbers.
; First, the user is instructed to enter the number of composites to be display.
; The user enters a number, and the program verifies it is within parameters [1 - 400]
; If out of range, the user is reprompted until he or she provides a value in the range
; The program then displays the composites

INCLUDE Irvine32.inc

UPPER_LIMIT = 401
COL_WIDTH	= 5		; Column size in spaces
TEST_LIMIT = 50

.data

intro_1		BYTE	"Composite Numbers    Programmed by Kevin Lewis",0
EC_1		BYTE	"**EC: Align the columns", 0
intro_2		BYTE	"Enter the number of composite numbers you would like to see.", 0
intro_3		BYTE	"I'll accept orders for up to 400 composites.", 0
instr_1		BYTE	"Enter the number of composites to display [1 .. 400]: ", 0
error_1		BYTE	"Out of range. Try again.", 0
test_numb	DWORD	?	;Number to be tested
comp_limit	DWORD	?	;user specified upper composite limit
col_count	DWORD	?	;counts how many numbers have been printed
pArray		WORD	2, 3, 5, 7, 11, 13, 17, 19
array_size	DWORD	8	;Size of the prime number array
isCompNumb	BYTE	?	;Boolean, holds whether or not a number is composite.
print_cnt	WORD	?	;Holds the number of values printed
space_1		BYTE	" ", 0	;Space for alignment purposes
space_5		BYTE	"     ", 0
goodBye		BYTE	"Results certified by Kevin Lewis. Goodbye.", 0
num_digit	DWORD	?	;Will hold the number of digits each value has
.code
main PROC

	call	intro
	call	getUserData
	call	showComposites
	call	farewell

	exit	; exit to operating system
main ENDP

;----------------------------------------------------------------------------------------------
intro	PROC
;Procedure to print the instructions to the command line
;receives: nothing
;returns: nothing
;preconditions: nothing
;registers changed: none

	enter	0, 0

;Display program Name and Author
	mov		edx, OFFSET intro_1
	call	WriteString
	call	CrLF

;Display Extra Credit
	mov		edx, OFFSET EC_1
	call	WriteString
	call	CrLF
	call	CrLF

;Display the first instruction
	mov		edx, OFFSET intro_2
	call	WriteString
	call	CrLF

;Display the second instruction
	mov		edx, OFFSET intro_3
	call	WriteString
	call	CrLF
	call	CrLF
	
	leave
	ret
intro	ENDP
;---------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------
getUserData	PROC
;Procedure to get composite range from the user
;receives: nothing
;returns: user specified upper limit (in EAX)
;preconditions: nothing
;registers changed: eax

	enter	0, 0

instructions:
; display the instructions to the user
	mov		edx, OFFSET instr_1
	call	WriteString

;Get the number from the user and validate
	call	ReadDec
	call	validate
	cmp		ebx, 1
	jae		validNumber

;if no jump occured, number is invalid, display the error
	mov		edx, OFFSET error_1
	call	WriteString
	call	CrLf
	jmp		instructions
	
validNumber:
	mov		comp_limit, eax
	call	Crlf

	leave
	ret
getUserData	ENDP
;-------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
validate	PROC
;Procedure to ther user specified upper limit is within the acceptable range
;receives: upper limit
;returns: True / False depending on if value is acceptable (in ebx)
;preconditions: upper limit is in eax
;registers changed: ebx

	enter	0, 0

; Confirm the number is within range [1 - 400]
	cmp		eax, UPPER_LIMIT
	jae		validate_invalid
	cmp		eax, 1
	jb		validate_invalid
	jmp		validate_valid

validate_invalid:
	mov		ebx, 0
	jmp		validate_done
	
validate_valid:
	mov		ebx, 1

validate_done:

	leave
	ret
validate	ENDP
;------------------------------------------------------------------------------------------


;------------------------------------------------------------------------------------------
showComposites	PROC
;Run through the numbers from 1 to the upper limit
;Check whether each number is composite
;receives: User specified upper limit
;returns: Prints composite values to command line
;preconditions: Upper limit saved in memory
;registers changed: eax, ebx, ecx
	enter	0, 0
	mov		ecx, comp_limit
;We will determine what numbers to display by subtracting ecx from the limit
;The first composite number is 2, therefore we need to decrease the ecx counter twice.
;Also, we need to check if the limit was set to 1, as this will cause an infinite loop.
	dec		ecx
	dec		ecx
	cmp		ecx, 0
	jb		showComposites_finished

showComposites_loop:
	mov		eax, comp_limit
	sub		eax, ecx
	call	isComposite
	movzx	ebx, isCompNumb
	cmp		ebx, 1
	jne		showComposites_NotComp
	inc		print_cnt
	call	WriteDec
	call	alignColumn
	call	maintainRow

showComposites_NotComp:
	loop	showComposites_loop

showComposites_finished:

	leave
	ret
showComposites	ENDP
;------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------
isComposite	PROC
;Procedure to verify a number is composite
;receives: number to be verified
;returns: boolean in isCompNumb (1 = True aka "composite", 0 = false "not composite")
;preconditions: number is in eax
;registers changed: ebx

	enter	0, 0
	pusha

;Need to run through the array of prime numbers, if the number divides evenly into any of the number (aka no remainder)
;Then we know the number is not 
	
	mov		ecx, array_size
	mov		ebx, 0
	mov		test_numb, eax

isComposite_Loop:
	cdq
;Get prime number from array, if the prime number is greater than the tested value, than the tested value is prime.
;However, if the prime number divides evenly into the tested value, than the tested value is composite.
;The tested value is also proven to be prime if it does not divide evenly into any of the primes.
	mov		eax, array_size
	sub		eax, ecx
	movzx	ebx, pArray[eax*2]
	mov		eax, test_numb
	div		ebx
	cmp		edx, 0
	je		isComposite_TRUE
	loop	isComposite_Loop

isComposite_FALSE:
	mov		isCompNumb, 0
	jmp		isComposite_END

isComposite_TRUE:
; Need to account for situation where we are testing a prime number. Ex: comparing 2 to 2
; Primes will initially test as true, so we shall add a second test here to weed them out.
; If the quotient is 1, we know it is a prime because only numbers with a zero remainder will
; reach this point
	cmp		eax, 1
	je		isComposite_FALSE
	mov		isCompNumb, 1
	
isComposite_END:

	popa
	leave
	ret
isComposite	ENDP
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
alignColumn	PROC
;Aligns numbers with columns, adds spaces to number fill in rest of
;column up to the column width.
;receives: number to add spaces to (eax)
;returns: prints spaces
;preconditions: number to add spaces to is in eax
;registers changed: none
	enter	0, 0
	pusha

	mov		num_digit, 0				;Initialize the number of digits

digitCount:								;Divide the number by 10 in a loop until it equals zero
	cdq
	mov		ebx, 10
	div		ebx							;Divide number by 10
	inc		num_digit					;Increase the num of digits for each loop
	cmp		eax, 0						;If there is nothing remaining, jump out of the loop
	je		add_spaces
	jmp		digitCount

add_spaces:								;Add Spaces until the column width has been met
	mov		edx, OFFSET space_1
	call	WriteString
	inc		num_digit
	cmp		num_digit, COL_WIDTH
	jne		add_spaces

	popa
	leave
	ret
alignColumn	ENDP
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
maintainRow	PROC
;Procedure to maintain the max number of values printed per row
;the max number is a global constant
;receives: c
;returns: Nothing
;preconditions: upper limit is in eax
;registers changed: None
	enter	0, 0

; maintain the registers
	pusha

; Divide the total number of values printed, if it divides evenly by the 
; max column size, then we know the row is full and we must jump down to
; the next row.
	movzx	eax, print_cnt
	cdq		
	mov		ebx, COL_WIDTH
	div		ebx
	cmp		edx, 0
	jne		maintainRow_done

; restore the registers
	popa
	call	Crlf

maintainRow_done:

	leave
	ret
maintainRow	ENDP
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
farewell	PROC
; Outputs Goodbye text
; receives: nothing
; returns: nothing
; preconditions: nothing
;registers changed: edxg
	enter 0, 0
;Display the farewell Message
	call	CrLF
	call	CrLF
	mov		edx, OFFSET goodBye
	call	WriteString
	call	CrLF

	leave
	ret
farewell	ENDP
;---------------------------------------------------------------------------


END main
