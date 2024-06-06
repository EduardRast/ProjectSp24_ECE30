LDA X0, start
LDA X1, end
LDA X2, list
LDA X3, list
LDUR X0, [X0, #0]
LDUR X1, [X1, #0]
LDUR X2, [X2, #8]
LDUR X3, [X3, #88]
BL FindMidpoint
STOP

FindMidpoint:
	SUBI	SP, SP, #64	// Allocate 32 bytes of memory (4 double words) to this function
	STUR	FP, [SP, #0]	// FP of parent is saved onto my stack SP+0
	STUR	LR, [SP, #8]	// LR should be saved to retrieve it later
	ADDI	FP, SP, #56	// FP is moved up from parent's to mine

if_mid:	ADD X4, XZR, X1 // stores tail in return register
	ADDI X9, X0, #16 // checks if head + 2 == tail and returns tail if yes
	SUBS XZR, X9, X4 // using X9 for temp storage
	B.EQ retmid
else_mid:
	STUR X0, [SP, #16]	// First, make sure we backup registers that we need and are our
	STUR X1, [SP, #24]
	STUR X2, [SP, #32]
	STUR X3, [SP, #40]
	//STUR X4, [SP, #48]
	SUBS XZR, X2, X3 // checks left_sum <= right_sum
	B.LE if2_mid
	// nested else statement
else2_mid:	
	SUBI X1, X1, #16 //tail = tail - 2
	LDUR X10, [X1, #8] // *(tail + 1)
	ADD X3, X3, X10 //right_sum = right_sum + *(tail + 1)
	B endif_mid
// nested if statement
if2_mid:
	
	ADDI X0, X0, #16 // head = head + 2
	LDUR X10, [X0, #8] // X10 has *(head + 1)
	ADD X2, X2, X10 // left_sum = left_sum + *(head + 1)
endif_mid:
	BL FindMidpoint // call FindMidpoint recursively
	LDUR X0, [SP, #16]	// Restore the value of registers that we backed up
	LDUR X1, [SP, #24]
	LDUR X2, [SP, #32]
	LDUR X3, [SP, #40]
	//LDUR X4, [SP, #48]
retmid:
	LDUR	FP, [SP, #0]	// Restore FP to what it was at the start
	LDUR	LR, [SP, #8]	// Restore LR to what it was at the start
	ADDI	SP, SP, #64	// Free up the space we took on stack by moving SP
	BR	LR		// Return to the parent call