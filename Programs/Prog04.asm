TITLE Program #4     (Prog04.asm)

; Author: Kevin Lewis (LewiKevi)
; Course / Project ID    CS 271 / Programming Assignment #4  Date: 7/30/2017
; Description: 

INCLUDE Irvine32.inc

UPPER_LIMIT = 400
LOWER_LIMIT = 10
ROW_WIDTH	= 10		;Number of values in 1 row
COL_WIDTH	= 10		; Column size in spaces
NUMB_LIMIT	= 1000

.data

intro_1		BYTE	"Sorting Random Integers           Programmed by Kevin Lewis",0
EC_1		BYTE	"**EC: Align the columns", 0
intro_2		BYTE	"This program generates random numbers in the range [100 .. 999],", 0
intro_3		BYTE	"displays the original list, sorts the list, and calculates the", 0
intro_4		BYTE	"median value. Finally, it displays the list sorted in descending order.", 0
instr_1		BYTE	"How many numbers should be generated? [10 .. 400]: ", 0
instr_2		BYTE	"The unsorted random numbers:", 0
instr_3		BYTE	"The median is ", 0
instr_4		BYTE	"The sorted list:", 0
array_size	DWORD	?	;Size of the array
error_1		BYTE	"Invalid input", 0
array_1		WORD 400 DUP(?)	
space_2		BYTE	"  ",0
median_1	BYTE	"The median is ",0

.code
main PROC
	call	Randomize

	call	intro

	push	OFFSET array_size
	push	OFFSET instr_1
	push	OFFSET error_1
	call	getData

	call	Crlf

	push	array_size
	push	OFFSET array_1
	call	fillArray

	push	OFFSET array_1
	push	array_size
	push	OFFSET  instr_2
	call	displayList

	call	Crlf

	push	OFFSET array_1
	push	array_size
	call	sortList

	call	displaymedian

	call	Crlf
	call	Crlf

	push	OFFSET array_1
	push	array_size
	push	OFFSET instr_4
	call	displayList

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

;Display the introduction, part 1
	mov		edx, OFFSET intro_2
	call	WriteString
	call	CrLF

;Display the introduction, part 2
	mov		edx, OFFSET intro_3
	call	WriteString
	call	CrLF

;Display the introduction, part 3
	mov		edx, OFFSET intro_4
	call	WriteString
	call	CrLF
	call	Crlf
	
	leave
	ret
intro	ENDP
;---------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------
getData	PROC USES EAX EBX EDX
;Get the number of integers to be generated from the user
;receives (push order): Number storage (reference), user prompt (reference), error message (reference)
;returns: none
;preconditions: None
;registers changed: none

	push	ebp
	mov		ebp, esp

	jmp		getData_L1

getData_Invalid:
	mov		edx, [ebp + 20]			;error message
	call	WriteString
	call	Crlf
	
getData_L1:
	mov		edx, [ebp + 24]			;user prompt
	call	WriteString
	call	ReadInt
; Verify the number is within the range

	cmp		eax, LOWER_LIMIT
	jb		getData_Invalid
	cmp		eax, UPPER_LIMIT
	jg		getData_Invalid
	mov		ebx, [ebp + 28]
	mov		[ebx], eax

	call	Crlf

	pop		ebp
	ret		12
getData	ENDP
;-------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
fillArray	PROC USES EAX EBX ECX
;Fills an array with random values
;receives (push order): array size (value), array (reference)
;returns: True / False depending on if value is acceptable (in ebx)
;preconditions: upper limit is in eax
;registers changed: ebx
	push	ebp
	mov		ebp, esp

	mov		ecx, [ebp + 24]
	mov		edi, [ebp + 20]

; Run through array, filling each index with a random value
fillArray_L1:
	mov		eax, NUMB_LIMIT
	call	RandomRange
	mov		[edi], ax
	add		edi, 2
	loop	fillArray_L1

	pop		ebp
	ret		8
fillArray	ENDP
;------------------------------------------------------------------------------------------


;------------------------------------------------------------------------------------------
sortList	PROC USES EAX EBX ECX EDX
;Sorts list via the selection sort. take the first value. Run through the remaining values in the array
;if a subsequent value is greater, than switch the position in the array. Continue to do so
;Until you've reached the end of the array
;receives (push order): array (reference), size (value)
;returns: Nothing, sorts the array via descending order
;preconditions: None
;registers changed: None
	push	ebp
	mov		ebp, esp
	mov		eax, 0
	mov		ebx, 0

	mov		ecx, [ebp + 24]		;Array Size
	dec		ecx					;The outer loop goes < request - 1
	mov		edi, [ebp + 28]		;Array
	mov		bl, [edi + 2]

