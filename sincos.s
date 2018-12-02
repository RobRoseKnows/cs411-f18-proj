@ Authors: Robert Rose, Alex, Mira
@ Based on work by Robert Genega, Mike Aebig, Dina Sagitova, Max Ricketts-Uy




.data

CORDIC_ALPHA: .word 2949120, 1740963, 919876, 466945, 234378, 117303, 58666, 29334, 14667, 7333, 3666, 1833

CORDIC_N:     .word 11          @ Number of elements in Alpha table (0-11)

CORDIC_ret:   .word 0           @ value of the final angle

CORDIC_input: .word 2949120     @ angle given to compute cos/sin/tan/e^x

CORDIC_COS:   .word 39797       @ki * 1; @ final value for COSINE

CORDIC_SIN: .word 0 @ final value for SINE
