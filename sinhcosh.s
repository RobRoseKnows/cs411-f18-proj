@ Authors: Robert Rose, Alex Flaerty, Mira
@ Based on work by Robert Genega, Mike Aebig, Dina Sagitova, Max Ricketts-Uy
@ At: https://github.com/MaxRickettsUy/411_ARM_PROJECT/blob/master/cos_sin_code/cordic.s

   .text
   .global _start

_start:

@r0 = 11  # of elements in Alpha (-1)
@r1       Used as a loop counter
@r2       Current angle
@r3       X
@r4       Y
@r5       T
@r6  	  scratch register
@r8       Register for reading addresses.

@ e^-x
NegativeExponent:
mov r1, #0         		@ Prime loop counter

ldr r8, =ExponentInput  @ load the address
ldr r3, [r8]            @ and get the value from the address

mov r4, #1           	@ Y = 1
mov r6, #16
lsl r4, r4, r6			@ Shift left by 16 bits.

ldr r8, =NegativeExponentAlpha  @ load address

@ First for loop
for1Neg:
    cmp r1, #3					@ For loop from 0 to 3
    bgt for2Neg    				

    ldr r6, [r8]              	@ We are going to load the value from memory NegativeExponentAlpha[r1]
    sub r5, r3, r6    			@ t = x - NegativeExponentAlpha[r1]


    if1Neg:

        cmp r5, #0 				@ If t is negative we break because x can not be negative.
        blt if1ExitNeg

        mov r3, r5 				@ x = t | This is why we made sure t was not negative.
        mov r6, #1
        mov r7, #3

        sub r7, r7, r1			@ Calculate the value for our logical shifts.

        lsl r7, r6, r7
        lsr r4, r4, r7 		 	@ y <<= 2^(3 - r1) or y <<= 2^(r7)


    if1ExitNeg:

    add r1, r1, #1				@ Increment the counter.
    add r8, r8, #4				@ Must increment r8 to point to the next element of NegativeExponentAlpha

    b for1Neg						@ Back to top of loop after incrementing counter and pointer.

@ Second for loop
for2Neg:
    cmp r1, #10					@ For loop from 4 to 10
    bgt exitLoopNeg


    ldr r6, [r8]              	@ NegativeExponentAlpha[r1]

    sub r5, r3, r6    			@ t = x - NegativeExponentAlpha[r1]

    if2Neg:

        cmp r5, #0 		@ If t is negative we break because x can not be negative.
        blt if2ExitNeg

        mov r3, r5 		@ x = t

        
        sub r7, r1, #2  @ r1 - 2
        asr r7, r4, r7  @ y >> r1 - 2
        sub r4, r4, r7  @ y= y - y>> r1 - 2

    if2ExitNeg:

    add r1, r1, #1
    add r8, r8, #4

    b for2Neg

@ Third for loop
for3Neg:
cmp r1, #19		@ For loop from 11 to 19
bgt exitLoopNeg



if3Neg:
    and r6, r3, r0
    cmp r6, #0 		@ We do a bitwise and of x and 0x100 / 2^r1 and break if it is zero.
    beq if3ExitNeg

    sub r7, r1, #3  @ r1 - 3
    asr r7, r4, r7  @ y >>= r1 - 3
    add r4, r4, r7  @ y = y + y>>= r1 - 3

if3ExitNeg:

add r1, r1, #1 		@ Increment our loop control variable.
asr r0, r0, #1

b for3Neg				@ Return to top of loop.

exitLoopNeg:

    @ Store our output into memory.

    ldr r8, =NegExponentY       	
    str r4, [r8]            		@ Store final value of y (e^-x)

    ldr r8, =NegativeExponentAngle  
    str r3, [r8]            		@ Store final angle (e^-x)

    ldr r8, =NegativeExponentT      
    str r5, [r8]             		@ Store final value of T

    mov r9, r4              		@ Save Y for later in hyperbolic calculations

