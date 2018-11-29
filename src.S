.data
cordic_ctab: .word 0x4E490FDA, 0x4DED6338, 0x4D7ADBAF, 0x4CFEADD4 ,0x4C7FAADD, 0x4BFFEAAD, 0x4B7FFAAA, 0x4AFFFEAA, 0x4A7FFFA8, 0x49FFFFE8, 0x497FFFF0, 0x48FFFFE0, 0x487FFFC0, 0x47FFFF80, 0x477FFF00, 0x46FFFE00, 0x467FFC00, 0x45FFF800, 0x457FF000, 0x44FFE000, 0x447FC000, 0x43FF8000, 0x437F0000, 0x42FE0000, 0x427C0000, 0x41F80000, 0x41700000, 0x41000000, 0x40800000, 0x40000000, 0x3F800000, 0x00000000
cordic_1k: .word 0x4E1B74ED
MUL: .word 0x4E800000
MULINV: .word 0x307FFFFF
ONE: .word 0x3F800000
X: .word 0x00000000
Y: .word 0x00000000
Z: .word 0x00000000
TX: .word 0x00000000
counter: .word 0x00000000
loop_limit: .word 32
COS: .word 0x00000000               @ answers stored in ieee754
SIN: .word 0x00000000
TAN: .word 0x00000000
theta: .word 0x41F00000             @ 30 degs in ieee754 (needs to be converted to radians)
deg_convert_const: .word 0x4B8EFA2D

.text
.global main
main:
    ldr r0, =theta
    ldr r1, [r0]                    @ r1=30° in ieee754
    ldr r0, =deg_convert_const
    ldr r2, [r0]                    @ r2=(PI/180)
    bl multiply_754                 @ Find 30° in rad
    ldr r1, =Z
    str r0, [r1]                    @ Store Z value

    ldr r0, =cordic_1k
    ldr r0, [r0]
    ldr r1, =X
    str r0, [r1]                    @ Store X value

    ldr r0, =Y
    mov r1, #0x00000000
    str r1, [r0]                    @ Store Y value

loop:
    ldr r6, =Z                      @ Find D value
    ldr r5, =0x80000000             @ Break to pos if D >= 0
    ldr r4, [r6]
    and r4, r4, r5
    cmp r4, #0x00000000
    beq pos

    ldr r6, =Y                      @ Load X and Y addr
    ldr r7, =X
    ldr r0, =counter
    ldr r0, [r0]
    ldr r2, [r6]
    ldr r8, =0x007FFFFF
    ldr r9, =0x7F800000
    and r4, r9, r2                  @ Extract exponent
    and r6, r8, r2                  @ Extract fraction
    mov r5, r4, lsr #23             @ Exp -= counter
    sub r5, r5, r0
    mov r5, r5, lsl #23
    orr r1, r5, r6
    ldr r2, [r7]
    bl addfloat                     @ r0 = r1 + r2 (r0 = X + (y>>k))
    ldr r6, =TX
    str r0, [r6]                    @ Update X value

    ldr r6, =X                      @ Load X and Y addr
    ldr r7, =Y
    ldr r0, =counter
    ldr r0, [r0]
    ldr r2, [r6]
    ldr r8, =0x007FFFFF
    ldr r9, =0x7F800000
    and r4, r9, r2                  @ Extract exponent
    and r6, r8, r2                  @ Extract fraction
    mov r5, r4, lsr #23             @ Exp -= counter
    sub r5, r5, r0
    mov r5, r5, lsl #23
    orr r2, r5, r6
    ldr r1, [r7]
    bl subfloat                     @ r0 = r1 - r2 (r0 = Y - (x>>k))
    ldr r6, =Y
    str r0, [r6]                    @ Update Y value

    ldr r6, =cordic_ctab            @ Load cordic_ctab and Z addr
    ldr r3, =Z
    mov r8, #-4
    mov r9, #-1

find_offset:                        @ Find cordic_ctab[k]
    add r8, r8, #4
    add r9, r9, #1
    ldr r1, =counter
    ldr r1, [r1]
    cmp r9, r1
    blt find_offset

    ldr r1, [r3]
    ldr r2, [r6, r8]
    bl addfloat                     @ r0 = r1 + r2 (r0 = Z + cordic_ctab[k])
    ldr r3, =Z
    str r0, [r3]

    ldr r1, =loop_limit
    ldr r2, =counter
    ldr r3, [r1]
    ldr r4, [r2]
    add r4, r4, #1                  @ counter += 1

    ldr r5, =TX                     @ Update X with temporary X
    ldr r7, =X
    ldr r6, [r5]
    str r6, [r7]

    cmp r4, r3                      @ if (counter <= loop_limit)
    str r3, [r1]
    str r4, [r2]
    blt loop
    b finished

