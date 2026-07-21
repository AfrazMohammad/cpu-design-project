initial begin
    memory[16'h0000] = 16'hA00A; // LI R0, #10      (R0 <= 10)
    memory[16'h0001] = 16'hA20F; // LI R1, #15      (R1 <= 15)
    memory[16'h0002] = 16'h8287; // ST R1, #7       (M10 <= 15)
    memory[16'h0003] = 16'h8186; // STI R0, #6      (M15 <= 10)
    memory[16'h0004] = 16'h8405; // LD R2, #5       (R2 <= 15)
    memory[16'h0005] = 16'h8704; // LDI R3, #4      (R3 <= 10)
    memory[16'h0006] = 16'h981E; // LDR R4, R0, -2  (R4 <= FC00)
    memory[16'h0007] = 16'h9925; // STR R4, R1, #5  (M20 <= FC00)
    memory[16'h0008] = 16'hFC00; // HALT
end

/*
Registers
------------------------------------------------------------
R0:000a  R1:000f  R2:000f  R3:000a
R4:fc00  R5:0000  R6:0000  R7:0000

Modified Memory Locations
------------------------------------------------------------
MEM[000a] = 000f
MEM[000f] = 000a
MEM[0014] = fc00
*/
