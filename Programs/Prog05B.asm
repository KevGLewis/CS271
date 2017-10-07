TITLE Program #5B     (Prog05B.asm)

; Author: Kevin Lewis (LewiKevi)
; Course / Project ID    CS 271 / Programming Assignment #5B  Date: 8/4/2017
; Description: Per the Assignment #5 B Homework Description, the system will ask the student
; to calculate the number of combinations of r items taken from a set of n items.
; The system generates problems with n in [3 .. 12] and r in [1 .. n]. The student enters
; his/her answer, and the system reports the correct answer and an evaluation of the student's
; answer. The system repeats until the student chooses to quit.
INCLUDE Irvine32.inc
INCLUDE Macros.inc

RANGE_SIZE = 9
LOWER_LIMIT = 3
NUMB_LIMIT	= 1000

.data

intro_1		BYTE	"Welcome to the Combinations Calculator           Programmed by Kevin Lewis",0
EC_1		BYTE	"**EC: Align the columns", 0
intro_2		BYTE	"I'll give you a combinations problem. You enter your answer,", 0
intro_3		BYTE	"and I'll let you know if you're right", 0
prompt_4	BYTE	"How many ways can you choose? ", 0
user_ans	DWORD	3		; User's # of combinations answer
answer		DWORD	20		; the resultant number of combinations
n_items		DWORD	0		; number of items in the set
r_items		DWORD	0		; r items from a set

.code
main PROC
	call	Randomize

	call	intro

L1:
	call	Crlf

	push	OFFSET n_items
	push	OFFSET r_items
	call	showProblem

	push	OFFSET user_ans
	call	getData

	push	n_items
	push	r_items
	push	OFFSET answer
	call	combinations

	push	n_items
	push	r_items
	push	user_ans
	push	answer
	call	showResults

	call	Crlf

L2:
	mWrite	"Another problem? (y/n): "
	call	ReadChar
	call	Crlf
; If y, repeat, if n, end, if neither repeat
	mov		bl, 121				;ASCII "y"
	cmp		al, bl
	je		L1
	mov		bl, 110				;ASCII "n"
	cmp		al, bl
	je		main_end
	
; The user provided an invalid response
	mWrite	"Invalid response. "
	jmp		L2

main_end:
	call	Crlf
	mWrite	"OK ... goodbye."
	call	Crlf

	exit	; exit to operating system
main ENDP

;--------------------------------------------------------------------
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

;Display the introduction, part 1
	mov		edx, OFFSET intro_2
	call	WriteString
	call	CrLF

;Display the introduction, part 2
	mov		edx, OFFSET intro_3
	call	WriteString
	call	CrLF
	
	leave
	ret
intro	ENDP
;---------------------------------------------------------------------------------------------


showProblem	PROC USES EAX EBX
;---------------------------------------------------------------------------------------------
;Displays the problem parameters (n and r)
;receives (push order): n (reference), r (reference)
;returns: none
;preconditions: n and r are word variables
;registers changed: none

	push	ebp
	mov		ebp, esp

; Store the total number of items
	mov		eax, RANGE_SIZE
	inc		eax
	call	RandomRange
	add		eax, LOWER_LIMIT

	mov		ebx, [ebp + 20]			;n
	mov		[ebx], ax

; Store the number of items to combine (note, eax already store n_items)
	dec		eax				;we want between 1 and n-1
	call	RandomRange
	inc		eax
	mov		ebx, [ebp + 16]			;r
	mov		[ebx], ax

; Display the prompts and the numbers to the user
	mWrite	"Problem:"
	call	Crlf
	mWrite  "Number of elements in the set: "
	mov		ebx, [ebp + 20]			;n
	mov		eax, [ebx]
	call	WriteDec
	call	Crlf

	mWrite	"Number of elements to choose from the set: "
	mov		ebx, [ebp + 16]			;r
	mov		eax, [ebx]
	call	WriteDec
	call	Crlf

	pop		ebp
	ret		8
showProblem	ENDP
;---------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------
getData	PROC USES EAX EBX ECX EDX
	LOCAL	buffer[10]: BYTE,
			dec_convert: DWORD
;Gets and store the result from the user
;receives (push order): result (reference)
;returns: none
;preconditions: None
;registers changed: none

getData_beginning:
	; First clear the String
	mov		ecx, LENGTHOF buffer
	mov		esi, 0
getData_clear_string:
	mov		buffer[esi], 0
	inc		esi
	loop	getData_clear_string

; Present the problem to the user
	mov		dec_convert, 0
	mWrite	"How many ways can you choose? "

; Get the integer and then store it
	lea		edx, buffer
	mov		ecx, SIZEOF buffer
	call	Readstring

	mov		ecx, LENGTHOF buffer
	mov		esi, 0
