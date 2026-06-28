module fourBitRegister(
  output [3:0] q,
  input [3:0] d,
  input clk
);
  
  dFlipFlop bit0(
    .q(q[0]),
    .d(d[0]),
    .clk(clk)
  );
  
  dFlipFlop bit1(
    .q(q[1]),
    .d(d[1]),
    .clk(clk)
  );
  
  dFlipFlop bit2(
    .q(q[2]),
    .d(d[2]),
    .clk(clk)
  );
  
  dFlipFlop bit3(
    .q(q[3]),
    .d(d[3]),
    .clk(clk)
  );
  
endmodule //fourBitRegister
