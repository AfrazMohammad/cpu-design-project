initial begin
    memory[16'h0000] = 16'h4025; // OR R0, R0, #5   (R0 <= 5)
    memory[16'h0001] = 16'h5266; // XOR R1, R1, #6  (R1 <= 6)
    memory[16'h0002] = 16'h4401; // OR R2, R0, R1   (R2 <= 7)
    memory[16'h0003] = 16'h5601; // XOR R3, R0, R1  (R3 <= 3)
    memory[16'h0004] = 16'h3801; // AND R4, R0, R1  (R4 <= 4)
    memory[16'h0005] = 16'h3AAB; // AND R5, R2, #11 (R5 <= 3)
    memory[16'h0006] = 16'h6480; // NOT R2, R2      (R2 <= fff8)
    memory[16'h0007] = 16'h7902; // SHL R4, R4, #2  (R4 <= 16)
    memory[16'h0008] = 16'h7C92; // SHR R6, R2, #2  (R6 <= 3ffe)
    memory[16'h0009] = 16'h7EA2; // SHRA R7, R2, #2 (R7 <= fffe)
    memory[16'h000a] = 16'h7032; // ROR R0, R0, #2  (R0 <= 4001)
    memory[16'h000b] = 16'hFC00; // HALT
end

/*
Registers
------------------------------------------------------------
R0:4001  R1:0006  R2:fff8  R3:0003
R4:0010  R5:0003  R6:3ffe  R7:fffe
*/
