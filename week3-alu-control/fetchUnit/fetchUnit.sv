module fetchUnit(
  output [7:0] instruction,
  output [3:0] pc,
  input clk, reset, enable
);
  
  programCounter fu1(
    .pc(pc),
    .clk(clk),
    .reset(reset),
    .enable(enable)
  );
  
  instructionMemory fu2(
    .instruction(instruction),
    .address(pc)
  );
  
endmodule //fetchUnit
