module cpu4bit(
  input clk, reset,
  input preload_enable,
  input [1:0] preload_address,
  input [3:0] preload_data
);
  
  wire [3:0] pc;
  wire [7:0] instruction;
  wire enable;
  
  wire [1:0] opcode, dr, sr1, sr2;
  wire [3:0] sr1data, sr2data, result;
  wire carry_out, zero_flag, negative_flag, positive_flag, overflow;
  
  wire rf_write_enable;
  wire [1:0] rf_write_address;
  wire [3:0] rf_write_data;
  
  assign enable = ~(instruction == 8'b11111111);
  
  assign rf_write_enable = preload_enable ? 1'b1 : enable;
  assign rf_write_address = preload_enable ? preload_address : dr;
  assign rf_write_data = preload_enable ? preload_data : result;

  fetchUnit cpu1(
    .instruction(instruction),
    .pc(pc),
    .clk(clk),
    .reset(reset),
    .enable(enable & ~preload_enable)
  );

  instructionDecoder cpu2(
    .instruction(instruction),
    .opcode(opcode),
    .dr(dr),
    .sr1(sr1),
    .sr2(sr2)
  );

  registerFile4x4 cpu3(
    .read_data1(sr1data),
    .read_data2(sr2data),

    .read_address1(sr1),
    .read_address2(sr2),

    .write_data(rf_write_data),
    .write_address(rf_write_address),
    .clk(clk),
    .write_enable(rf_write_enable)
  );

  fourBitALU cpu4(
    .result(result),
    .a(sr1data),
    .b(sr2data),
    .opcode(opcode),
    .carry_out(carry_out),
    .negative_flag(negative_flag),
    .zero_flag(zero_flag),
    .positive_flag(positive_flag),
    .overflow(overflow)
  );
  
endmodule //fourBitCPU
