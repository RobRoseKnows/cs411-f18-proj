@ Authors: Robert Rose, Alex, Mira
@ Based on work by Robert Genega, Mike Aebig, Dina Sagitova, Max Ricketts-Uy
@ At: https://github.com/MaxRickettsUy/411_ARM_PROJECT/blob/master/cos_sin_code/cordic.s


@ Register use:
@

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
    CORDIC_input:   .word 2816199

    @ Final value of cosine.
    CORDIC_COS:     .word 39797

    @ Final value of sine.
    CORDIC_SIN:     .word 0


.text

.global _start



