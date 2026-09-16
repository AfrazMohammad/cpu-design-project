module instructionDecoder_tb;

  wire [1:0] opcode, dr, sr1, sr2;
  reg [7:0] instruction;

  instructionDecoder uut(
    .instruction(instruction),
    .opcode(opcode),
    .dr(dr),
    .sr1(sr1),
    .sr2(sr2)
  );

  // Test sequence
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, instructionDecoder_tb);

    $monitor("t=%0t instruction=%b opcode=%b dr=%b sr1=%b sr2=%b",
             $time, instruction, opcode, dr, sr1, sr2);

    instruction = 8'b00000110; 	#10;
    instruction = 8'b01110010;	#10;
    instruction = 8'b10010011;	#10;
    instruction = 8'b11111111;	#10;

    $finish;
  end

endmodule