; Convert the string to a number. The basic formula is check that the character is a number
; (between 48 and 57). Convert the character to a number, by subtracting 48. Then add it to the
; total by first adding the place (aka 10th, 100th, 1000th, etc.).
getData_convert:
	movzx	ebx, buffer[esi]
	cmp		ebx, 48
	jb		getData_break
	cmp		ebx, 57
	ja		getData_break
	sub		ebx, 48
; store eax and add the place value
	mov		eax, dec_convert
	mov		edx, 10
	mul		edx
	add		eax, ebx
	mov		dec_convert, eax
	inc		esi
	loop	getData_convert
	
	jmp		getData_end

getData_break:
; Check if the null terminator has been reached
	cmp		ebx, 0
	je		getData_end

getData_error:

;Give the error message
	call	Crlf
	mWrite	"Invalid response. "
	jmp		getData_beginning

getData_end:
	mov		ebx, [ebp + 8]
	mov		eax, dec_convert
	mov		ecx, [ebx]
	mov		[ebx], eax

	call	Crlf

	ret		4
getData	ENDP
;-------------------------------------------------------------------------------------------

showResults	PROC USES EAX EBX,
;---------------------------------------------------------------------------------------------
;Displays the student's answer, calculated result and statement about the
; student's performance
;receives (push order): n (value), r (value), answer (value), result (value)
;returns: none
;preconditions: None
;registers changed: none

	push	ebp
	mov		ebp, esp

	mWrite "There are "
	mov		eax, [ebp + 16]			;Result
	call	WriteDec

	mWrite " combinations of "
	mov		eax, [ebp + 24]			;r
	call	WriteDec

	mWrite	" items from a set of "
	mov		eax, [ebp + 28]			;n
	call	WriteDec
	mWrite	"."

	call	Crlf

	mov		eax, [ebp + 16]			;Result
	mov		ebx, [ebp + 20]			;Answer
	cmp		eax, ebx
	jne		showResults_incorrect

	mWrite "You are correct!"
	jmp		showResults_end

showResults_incorrect:
	mWrite "You need more practice."

showResults_end:
	call	Crlf

	pop		ebp
	ret		12
showResults	ENDP
;---------------------------------------------------------------------------------------------

combinations PROC USES EAX EBX
	LOCAL	n_fact: DWORD,
			r_fact: DWORD,
			n_r_fact: DWORD
;---------------------------------------------------------------------------------------------
;Displays the student's answer, calculated result and statement about the
; student's performance
;receives (push order): n (value), r (value), result (reference)
;returns: none
;preconditions: 
;registers changed: none

; Find n factorial
	mov		eax, [ebp + 16]			;n
	lea		ebx, n_fact
	push	eax
	push	ebx
	call	factorial

; Find r factorial
	mov		eax, [ebp + 12]			;r
	lea		ebx, r_fact
	push	eax
	push	ebx
	call	factorial

; Find n-r factorial
	mov		eax, [ebp + 16]			;n
	mov		ebx, [ebp + 12]			;r
	sub		eax, ebx
	lea		ebx, n_r_fact
	push	eax
	push	ebx
	call	factorial

; Determine the resultant
	mov		eax, r_fact
	mov		ebx, n_r_fact
	mul		ebx

	mov		ebx, eax
	mov		eax, n_fact
	div		ebx
	mov		ebx, [ebp + 8]			;result
	mov		[ebx], eax

	ret		12
combinations	ENDP
;---------------------------------------------------------------------------------------------

factorial	PROC USES EAX EBX
;---------------------------------------------------------------------------------------------
;Recursive procedure to determine the factoral of a number
;receives (push order): factorial (value), result (reference)
;returns: none
;preconditions: None
;registers changed: none

	push	ebp
	mov		ebp, esp
; See if the base case of 1 is current
	mov		eax, [ebp + 20]
	cmp		eax, 1
	je		factorial_one

; Recursively call the factorial function if it isn't 1
	dec		eax
	push	eax
	mov		ebx, [ebp + 16]
	push	ebx
	call	factorial

; Now multiply the result of the factorial procedure by the current value
	mov		ebx, [ebp + 16]
	mov		eax, [ebx]
	mov		ebx, [ebp + 20]
	mul		ebx
	mov		ebx, [ebp + 16]
	mov		[ebx], eax
	jmp		factorial_end

factorial_one:
	mov		eax, [ebp + 16]
	mov		ebx, 1
	mov		[eax], ebx

factorial_end:
	
	pop		ebp
	ret		8
factorial	ENDP
;---------------------------------------------------------------------------------------------


END main
