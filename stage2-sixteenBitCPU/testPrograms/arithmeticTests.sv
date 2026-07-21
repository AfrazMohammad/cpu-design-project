initial begin
    memory[16'h0000] = 16'hA005; // LI R0, #5       (R0 <= 5)
    memory[16'h0001] = 16'hA307; // LEA R1, #7      (R1 <= 9)
    memory[16'h0002] = 16'h04AA; // ADD R2, R2, #10 (R2 <= 10)
    memory[16'h0003] = 16'h0682; // ADD R3, R2, R2  (R3 <= 20)
    memory[16'h0004] = 16'h18A3; // SUB R4, R2, #3  (R4 <= 7)
    memory[16'h0005] = 16'h1AC4; // SUB R5, R3, R4  (R5 <= 13)
    memory[16'h0006] = 16'h2C84; // MUL R6, R2, R4  (R6 <= 70)
    memory[16'h0007] = 16'h2F66; // MUL R7, R5, #6  (R7 <= 78) 
    memory[16'h0008] = 16'hF400; // HALT
end

/*
Registers
------------------------------------------------------------
R0:0005  R1:0009  R2:000a  R3:0014
R4:0007  R5:000d  R6:0046  R7:004e
*/
