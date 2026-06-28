module fourBitAdder(
  output [3:0] sum,
  output cout,
  input [3:0] a,
  input [3:0] b
);
  
  wire c1, c2, c3;
  
  halfAdder bit0(
    .sum(sum[0]),
    .cout(c1),
    .a(a[0]),
    .b(b[0])
  );
  
  fullAdder bit1(
    .sum(sum[1]),
    .cout(c2),
    .a(a[1]),
    .b(b[1]),
    .cin(c1)
  );
  
  fullAdder bit2(
    .sum(sum[2]),
    .cout(c3),
    .a(a[2]),
    .b(b[2]),
    .cin(c2)
  );
  
  fullAdder bit3(
    .sum(sum[3]),
    .cout(cout),
    .a(a[3]),
    .b(b[3]),
    .cin(c3)
  );
  
endmodule //fourBitAdder
