module fourBitALU_tb;

  wire [3:0] result;
  reg [3:0] a, b;
  reg [1:0] opcode;

  fourBitALU uut(
    .result(result),
    .a(a),
    .b(b),
    .opcode(opcode)
  );

  initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, fourBitALU_tb);

    $monitor(
      "t=%0t a=%b b=%b opcode=%b result=%b",
      $time, a, b, opcode, result
    );

    // Initial values
    a = 4'b0101;
    b = 4'b0011;
    opcode = 2'b00;
    #10;
    
    a = 4'b0101;
    b = 4'b0011;
    opcode = 2'b01;
    #10;
    
    a = 4'b0101;
    b = 4'b0011;
    opcode = 2'b10;
    #10;
    
    a = 4'b0101;
    b = 4'b0011;
    opcode = 2'b11;
    #10;
    
    $finish;

  end

endmodule
