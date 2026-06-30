module instructionMemory_tb;

  reg [3:0] address;
  wire [7:0] instruction;

  instructionMemory uut(
    .instruction(instruction),
    .address(address)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, instructionMemory_tb);

    $monitor("t=%0t address=%b instruction=%b",
             $time, address, instruction);

    address = 4'b0000; 	#10;
    address = 4'b0001; 	#10;
    address = 4'b0010;	#10;
    address = 4'b0011;	#10;
    address = 4'b0100;	#10;
    address = 4'b0101;	#10;
    address = 4'b0110;	#10;
    address = 4'b0111;	#10;
    address = 4'b1000;	#10;
    address = 4'b1001;	#10;

    $finish;
  end

endmodule
