initial begin
    memory[16'h0000] = 16'hD100; // CMP R0, #0
    memory[16'h0001] = 16'hEE07; // BR 0009 (+7)

    memory[16'h0002] = 16'hA40F; // LI R2, #15
    memory[16'h0003] = 16'hD401; // CMP R2, R1
    memory[16'h0004] = 16'hEDFD; // BLE 0002 (-3)
    memory[16'h0005] = 16'hE202; // BGT 0008 (+2)      

    memory[16'h0006] = 16'hA207; // LI R1, #7
    memory[16'h0007] = 16'hD001; // CMP R0, R1
    memory[16'h0008] = 16'hE603; // BGE 000c (+3)    
    memory[16'h0009] = 16'hE801; // BLT 000b (+1)    

    memory[16'h000a] = 16'hF000; // NOP

    memory[16'h000b] = 16'hEBF8; // BNE 0004 (-8)   
    memory[16'h000c] = 16'hE5F8; // BEQ 0005 (-8)  

    memory[16'h000d] = 16'hFC00; // HALT
end


/* Total executed cycles: 100
PC    = 000e
IR    = fc00
MAR   = 000d
MDR   = fc00
Flags = 001

Registers
------------------------------------------------------------
R0:0000  R1:0007  R2:000f  R3:0000
R4:0000  R5:0000  R6:0000  R7:0000
*/
