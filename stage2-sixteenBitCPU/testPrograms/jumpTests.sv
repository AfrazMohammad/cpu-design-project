initial begin
    memory[16'h0000] = 16'hA014; // LI R0, #20      (R0 <= 20)
    memory[16'h0001] = 16'hB01E; // JAL #30         (PC <= 32)
    memory[16'h0002] = 16'hA201; // LI R1, #1       (R1 <= 1)
    memory[16'h0003] = 16'hB87C; // JALR R0, #-4    (PC <= 16)
    memory[16'h0004] = 16'hFC00; // HALT       

    // Second Jump
    memory[16'h0010] = 16'h0482; // ADD R2, R2, R2  (R2 <= 10)
    memory[16'h0011] = 16'hB780; // JMP R7          (PC <= 2)

    // First Jump
    memory[16'h0020] = 16'hA405; // LI R2, #5       
    memory[16'h0021] = 16'hB780; // JMP R7          (PC <= 4)

    memory[16'h0022] = 16'hFC00; // Emergency HALT
end


/*
Registers
------------------------------------------------------------
R0:0014  R1:0001  R2:000a  R3:0000
R4:0000  R5:0000  R6:0000  R7:0004
*/
