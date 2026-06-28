// Code your testbench here
// or browse Examples

module fourBitAdder_tb;

  reg [3:0] a;
  reg [3:0] b;
  wire cout;
  wire [3:0] sum;

  fourBitAdder uut (
    .a(a),
    .b(b),
    .cout(cout),
    .sum(sum)
  );
  
  initial begin
    $monitor("time=%0t a=%b b=%b sum=%b cout=%b",
             $time, a, b, sum, cout);
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, fourBitAdder_tb);

    a = 4'b0101; b = 4'b0011; // sum = 1000, cout = 0
    #10;

    a = 4'b1111; b = 4'b0001; // sum = 0000, cout = 1
    #10;

    a = 4'b0110; b = 4'b0010; // sum = 1000, cout = 0
    #10;

    a = 4'b1010; b = 4'b0101; // sum = 1111, cout = 0
    #10;

    $finish;
  end

endmodule
