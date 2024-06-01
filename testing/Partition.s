LDA X0, start
LDA X1, end
LDA X2, list

LDUR X0, [X0, #0]
LDUR X1, [X1, #0]


BL Partition
STOP

Partition:
	SUBI	SP, SP, #64	// Allocate 64 bytes of memory (4 double words) to this function
	STUR	FP, [SP, #0]	// FP of parent is saved onto my stack SP+0
	STUR	LR, [SP, #8]	// LR should be saved to retrieve it later
	ADDI	FP, SP, #56	// FP is moved up from parent's to mine


	STUR X0, [X2, #0] //*node = start
	STUR X1, [X2, #8] //*(node+1) = end
if_part:
	SUBS XZR, X0, X1 // checks if start = end
	B.NE else_part
	SUBI X9, XZR, #1 // storing NULL in X9
	STUR X9, [X2, #16] // *(node + 2) = NULL
	STUR X9, [X2, #24] // *(node + 3) = NULL
	B retpart
	
else_part:
	STUR X0, [SP, #16]	// First, make sure we backup registers that we need and are our
	STUR X1, [SP, #24]
	STUR X2, [SP, #32]	

	//ADDI X14, X0, #8 // *(start + 1)
	//ADDI X15, X1, #8 // *(end + 1)
	LDUR X2, [X0, #8] // left_sum = *(start + 1)
	LDUR X3, [X1, #8] // right_sum = *(end + 1)
	
	BL FindMidpoint
	LDUR X0, [SP, #16]	// Restore the value of registers that we backed up
	LDUR X1, [SP, #24]
	LDUR X2, [SP, #32]

	ADD X10, X4, XZR // storing midpoint in X10
	SUB X11, X10, X0 // offset = midpoint - start
	SUBI X11, X11, #1 // offset = midpoint - start - 1
	ADDI X12, X2, #32 // left_node = node + 4
	LSL X11, X11, #2 // offset * 4
	ADD X13, X12, X11 // right_node = node + 4 + offset * 4
	STUR X12, [X2, #16] // *(node+2) = left_node
	STUR X13, [X2, #24] // *(node+3) = right_node

	SUBI X1, X10, #2 // end = midpoint - 2 before partition call
	ADD X2, X12, XZR // node = left_node before partition call
	BL Partition
	LDUR X0, [SP, #16]	// Restore the value of registers that we backed up
	LDUR X1, [SP, #24]
	LDUR X2, [SP, #32]
	

	ADD X0, X10, XZR // start = midpoint before partition call
	ADD X2, X13, XZR // node = right_node before partition call
	BL Partition
	LDUR X0, [SP, #16]	// Restore the value of registers that we backed up
	LDUR X1, [SP, #24]
	LDUR X2, [SP, #32]
	

retpart:
	LDUR	FP, [SP, #0]	// Restore FP to what it was at the start
	LDUR	LR, [SP, #8]	// Restore LR to what it was at the start
	ADDI	SP, SP, #56	// Free up the space we took on stack by moving SP
	BR LR // end function
