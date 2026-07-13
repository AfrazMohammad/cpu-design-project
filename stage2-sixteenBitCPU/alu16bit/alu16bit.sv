module alu16bit(
    output reg signed [15:0] result,
    output reg carry_flag, overflow_flag,

    input signed [15:0] a, b,
    input [3:0] alu_control
);

    //ALU Control Codes
    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam MUL = 4'b0010;
    localparam AND = 4'b0011;
    localparam OR = 4'b0100;
    localparam XOR = 4'b0101;
    localparam NOT = 4'b0110;
    localparam SHL = 4'b0111;
    localparam SHR = 4'b1000;
    localparam SHA = 4'b1001;
    localparam ROR = 4'b1010;

    //Internal Regs
    reg signed [31:0] product;
    reg [16:0] sum;

always @ (*) begin
    //Default Initalizations
    carry_flag = 1'b0;
    overflow_flag = 1'b0;
    sum = 17'h00000;
    product = 32'sh00000000;
    result = 16'h0000;

    case (alu_control)
        // Arithmetic Cases
        ADD : begin
            sum = {1'b0, a} + {1'b0, b};
            result = sum[15:0];
            carry_flag = sum[16];
            overflow_flag = ~(a[15] ^ b[15]) & (a[15] ^ result[15]);
        end //ADD
        SUB : begin
            result = a - b;
            carry_flag = ($unsigned(a) >= $unsigned(b));
            overflow_flag = (a[15] ^ b[15]) & (a[15] ^ result[15]);
        end //SUB
        MUL : begin
            product = a * b;
            result = product[15:0];
            overflow_flag = product[31:16] != {16{product[15]}};
        end

        // Logic Cases
        AND : result = a & b; 
        OR : result = a | b; 
        XOR : result = a ^ b; 
        NOT : result = ~a;    

        // Shift Cases
        SHL : result = a << b[3:0]; 
        SHR : result = a >> b[3:0]; 
        SHA : result = a >>> b[3:0]; 
        ROR : begin
            if (b[3:0] == 4'b0000)
                result = a;
            else
                result = (a >> b[3:0]) | (a << (16-b[3:0]));
        end
        default : result = 16'h0000;
    endcase

end
endmodule //alu16bit