@ e^x
Exponent:
    mov r0, #256       			@ Counter used at the end
    mov r1, #0         			@ for loop counter

    ldr r8, =ExponentInput      @ load address
    ldr r3, [r8]            	@ get val from address

    mov r4, #1           		@ Y = 1
    mov r6, #16
    lsl r4, r4, r6				@ initializing Y to 1 in 16.16

    ldr r8, =ExponentAlpha      @ load address

@ We are going to subtract from x the biggest k in our table that we can without x going below 0.
for1:
    cmp r1, #3
        bgt for2
    
        ldr r6, [r8]        	@ ExponentAlpha[r1]

        sub r5, r3, r6    		@ t = x - ExponentAlpha[r1]

        if1:

            cmp r5, #0 			@ If t is negative we break because x can not be negative. 
            blt if1Exit		

            mov r3, r5 			@ x = t

            mov r6, #1
            mov r7, #3
            sub r7, r7, r1		
            lsl r7, r6, r7		
            lsl r4, r4, r7  	@ y <<= 2^(3 - r1)

        if1Exit:

            add r1, r1, #1		@ Increment loop counter
            add r8, r8, #4		@ move to next address in ExponentAlpha

            b for1			@ Return to start of the loop.

for2:
    cmp r1, #10					@ For from 4 to 10
    bgt for3

        ldr r6, [r8]   			@ ExponentAlpha[r1]

        sub r5, r3, r6    		@ t = x - ExponentAlpha[r1]

        if2:

            cmp r5, #0 			@ If t is negative we break because x can not be negative. 
            blt if2Exit

            mov r3, r5 			@ x = t
       
            sub r7, r1, #3  	@ r1 - 3
            asr r7, r4, r7  	@ y >>= r1 - 3
            add r4, r4, r7  	@ y = y + y >>= r1 - 3

        if2Exit:

            add r1, r1, #1
            add r8, r8, #4

            b for2

for3:
    cmp r1, #19 					@ For from 11 to 19
    bgt exit_loopx

    if3:
            and r6, r3, r0
            cmp r6, #0 				@ If a bitwise and between x and 0x100 / 2^r1 results in 0 we will break.
            beq if3Exit
       
            sub r7, r1, #3  		@ r1 - 3
            asr r7, r4, r7  		@ y >>= r1 - 3
            add r4, r4, r7  		@ y = y + y >>= r1 - 3

    if3Exit:

        add r1, r1, #1
        asr r0, r0, #1

        b for3

@ This is where all the final answers get stored into their respective .data memory locations. 
exit_loopx:

    ldr r8, =ExponentY      @ Final value of e^x
       str r4, [r8]           

       ldr r8, =ExponentAngle  @ Final value for the angle (e^x)  
       str r3, [r8]           

       ldr r8, =ExponentT   	@ Final value for the angle (e^x)  	
       str r5, [r8]          


    mov r7, #1				@ Calculate cosh(x)
    add r3, r4, r9
    asr r3, r3, r7

    ldr r8, =COSH     		@ Final value for cosh(x)
    str r3, [r8]       

    mov r7, #1				@ Calculate sinh(x)
    sub r3, r4, r9
    asr r3, r3, r7

    ldr r8, =SINH    		@ Final value for sinh(x) 
    str r3, [r8]       

   

    
.data

ExponentAlpha: .word 363410, 181705, 90852, 45423, 26573, 14624, 7719, 3973, 2017, 1016, 510
NegativeExponentAlpha:	.word 363410, 181705, 90852, 45423, 18848, 8749, 4227, 2077, 1028, 511, 255

@ Reserved storage for results in memory.
ExponentInput: .word 0x10000 		@ Input angle to use for calculating e^x, e^-x, cosh, sinh

ExponentAngle:   .word 0			@ Final value of the angle
NegativeExponentAngle:  .word 0		@ Final value of the angle (e^-x)

ExponentY:     .word 0  			@ Calculated value e^x
NegExponentY:  .word 0  			@ Calculated value e^-x

ExponentT:     .word 0				@ Final value of T   
NegativeExponentT:  .word 0  		@ Final value of T (e^-x)  

COSH:	.word 0						@ cosh(x)
SINH:	.word 0						@ sinh(x)

.end