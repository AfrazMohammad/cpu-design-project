; Example Assembly Program. Edit this file to run your custom programs.
; This program clears R0 and then continuously adds 4 to R0 until R0 holds 16.

.ORIG x0000

AND R0, R0, #0
LOOP:
ADD R0, R0, #4

CMP R0, #16
BLT LOOP

HALT

.END
