module programCounter(
  output [3:0] pc,
  input clk, reset, enable
);
  
  wire [3:0] pcIncrement, nextPC;
  
  fourBitAdder pc1(
    .sum(pcIncrement),
    .a(pc),
    .b(4'b0001),
    .cin(1'b0)
  );
  
  assign nextPC = (reset) ? 4'b0000 : pcIncrement;
  
  fourBitRegisterEnable pc2(
    .q(pc),
    .d(nextPC),
    .clk(clk),
    .enable(enable | reset)
  );
  
endmodule //programCounter
