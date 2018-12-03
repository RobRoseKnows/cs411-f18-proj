@ Authors: Robert Rose, Alex, Mira
@ This is a quick demo of the possible sqrt function using CORDIC with
@ multiplication. We didn't feel like writing the extra credit one without
@ mul was really neccessary and it simplifies the alogrithm quite a bit to
@ be able to use mul.

@ Register use:
@ r0 = 8     since ARM can't do cmp with immediates, we store it in register.
@ r1         loop counter, "i"
@ r2         CORDIC_input, the number being processed, "x"
@ r3         CORDIC_ROOT, the sqrt result of the number, "y"
@ r4         CORDIC_BASE, the base we're currently using, "base"
@ r5         scratch register
@ r8         register for accessing addresses

.data

    @ Number of times we should loop.
    CORDIC_N:       .word 8

    @ Value of the final angle returned by the CORDIC algorithm.
    CORDIC_ret:     .word 0

    @ A number between 0 and 65536
    CORDIC_input:   .word 64

    @ The starting base to use for CORDIC
    CORDIC_BASE:    .word 128


.text

.global _start

_start:
    @ num elements in Alpha because ARM can't do math with constants
    mov r0, #8
    @ for loop counter ; referred to throughout as "i"
    mov r1, #0

    @ load address into address register
    ldr r8, =CORDIC_BASE
    @ get value from the address. this is to prepopulate the cosine value.
    ldr r4, [r8]

    @ populate the initial sine value.
    mov r3, #0

    @ get the address of the input angle.
    ldr r8, =CORDIC_input
    @ load in the input angle.
    ldr r2, [r8]

@ Beginning of for loop to do CORDIC
for_1:
    @ i <= 8
    cmp r1, r0
    @ if i > 8, we break the end of the loop, otherwise keep going into the
    @ loop body with the if statements.
    bgt exit_for

cond_1:

    @ add base to y
    add r3, r4, r3

    @ multiply y by itself
    mul r5, r3, r3

    @ see if y * y exceeds x
    cmp r5, r2

    @ if greater than, continue to if_1, otherwise branch to the else_1
    ble skip_if_1

    @ this is if we go over in estimating the sqrt, we should subtract
    @ the base we just added.
    if_1:

        @ subtract the base from y because we went over
        sub r3, r4, r3

skip_if_1:

    @ i++
    asr r4, r4, #1
    add r1, r1, #1
    b for_1                      @ repeat loop by jumping back to the beginning

@@ When we exit the for loop all we have to do is store the results into memory.
exit_for:

    ldr r8, =CORDIC_ret          @ load address
    str r3, [r8]                 @ get val from address

.end