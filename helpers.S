        .text
mul_wo_mul:
        push    {fp, lr}
        add     fp, sp, #4
        sub     sp, sp, #16
        // Float to add.
        str     r0, [fp, #-16]    @ float
        // Number of times to add it, stored to memory.
        str     r1, [fp, #-20]
        // Initialize current result to be 0.
        mov     r3, #0
        // Store current result in memory
        str     r3, [fp, #-8]     @ float
        // Load number of times to add it to memory.
        ldr     r3, [fp, #-20]
        str     r3, [fp, #-12]
        // Go to the beginning of the loop.
        b       .L2
.L3:
        // for loop internal.
        // Get the number to add
        ldr     r1, [fp, #-16]    @ float
        // Get the current result
        ldr     r0, [fp, #-8]     @ float
        // This is a float add subroutine or something like that. Originally this was
        // just an add command but it got replaced with this when I changed t
        bl      __aeabi_fadd
        mov     r3, r0
        str     r3, [fp, #-8]     @ float
        ldr     r3, [fp, #-12]
        // i--
        sub     r3, r3, #1
        str     r3, [fp, #-12]
.L2:
        // for loop control logic
        ldr     r3, [fp, #-12]
        cmp     r3, #0
        // i > 0, continue loop.
        bgt     .L3
        ldr     r3, [fp, #-8]     @ float
        mov     r0, r3
        sub     sp, fp, #4
        // Pop out the frame pointer and instruction pointer.
        pop     {fp, lr}
        // Branch back to the point we were when we bl'd.
        bx      lr
main:
        push    {fp, lr}
        add     fp, sp, #4
        sub     sp, sp, #8
        mov     r1, #3
        // Float for 1.5
        mov     r0, #1069547520
        // We expect 1083179008 (0x40900000) as a result.
        bl      mul_wo_mul
        str     r0, [fp, #-8]     @ float
        mov     r3, #0
        mov     r0, r3
        sub     sp, fp, #4
        pop     {fp, lr}
        bx      lr