pos:
    ldr r6, =Y                      @ Load X and Y addr
    ldr r7, =X
    ldr r0, =counter
    ldr r0, [r0]
    ldr r2, [r6]
    ldr r8, =0x007FFFFF
    ldr r9, =0x7F800000
    and r4, r9, r2                  @ Extract exponent
    and r6, r8, r2                  @ Extract fraction
    mov r5, r4, lsr #23             @ Exp -= counter
    sub r5, r5, r0
    mov r5, r5, lsl #23
    orr r2, r5, r6
    ldr r1, [r7]
    bl subfloat                     @ r0 = r1 - r2 (r0 = X - (y>>k))
    ldr r6, =TX
    str r0, [r6]

    ldr r6, =X                      @ Load X and Y addr
    ldr r7, =Y
    ldr r0, =counter
    ldr r0, [r0]
    ldr r2, [r6]
    ldr r8, =0x007FFFFF
    ldr r9, =0x7F800000
    and r4, r9, r2                  @ Extract exponent
    and r6, r8, r2                  @ Extract fraction
    mov r5, r4, lsr #23             @ Exp -= counter
    sub r5, r5, r0
    mov r5, r5, lsl #23
    orr r2, r5, r6
    ldr r1, [r7]
    bl addfloat                     @ r0 = r1 + r2 (r0 = Y + (x>>k))
    ldr r6, =Y
    str r0, [r6]

    ldr r6, =cordic_ctab            @ Load cordic_ctab and Z addr
    ldr r3, =Z
    mov r8, #-4
    mov r9, #-1
find_offset_pos:                    @ Find cordic_ctab[k]
    add r8, r8, #4
    add r9, r9, #1
    ldr r1, =counter
    ldr r1, [r1]
    cmp r9, r1
    blt find_offset_pos

    ldr r1, [r3]
    ldr r2, [r6, r8]
    bl subfloat                     @ r0 = r1 - r2 (r0 = Z - cordic_ctab[k])
    ldr r3, =Z
    str r0, [r3]

    ldr r1, =loop_limit
    ldr r2, =counter
    ldr r3, [r1]
    ldr r4, [r2]
    add r4, r4, #1                  @ counter += 1

    ldr r5, =TX                     @ Update X with temporary X
    ldr r7, =X
    ldr r6, [r5]
    str r6, [r7]

    cmp r4, r3                      @ if (counter <= loop_limit)
    str r3, [r1]
    str r4, [r2]
    blt loop
    b finished

@ Multiplicands stored in r1 and r2
multiply_754:
    and r3, r1, #0x80000000         @ Extract sign
    and r4, r2, #0x80000000

    eor r0, r3, r4                  @ Find new sign
    ldr r9, =0x7F800000
    and r3, r1, r9                  @ Extract exponents
    and r4, r2, r9

    mov r3, r3, lsr #23             @ Move to other side of decimal point
    mov r4, r4, lsr #23
    sub r3, r3, #127                @ Remove the bias
    sub r4, r4, #127
    add r5, r3, r4                  @ r5 holds exponent

    ldr r9, =0x007FFFFF
    and r3, r1, r9                  @ Extract fractions
    and r4, r2, r9
    orr r3, r3, #0x00800000         @ Add implied 1
    orr r4, r4, #0x00800000
    stmfd sp!, {r3-r4, r8-r9}       @ Save r6 & r7
    mov r6, #0                      @ Zero out r6-r9
    mov r7, #0
    mov r9, #0

mul:
    ands r8, r3, #1                 @ Check for 1 in LSB
    beq no_add

    adds r7, r7, r4
    adc r6, r6, r9

no_add:


    mov r9, r9, lsl #1
    movs r4, r4, lsl #1
    adc r9, r9, #0                  @ Shift to left, move carry bit and add overflow

    movs r3, r3, lsr #1             @ Shift r3 and set flags
    bne mul                         @ Branch if r3 is not 0 yet
    ldmfd sp!, {r3-r4, r8-r9}       @ Pop r3-r4, r8-r9

creatfraction:
    ands r8, r6, #0x00008000

    addne r5, r5, #1                @ If 16th bit is a 1
    movne r6, r6, lsl #16           @ Making room
    movne r7, r7, lsr #16

    moveq r6, r6, lsl #17           @ If 16th bit is not a 1
    moveq r7, r7, lsr #15           @ Making room

    orr r6, r6, r7                  @ Merging fractions together
    mov r6, r6, lsr #8              @ Can only use 24 bits
    bic r6, r6, #0x00800000         @ Clear the 1

