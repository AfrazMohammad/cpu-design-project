module flagsRegister(
    output reg [2:0] leg_flags,
    input [2:0] next_leg_flags,
    input clk, reset, enable
);

always @ (posedge clk) begin
    if (reset)
        leg_flags <= 3'b000;

    else if (enable)
        leg_flags <= next_leg_flags;
end

endmodule //flagsRegister




module compareUnit(
    output reg [2:0] next_leg_flags,
    input [15:0] a, b
);

always @ (*) begin
    next_leg_flags = 3'b000;

    if ($signed(a) < $signed(b))
        next_leg_flags[2] = 1'b1; //L
    else if (a == b)
        next_leg_flags[1] = 1'b1; //E
    else
        next_leg_flags[0] = 1'b1; //G
end

endmodule //compareUnit
