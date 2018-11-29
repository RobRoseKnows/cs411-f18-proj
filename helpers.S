        .text
mul_wo_mul:
        push    {fp, lr}
        add     fp, sp, #4
        sub     sp, sp, #16
        str     r0, [fp, #-16]    @ float
        str     r1, [fp, #-20]
        mov     r3, #0
        str     r3, [fp, #-8]     @ float
        ldr     r3, [fp, #-20]
        str     r3, [fp, #-12]
        b       .L2
.L3:
        ldr     r1, [fp, #-16]    @ float
        ldr     r0, [fp, #-8]     @ float
        ; I don't know what this is, the compiler inserted it. I don't know if
        ; it's needed or not.
        ; bl      __aeabi_fadd
        mov     r3, r0
        str     r3, [fp, #-8]     @ float
        ldr     r3, [fp, #-12]
        sub     r3, r3, #1
        str     r3, [fp, #-12]
.L2:
        ldr     r3, [fp, #-12]
        cmp     r3, #0
        bgt     .L3
        ldr     r3, [fp, #-8]     @ float
        mov     r0, r3
        sub     sp, fp, #4
        pop     {fp, lr}
        bx      lr
main:
        push    {fp, lr}
        add     fp, sp, #4
        sub     sp, sp, #8
        mov     r1, #3
        ; Float for 1.5
        mov     r0, #1069547520
        bl      mul_wo_mul
        str     r0, [fp, #-8]     @ float
        mov     r3, #0
        mov     r0, r3
        sub     sp, fp, #4
        pop     {fp, lr}
        bx      lr