done_mul:
    add r5, r5, #127                @ Re-add bias to the exponent
    mov r5, r5, lsl #23             @ Put exponent into position
    orr r0, r0, r5                  @ Place exponent
    orr r0, r0, r6                  @ Place fraction
    mov pc, lr


@ r0 = r1 - r2
subfloat:
    ldr r10, =0x80000000
    eor r2, r2, r10                 @ Exclusive or r2 with 0x80000000 to toggle the sign bit
    @bl addfloat
    @mov pc, lr

@ r0 = r1 + r2
addfloat:
    ldr r10, =0x7f800000
    and r4, r1, r10                 @ use a bitmask to capture the first number's exponent
    and r5, r2, r10                 @ use a bitmask to capture the second number's exponent
    cmp r4, r5

    movcc r3, r1
    movcc r1, r2
    movcc r2, r3                    @ swap r1 with r2 if r2 has the higher exponent
    andcc r4, r1, r10
    andcc r5, r2, r10               @ update exponents if swapped

    mov r4, r4, lsr #23
    mov r5, r5, lsr #23             @ move exponents to least significant position

    sub r3, r4, r5                  @ subtract exponents to get shift amount
    ldr r10, =0x007fffff
    and r5, r1, r10                 @ grab first number's fractional part
    and r6, r2, r10                 @ grab second number's fractional part
    ldr r10, =0x00800000
    orr r5, r5, r10                 @ add implied 1 to first fractional part
    orr r6, r6, r10                 @ add implied 1 to second fractional part
    mov r6, r6, lsr r3              @ shift r6 to the right by the difference in exponents

    ldr r10, =0x80000000
    ands r0, r1, r10                @ check msb for negative bit
    movne r0, r5                    @ this "not equal" works because the "ands" will set the zero flag if the result is zero
    stmnefd sp!, {lr}
    blne twos_complement            @ two's complement fractional first number if it's supposed to be negative
    ldmnefd sp!, {lr}
    movne r5, r0

    ands r0, r2, r10                @ check msb for negative bit
    movne r0, r6
    stmnefd sp!, {lr}
    blne twos_complement            @ two's complement fractional second number if it's supposed to be negative
    ldmnefd sp!, {lr}
    movne r6, r0

    add r5, r5, r6                  @ add the fractional portions. r5 contains the result.

    ands r0, r5, r10                @ check msb to see if the result is negative
    movne r0, r5
    stmnefd sp!, {lr}
    blne twos_complement            @ two's complement result if negative
    ldmnefd sp!, {lr}
    movne r5, r0
    ldrne r0, =0x80000000           @ put a 1 as result's msb if the result was negative
    moveq r0, #0                    @ put a 0 as result's msb if the result was positive

    mov r3, #0
    ldr r10, =0x80000000

count_sigbit_loop:
    cmp r10, r5
    addhi r3, r3, #1
    movhi r10, r10, lsr #1
    bhi count_sigbit_loop           @ count how many times you have to shift before hitting a 1 in the result

    cmp r3, #8                      @ if it's shifted 8 times it's already in the right place
    subhi r3, r3, #8                @ if it needs shifting left, determine how many times
    movhi r5, r5, lsl r3            @ shift as needed
    subhi r4, r4, r3                @ subtract shift amount from exponent to reflect shift
    movcc r10, #8
    subcc r3, r10, r3               @ if it needs shifting right, determine how many times
    movcc r5, r5, lsr r3            @ shift as needed
    addcc r4, r4, r3                @ add shift amount to exponent to relfect shift

    mov r4, r4, lsl #23             @ shift exponent into place
    orr r0, r0, r4                  @ or exponent into number
    ldr r10, =0x007fffff
    and r5, r5, r10                 @ get rid of implied 1 in fraction
    orr r0, r0, r5                  @ attach fractional part

    mov pc, lr

@ r0 = -r0
twos_complement:
    mvn r0, r0                      @ negate r0
    add r0, r0, #1                  @ add 1
    mov pc, lr                      @ Return to caller

finished:
    ldr r0, =Y
    ldr r1, [r0]
    ldr r2, =MULINV
    ldr r2, [r2]
    bl multiply_754
    ldr r1, =SIN                    @ Store Sin(theta)
    str r0, [r1]

    ldr r0, =X
    ldr r1, [r0]
    ldr r2, =MULINV
    ldr r2, [r2]
    bl multiply_754
    ldr r1, =COS                    @ Store Cos(theta)
    str r0, [r1]

    ldr r0, =ONE
    ldr r1, [r0]
    ldr r2, =COS
    ldr r2, [r2]
    bl multiply_754
    mov r1, r0
    ldr r2, =SIN
    ldr r2, [r2]
    bl multiply_754
    ldr r2, =TAN                    @ Store Tan(theta) (does not work)
    str r0, [r2]
