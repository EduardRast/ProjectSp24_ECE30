//////////////////////////
//			//
// Project Submission	//
//			//
//////////////////////////

// Partner 1: Hou Dren Yuen, A17818091
// Partner 2: Eduard Shkulipa, A16758303
//////////////////////////
//			//
//	main		//
//                    	//
//////////////////////////

main:	lda x4, symbol
	add x0,xzr,x4
	bl FindTail
	addi x2, x1, #24
	stur x2, [sp, #0]
	bl Partition
	ldur x0, [sp, #0]
	lda x5, encode
	ldur x1, [x5, #0]
CheckSymbol:
	ldur x2, [x1, #0]
	subs xzr, x2, xzr
	b.ge KeepEncode
	stop

KeepEncode:
	stur x1, [sp, #0]
	bl Encode
	ldur x1, [sp, #0]
	addi x1, x1, #8
	b CheckSymbol

	

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
//   IsContain        //
//                    //
////////////////////////
IsContain:
	// input:
	// x0: address of (pointer to) the first symbol of the sub-array
	// x1: address of (pointer to) the last symbol of the sub-array
	// x2: symbol to look for

	SUBI	SP, SP, #32	// Allocate 32 bytes of memory (4 double words) to this function
	STUR	FP, [SP, #0]	// FP of parent is saved onto my stack SP+0
	STUR	LR, [SP, #8]	// LR should be saved to retrieve it later
	ADDI	FP, SP, #24	// FP is moved up from parent's to mine

	IsContainLoop: 
	subs xzr, x0, x1 // if start>end -> end while, return 0
	b.gt ICreturn0 
	ldur x10, [x0,#0] // *start
	subs xzr, x10, x2 // if start == symbol
	b.eq ICreturn1 // return 1
	addi x0,x0,#16 // start 
	b IsContainLoop
	// output:
	// x3: 1 if symbol is found, 0 otherwise
	ICreturn1: addi x3,xzr,#1 // x3 = 1
	b IsReturn
	ICreturn0: 	add x3, xzr, xzr // x3 = 0
	b IsReturn
	IsReturn:
	LDUR	FP, [SP, #0]	// Restore FP to what it was at the start
	LDUR	LR, [SP, #8]	// Restore LR to what it was at the start
	ADDI	SP, SP, #32	// Free up the space we took on stack by moving SP
	BR	LR		// Return to the parent call



////////////////////////
//                    //
//   Encode           //
//                    //
////////////////////////
Encode:	
	// input:
	// x0: the address of (pointer to) the binary tree node 
	// x2: symbols to encode

	SUBI	SP, SP, #64	// Allocate 32 bytes of memory (4 double words) to this function
	STUR	FP, [SP, #0]	// FP of parent is saved onto my stack SP+0
	STUR	LR, [SP, #8]	// LR should be saved to retrieve it later
	STUR 	X0, [SP, #16]
	ADDI	FP, SP, #56	

	ldur x5, [x0,#16] // x5 = left_node
	ldur x6, [x0,#24] // x6 = right_node

	subs xzr, x5, x6 // if left_node==right_node -> end
	b.eq Ereturn

	ldur x0, [x5,#0] // x0 = *(left_node)
	ldur x1, [x5,#8] //x1 = *(left_node+1)
	//call the IsContain, returns x3
	BL IsContain

	cbz x3, E0 //check the output from iscontain, branch if 0 
	add x3, xzr,xzr
	putint x3 //print 0

	//call encode
	add x0,xzr,x5 // x0 = left_node
	BL Encode
	b Ereturn

	E0:
	addi x3,xzr,#1
	putint x3 // print 1
	//call encode
	add x0,xzr,x6 // x0 = right_node
	BL Encode
	b Ereturn

	Ereturn: 
	LDUR	FP, [SP, #0]	// Restore FP to what it was at the start
	LDUR	LR, [SP, #8]	// Restore LR to what it was at the start
	LDUR	X0, [SP, #16]
	ADDI	SP, SP, #64	// Free up the space we took on stack by moving SP
	BR	LR		// Return to the parent call

