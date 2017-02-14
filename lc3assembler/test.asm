; Sample LC-3 Assembly File

.ORIG x3000
    ADD R0, R1, R2
    ADD R0, R1, #5

    LD R5, VARIABLE

VARIABLE .FILL #9

.END
