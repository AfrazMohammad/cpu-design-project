module fourBitRegisterEnable(
  output [3:0] q,
  input [3:0] d,
  input clk,
  input enable
);
  
  wire [3:0] next_d;
  
  assign next_d = enable ? d : q;
  
  fourBitRegister fbre(
    .q(q),
    .d(next_d),
    .clk(clk)
  );
  
endmodule //fourBitRegisterEnable
