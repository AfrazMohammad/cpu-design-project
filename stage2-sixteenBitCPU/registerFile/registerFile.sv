module register16bit(
    output reg [15:0] q,
    input [15:0] d,
    input clk, reset, enable
);

always @(posedge clk) begin
    if (reset)
        q <= 16'h0000;

    else if (enable)
        q <= d;
end

endmodule //register16bit




module decoder3to8(
    output [7:0] d,
    input [2:0] a
);

assign d[0] = ~a[2] & ~a[1] & ~a[0];
assign d[1] = ~a[2] & ~a[1] & a[0];
assign d[2] = ~a[2] & a[1] & ~a[0];
assign d[3] = ~a[2] & a[1] & a[0];
assign d[4] = a[2] & ~a[1] & ~a[0];
assign d[5] = a[2] & ~a[1] & a[0];
assign d[6] = a[2] & a[1] & ~a[0];
assign d[7] = a[2] & a[1] & a[0];

endmodule




module registerFile(
    output reg [15:0] read_data1, read_data2,
    input [2:0] read_address1, read_address2,

    input [2:0] write_address,
    input [15:0] write_data,
    
    input clk, reset, write_enable
);

wire [7:0] register_select;
wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

decoder3to8 rf1(
    .d(register_select),
    .a(write_address)
);

register16bit rfR0(
    .q(r0),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[0])
);

register16bit rfR1(
    .q(r1),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[1])
);

register16bit rfR2(
    .q(r2),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[2])
);

register16bit rfR3(
    .q(r3),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[3])
);

register16bit rfR4(
    .q(r4),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[4])
);

register16bit rfR5(
    .q(r5),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[5])
);

register16bit rfR6(
    .q(r6),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[6])
);

register16bit rfR7(
    .q(r7),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[7])
);

always @ (*) begin
    case (read_address1)
        3'b000 : read_data1 = r0;
        3'b001 : read_data1 = r1;
        3'b010 : read_data1 = r2;
        3'b011 : read_data1 = r3;
        3'b100 : read_data1 = r4;
        3'b101 : read_data1 = r5;
        3'b110 : read_data1 = r6;
        3'b111 : read_data1 = r7;
        default: read_data1 = 16'h0000;
    endcase

    case (read_address2)
        3'b000 : read_data2 = r0;
        3'b001 : read_data2 = r1;
        3'b010 : read_data2 = r2;
        3'b011 : read_data2 = r3;
        3'b100 : read_data2 = r4;
        3'b101 : read_data2 = r5;
        3'b110 : read_data2 = r6;
        3'b111 : read_data2 = r7;
        default: read_data2 = 16'h0000;
    endcase
end

endmodule //registerFile
