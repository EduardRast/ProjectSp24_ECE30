main:   lda x4, tree            // load pointer to tree root
        ldur x0, [x4, #0]
        lda x4, symbol          // load pointer to start of symbol array
        ldur x1, [x4, #0]
        addi x2, xzr, #0        // initialize node counter
        bl getTotalNode
        lsl x2, x2, #1
        subi x2, x2, #1
        lda x4, root
        ldur x1, [x4, #0]
        lsl x1, x1, #3
        bl StoreNode
        // by this point, you have everything you need to perform encoding
        lda x4, tree            // load pointer to tree root
        ldur x0, [x4, #0]
        lda x5, Encode          // load pointer to symbols to be encoded
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

getTotalNode:
        ldur x3, [x1, #0]
        subis xzr, x3, #0
        b.lt TailFound
        addis x2, x2, #1
        addis x1, x1, #16
        b getTotalNode
        
TailFound:
        br lr

StoreNode:
        // load and store start pointer
        ldur x3, [x0, #0]
        lsl x3, x3, #3
        stur x3, [x1, #0]
        addi, x0, x0, #8
        addi, x1, x1, #8
        // load and store end pointer
        ldur x3, [x0, #0]
        lsl x3, x3, #3
        stur x3, [x1, #0]
        addi, x0, x0, #8
        addi, x1, x1, #8
        // load and store left node pointer
        ldur x3, [x0, #0]
        subis xzr, x3, #0
        b.le skipL
        lsl x3, x3, #3
skipL:  stur x3, [x1, #0]
        addi, x0, x0, #8
        addi, x1, x1, #8
        // load and store right node pointer
        ldur x3, [x0, #0]
        b.le skipR
        lsl x3, x3, #3
skipR:  stur x3, [x1, #0]
        addi, x0, x0, #8
        addi, x1, x1, #8
        subi x2, x2, #1
        subis xzr, x2, #0
        b.gt StoreNode
        br lr


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


	add x4, xzr,x0 // X4 - original node
	ldur x5, [x0,#16] // x5 = left_node
	ldur x6, [x0,#24] // x6 = right_node

	subs xzr, x5, x6 // if left_node!=right_node -> end
	b.eq Ereturn
	// prepare registers for iscontain
	// prepare variable for calling the iscontain
	STUR X0, [SP, #16]	
	STUR x1, [SP, #24]	
	STUR X2, [SP, #32]	

	addi x0,x4,#16 // x0 = left_node
	addi x1,x4,#24 //x1 = left_node+1
	//call the IsContain, returns x3
	
	BL IsContain
	LDUR X0, [SP, #16]	
	LDUR x1, [SP, #24]	
	LDUR X2, [SP, #32]	

	cbz x3, E0 //check the output from iscontain, branch is 0 
	subi x3,x3,#1 // x3 = 0
	putint x3 //print 0

	//call encode
	STUR X0, [SP, #16]	
	STUR X2, [SP, #24]	
	add x0,xzr,x5 // x0 = left_node
	BL Encode
	LDUR X0, [SP, #16]	
	LDUR X2, [SP, #24]	

	E0:
	addi x3,x3,#1 //x3 = 1
	putint x3 // print 1

	//call encode
	STUR X0, [SP, #16]	
	STUR X2, [SP, #24]	
	add x0,xzr,x6 // x0 = right_node
	BL Encode
	LDUR X0, [SP, #16]	
	LDUR X2, [SP, #24]	

	Ereturn: 
	LDUR	FP, [SP, #0]	// Restore FP to what it was at the start
	LDUR	LR, [SP, #8]	// Restore LR to what it was at the start
	ADDI	SP, SP, #56	// Free up the space we took on stack by moving SP
	BR	LR		// Return to the parent call

	