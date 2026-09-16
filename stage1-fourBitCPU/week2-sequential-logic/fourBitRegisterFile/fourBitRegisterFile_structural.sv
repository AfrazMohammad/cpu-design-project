module fourBitRegisterFile(
  output [3:0] r0, r1, r2, r3,
  input [3:0] d,
  input clk,
  input write_enable,
  input [1:0] write_address
);
  
  wire [3:0] register_select;
  
  twoToFourDecoder fbrf(
    .d(register_select),
    .a(write_address)
  );
  
  fourBitRegisterEnable register0(
    .q(r0),
    .d(d),
    .clk(clk),
    .enable((write_enable & register_select[0]))
  );
  
  fourBitRegisterEnable register1(
    .q(r1),
    .d(d),
    .clk(clk),
    .enable((write_enable & register_select[1]))
  );
  
  fourBitRegisterEnable register2(
    .q(r2),
    .d(d),
    .clk(clk),
    .enable((write_enable & register_select[2]))
  );
  
  fourBitRegisterEnable register3(
    .q(r3),
    .d(d),
    .clk(clk),
    .enable((write_enable & register_select[3]))
  );
  
endmodule //fourBitRegisterFile
