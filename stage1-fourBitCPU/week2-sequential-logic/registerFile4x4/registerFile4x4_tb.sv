module registerFile4x4_tb;

  reg clk;
  reg write_enable;
  reg [3:0] write_data;
  reg [1:0] write_address;
  reg [1:0] read_address1;
  reg [1:0] read_address2;

  wire [3:0] read_data1;
  wire [3:0] read_data2;

  registerFile4x4 uut(
    .read_data1(read_data1),
    .read_data2(read_data2),
    .read_address1(read_address1),
    .read_address2(read_address2),
    .write_data(write_data),
    .write_address(write_address),
    .write_enable(write_enable),
    .clk(clk)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, registerFile4x4_tb);

    $monitor("t=%0t we=%b waddr=%b wdata=%b raddr1=%b rdata1=%b raddr2=%b rdata2=%b",
             $time, write_enable, write_address, write_data,
             read_address1, read_data1, read_address2, read_data2);

    write_enable = 0; write_data = 4'b0000; write_address = 2'b00;
    read_address1 = 2'b00; read_address2 = 2'b01;
    #10;

    // Write R0 = 1010
    write_enable = 1; write_address = 2'b00; write_data = 4'b1010;
    #10;

    // Write R1 = 0011
    write_address = 2'b01; write_data = 4'b0011;
    #10;

    // Write R2 = 0101
    write_address = 2'b10; write_data = 4'b0101;
    #10;

    // Write R3 = 1111
    write_address = 2'b11; write_data = 4'b1111;
    #10;

    // Stop writing, test reads
    write_enable = 0;

    read_address1 = 2'b00; read_address2 = 2'b10;
    #10;

    read_address1 = 2'b11; read_address2 = 2'b01;
    #10;

    read_address1 = 2'b10; read_address2 = 2'b00;
    #10;

    // Attempt write while disabled; R0 should stay 1010
    write_enable = 0; write_address = 2'b00; write_data = 4'b0000;
    #10;

    read_address1 = 2'b00; read_address2 = 2'b11;
    #10;

    $finish;
  end

endmodule
