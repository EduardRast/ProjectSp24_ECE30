lda x4, symbol
add x0,xzr,x4
bl FindTail
ldur x16, [x1,#0]
addi x2, x1, #24
stur x2, [sp, #0]
bl Partition

STOP

////////////////////////
//                    //
//   Partition        //
//                    //
////////////////////////
Partition:
	SUBI	SP, SP, #72	// Allocate 64 bytes of memory (4 double words) to this function
	STUR	FP, [SP, #0]	// FP of parent is saved onto my stack SP+0
	STUR	LR, [SP, #8]	// LR should be saved to retrieve it later
	ADDI	FP, SP, #64	// FP is moved up from parent's to mine


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

	LDUR X2, [X0, #8] // left_sum = *(start + 1)
	LDUR X3, [X1, #8] // right_sum = *(end + 1)

	BL FindMidpoint
	LDUR X0, [SP, #16]	// Restore the value of registers that we backed up
	LDUR X1, [SP, #24]
	LDUR X2, [SP, #32]

	ADD X10, X4, XZR // storing midpoint in X10
	
	SUB X11, X10, X0 // offset = midpoint - start
	SUBI X11, X11, #8 // offset = midpoint - start - 1
	ADDI X12, X2, #32 // left_node = node + 4
	LSL X11, X11, #2 // offset * 4
	ADD X13, X12, X11 // right_node = node + 4 + offset * 4
	STUR X12, [X2, #16] // *(node+2) = left_node
	STUR X13, [X2, #24] // *(node+3) = right_node

	ADD X14, xzr, x1 // store end

	SUBI X1, X10, #16 // end = midpoint - 2 before partition call
	ADD X2, X12, XZR // node = left_node before partition call


	STUR X4, [SP, #16] // store midpoint
	STUR X14, [SP, #24] // store end
	STUR X13, [SP, #32] // store right_node
	BL Partition
	LDUR X4, [SP, #16] // restore midpoint
	LDUR X14, [SP, #24] // restore end
	LDUR X13, [SP, #32] // restore right_node

	ADD X0, xzr, X4
	ADD x1, xzr,X14
	ADD x2, xzr, x13
	BL Partition	

retpart:
	LDUR	FP, [SP, #0]	// Restore FP to what it was at the start
	LDUR	LR, [SP, #8]	// Restore LR to what it was at the start
	ADDI	SP, SP, #72	// Free up the space we took on stack by moving SP
	BR LR // end function


////////////////////////
//                    //
//   FindTail         //
//                    //
////////////////////////
FindTail:
SUBI SP, SP, #64
STUR FP, [SP, #0]
STUR LR, [SP, #8]
STUR X0, [SP, #16]
ADDI FP, SP, #56


LDUR X9, [X0, #16] // *(pt + 2)
ADDIS X10,X9,#1
cbz X10, if_tail
else_tail:

ADDI X0, X0, #16 // pt = pt + 2
BL FindTail
B rettail


if_tail:
ADD X1, XZR, X0


rettail:

LDUR FP, [SP, #0]
LDUR LR, [SP, #8]
LDUR X0, [SP, #16]
ADDI SP, SP, #64
BR LR

////////////////////////
//                    //
//   FindMidpoint     //
//                    //
////////////////////////
FindMidpoint:
	SUBI	SP, SP, #64	// Allocate 32 bytes of memory (4 double words) to this function
	STUR	FP, [SP, #0]	// FP of parent is saved onto my stack SP+0
	STUR	LR, [SP, #8]	// LR should be saved to retrieve it later
	STUR X0, [SP, #16]	// First, make sure we backup registers that we need and are our
	STUR X1, [SP, #24]
	STUR X2, [SP, #32]
	STUR X3, [SP, #40]
	ADDI	FP, SP, #56	// FP is moved up from parent's to mine

if_mid:	ADD X4, XZR, X1 // stores tail in return register
	ADDI X9, X0, #16 // checks if head + 2 == tail and returns tail if yes
	SUBS XZR, X9, X4 // using X9 for temp storage
	B.EQ retmid
else_mid:
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
	
retmid:
	LDUR	FP, [SP, #0]	// Restore FP to what it was at the start
	LDUR	LR, [SP, #8]	// Restore LR to what it was at the start
	LDUR X0, [SP, #16]	// Restore the value of registers that we backed up
	LDUR X1, [SP, #24]
	LDUR X2, [SP, #32]
	LDUR X3, [SP, #40] 
	ADDI	SP, SP, #64	// Free up the space we took on stack by moving SP
	BR	LR		// Return to the parent call