;Run through every index in the array
sortList_L1:

;Check every subsequent index's value. If it is greater than switch the value
;First save the registers before moving into the inner loop
	push	ecx
	mov		esi, edi			;save edi (k) to esi (j)

sortList_L2:
	add		esi, 2
	mov		ax, [edi]
	mov		bx, [esi]
	
	cmp		ax, bx
	jae		no_exchange

	push	edi
	push	esi
	call	exchangeElements

no_exchange:	

	loop	sortList_l2

	pop		ecx
	add		edi, 2
	loop	sortList_L1

	pop		ebp
	ret
sortList	ENDP
;------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------
exchangeElements	PROC USES EAX EBX ECX EDX
;Switches two elements within an array
;receives: array[i] (reference), array[j] (reference), i and j are indexes of elements to be exchanged
;returns: Exchanges values in the array
;preconditions: array is array of WORD
;registers changed: None
	push	ebp
	mov		ebp, esp

;Copy the value of i, move the value of j into i, move the value of i into j
	mov		eax, [ebp + 24]		;array[i] reference
	mov		ebx, [ebp + 28]		;array[j] reference
	mov		dx, [eax]
	mov		cx, [ebx]
	mov		[eax], cx
	mov		[ebx], dx

	pop		ebp
	ret		8
exchangeElements	ENDP
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
displayMedian PROC USES EAX EBX
;displays the median value in an array
;receives: Array (reference), size of array (value)
;returns: prints the median value
;preconditions: Array is array of words
;registers changed: none
	push	ebp
	mov		ebp, esp

	mov		edx, OFFSET median_1
	call	WriteString

	mov		eax, [ebp + 16]			; array size
	mov		esi, [ebp + 20]			; Array (reference)

; Determine if there is an even number or odd number of values in array
; if even, take average of two middle number. if odd, just take the 
; middle number
	mov		ebx, 2
	cdq
	div		ebx
	cmp		edx, 0
	je		displayMedian_even

; convert the index to the correct offest. Currently the pointer is pointing
; to the middle value
	mov		ebx, 2
	mul		ebx
	mov		bx, [esi + eax]
	movzx	eax, bx
	call	WriteDec

	jmp		displayMedian_end

displayMedian_even:
; convert the index to the correct offest. Currently the pointer is pointing
; to the larger of the two index. Take the average of the two values
	mov		ebx, 2
	mul		ebx
	mov		bx, [esi + eax]
	sub		eax, 2
	mov		cx, [esi + eax]

	add		bx, cx
	movzx	eax, bx

	mov		ebx, 2
	cdq
	div		ebx
	call	WriteDec	
	

displayMedian_end:



	pop		ebp
	ret
displayMedian	ENDP
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
displayList	PROC USES EDX ECX
;Procedure to display values in an array
;receives (push order): array (reference), array size(value), prompt (reference)
;returns: Nothing
;preconditions:
;registers changed: EAX, EBX

	push	ebp
	mov		ebp, esp

;Write the user prompt
	mov		edx, [ebp + 16]			;Prompt
	call	WriteString
	call	Crlf

;Loop through the array, displaying the values
	mov		ecx, [ebp + 20]			;Array size
	mov		esi, [ebp + 24]			;Array (reference)

displayList_L1:
	mov		bx, [esi]
	movzx	eax, bx
	call	WriteDec

;Determine the order of the value (1st, 2nd, 3rd, etc.)
	mov		eax, [ebp + 20]
	sub		eax, ecx
	push	ROW_WIDTH
	push	eax
	
	mov		edx, OFFSET space_2
	call	WriteString

;Move to the next row after capacity has been met
	call	maintain_row
	add		esi, 2
	loop	displayList_L1

	call	Crlf
	
	pop		ebp
	ret		12
displayList	ENDP
;----------------------------------------------------------------------------

maintain_row	PROC USES EAX EBX EDX
;Determines when to move to the next line
;receives (push order): Column Width (value), number of value (1st, 2nd, etc) (value)
;returns: Nothing
;preconditions: upper limit is in eax
;registers changed: None

	push	ebp
	mov		ebp, esp

; Only move to the next row when the end of the row has been reached
; Disregard the 0th (first) value
	mov		eax, [ebp + 20]				;Number of value
	cmp		eax, 0
	je		maintain_row_end

	mov		ebx, [ebp + 24]				;Column Width
	cdq
	div		ebx
	dec		ebx							;Move to next row at n-1th value

	cmp		edx, ebx
	jne		maintain_row_end

	call	Crlf

maintain_row_end:

	pop		ebp
	ret		8
maintain_row	ENDP
;----------------------------------------------------------------------------


END main
