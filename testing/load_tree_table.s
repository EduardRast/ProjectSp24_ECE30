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
        lda x5, encode          // load pointer to symbols to be encoded
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
