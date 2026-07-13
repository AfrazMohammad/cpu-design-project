module programCounter(
    output reg [15:0] pc,
    input [15:0] next_pc,
    input clk, reset, enable
);

always @ (posedge clk) begin
    if (reset)
        pc <= 16'h0000;
    else if (enable)
        pc <= next_pc;
end

endmodule //programCounter
