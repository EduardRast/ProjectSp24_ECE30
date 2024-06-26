



///////////////////////
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


	addi x3, xzr, #1 // x3 = 1
	IsContainLoop: 
	subs xzr, x0, x1 // if start>end -> end while, return 0
	b.gt ICReturn0 
	ldur x10, [x0,#0] // *start
	subs xzr, x10, x2 // if start ==symbol
	b.eq ICretirn1 // return 1
	addi x0,x0,#16 // start 
	b IsContainLoop

	// output:
	// x3: 1 if symbol is found, 0 otherwise
	ICreturn0: add x3,xzr,xzr // x3 = 0
	ICretirn1: 
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
	ADDI	FP, SP, #56	

	// save the original values
	addi x20, xzr, x0 // x20 = node
	addi x22, xzr, x2 // x22 = symbol

	ldur x5, [x0,16] // x3 = left_node
	ldur x6, [x0,24] // x4 = right_node


	subs xzr, x5, x6 // if left_node!=right_node -> end
	b.eq Ereturn
	// prepare registers for iscontain
	ldur x0,[x5,#0] // x0 = left_node
	ldur x1,[x5,#8] //x1 = left_node+1
	//call the IsContain, returns x3

	cbz x3, E0 //check the output from iscontain, branch is 0 
	subi x3,x3,#1 // x3 = 0
	putint x3 //print 0

	//call encode
	

	E0:
	addi x3,x3,#1 //x3 = 1
	putint x3 // print 1

	//call encode

	Ereturn: 
	LDUR	FP, [SP, #0]	// Restore FP to what it was at the start
	LDUR	LR, [SP, #8]	// Restore LR to what it was at the start
	ADDI	SP, SP, #56	// Free up the space we took on stack by moving SP
	BR	LR		// Return to the parent call
