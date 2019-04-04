@ Authors: Robert Rose, Alex, Mira
@ Based on work by Robert Genega, Mike Aebig, Dina Sagitova, Max Ricketts-Uy
@ At: https://github.com/MaxRickettsUy/411_ARM_PROJECT/blob/master/cos_sin_code/cordic.s


@ Register use:
@ r0 = 11    (elements in Alpha - 1)
@ r1         loop counter
@ r2         CORDIC_input, the current angle being processed
@ r3         CORDIC_COS, result
@ r4         CORDIC_SIN, result
@ r5         scratch register
@ r8         register for accessing addresses

.data

    @ Alpha lookup table.
    CORDIC_ALPHA:   .word 2949120, 1740963, 919876, 466945, 234378, 117303, 58666, 29334, 14667, 7333, 3666, 1833

    @ Number of elements in Alpha table
    CORDIC_N:       .word 11

    @ Value of the final angle returned by the CORDIC algorithm.
    CORDIC_ret:     .word 0

    @ Angle given to compute cos/sin of.
    @ Radians   @ Degrees   @ Decimal
    @ 1/4       @ 14.3239   @ 938731
    @ 0.2618    @ 15        @ 983040
    @ 1/2       @ 28.6479   @ 1877468
    @ 3/4       @ 42.9718   @ 2816199
    @ 0.7941    @ 45.5      @ 2981888
    @ 1         @ 57.2958   @ 3754937
    @ 1.1519    @ 66        @ 4325376
    @ 1.5533    @ 89.125    @ 5840896
    CORDIC_input:   .word 0x00230000

    @ Final value of cosine. We prepopulate it with a value that is shifted
    @ via the CORDIC algorithm
    CORDIC_COS:     .word 39797

    @ Final value of sine.
    CORDIC_SIN:     .word 0


.text

.global _start

_start:
    @ num elements in Alpha because ARM can't do math with constants
    mov r0, #11
    @ for loop counter ; referred to throughout as "i"
    mov r1, #0

    @ load address into address register
    ldr r8, =CORDIC_COS
    @ get value from the address. this is to prepopulate the cosine value.
    ldr r3, [r8]

    @ populate the initial sine value.
    mov r4, #0

    @ get the address of the input angle.
    ldr r8, =CORDIC_input
    @ load in the input angle.
    ldr r2, [r8]

@ Beginning of for loop to do CORDIC
for_1:
    @ i < 11
    cmp r1, r0
    @ if i < 11, we break the end of the loop, otherwise keep going into the
    @ loop body with the if statements.
    bgt exit_for

cond_1:

    @ compare current angle with zero. this is the check if the angle is positive
    @ or negative, as that determines what we need to do to it by CORDIC.
    cmp r2, #0

    @ if less than, continue to if_1, otherwise branch to the else_1
    bgt else_1

    if_1:

        @ rotations via shifiting.
        asr r5, r4, r1               @ (Y >> i)
        add r5, r3, r5               @ NEWX = X + (Y >> i)
        asr r3, r3, r1               @ (X >> i)
        sub r4, r4, r3               @ Y -= (X >> i)

        mov r3, r5                   @ X = NEWX

        @ load address of lookup table into address register
        ldr r8, =CORDIC_ALPHA
        mov r5, #2
        @ maps index to byte offset
        lsl r5, r1, r5
        @ move r8 to index of next Alpha value
        add r8, r8, r5
        @ Alpha[i].
        @ TODO: I think it may be possible to just use rregister offsetting for
        @ this, if we have time we should experiment to see if it saves any cycles
        ldr r5, [r8]

        @ CurrAngle += Alpha[i]
        add r2, r2, r5

        @@ Then skip over the else_1 section
        b skip_else_1

    else_1:

        @ rotations via shifting
        asr r5, r4, r1               @ (Y >> i)
        sub r5, r3, r5               @ NEWX = X - (Y >> i)
        asr r3, r3, r1               @ (X >> i)
        add r4, r4, r3               @ Y += (X >> i)

        mov r3, r5                   @ X = NEWX

        @ load address of lookup table into address register.
        ldr r8, =CORDIC_ALPHA
        mov r5, #2
        @ maps index to byte offset
        lsl r5, r1, r5
        @ move r8 to index of next Alpha value
        add r8, r8, r5
        @ Alpha[i].
        @ TODO: I think it may be possible to just use rregister offsetting for
        @ this, if we have time we should experiment to see if it saves any cycles
        ldr r5, [r8]

        sub r2, r2, r5               @ CurrAngle -= Alpha[i]

skip_else_1:

    @ i++
    add r1, r1, #1
    b for_1                      @ repeat loop by jumping back to the beginning

@@ When we exit the for loop all we have to do is store the results into memory.
exit_for:

    ldr r8, =CORDIC_COS          @ load address
    str r3, [r8]                 @ get val from address

    ldr r8, =CORDIC_SIN          @ load address
    str r4, [r8]                 @ get val from address

    ldr r8, =CORDIC_ret          @ load address
    str r2, [r8] @ store final angle into mem

.end