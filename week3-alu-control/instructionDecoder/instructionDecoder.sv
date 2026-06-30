module instructionDecoder(
  output [1:0] opcode, dr, sr1, sr2,
  input [7:0] instruction
);
  
  assign opcode = instruction[7:6];
  assign dr = instruction[5:4];
  assign sr1 = instruction[3:2];
  assign sr2 = instruction[1:0];
  
endmodule //instructionDecoder
