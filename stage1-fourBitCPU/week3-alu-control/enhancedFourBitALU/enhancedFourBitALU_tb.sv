module fourBitALU_tb;

  reg [3:0] a, b;
  reg [2:0] opcode;
  wire [3:0] result;
  wire carry_out, zero_flag, negative_flag, positive_flag, overflow;

  fourBitALU uut(
    .result(result),
    .carry_out(carry_out),
    .zero_flag(zero_flag),
    .negative_flag(negative_flag),
    .positive_flag(positive_flag),
    .overflow(overflow),
    .a(a),
    .b(b),
    .opcode(opcode)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, fourBitALU_tb);

    $monitor("t=%0t a=%b b=%b opcode=%b result=%b carry=%b zero=%b negative=%b positive=%b overflow=%b",
             $time, a, b, opcode, result, carry_out, zero_flag, negative_flag, positive_flag, overflow);

    a = 4'b0101; b = 4'b0011; opcode = 3'b000; #10;
    a = 4'b1111; b = 4'b0001; opcode = 3'b000; #10;
    a = 4'b1100; b = 4'b1010; opcode = 3'b001; #10;
    a = 4'b0101; b = 4'b1010; opcode = 3'b001; #10;
    a = 4'b1100; b = 4'b1010; opcode = 3'b010; #10;
    a = 4'b1010; b = 4'b1010; opcode = 3'b010; #10;
    a = 4'b0101; b = 4'b0011; opcode = 3'b011; #10;
    a = 4'b0000; b = 4'b0000; opcode = 3'b011; #10;
    a = 4'b0101; b = 4'b0011; opcode = 3'b100; #10;
    a = 4'b0000; b = 4'b0000; opcode = 3'b100; #10;

    $finish;
  end

endmodule
