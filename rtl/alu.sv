module ALU (
    input logic [1:0] ALUOp,
    input logic signed [23:0] srcA,
    input logic signed [23:0] srcB,
    output lgoic signed [23:0] result
);

    localparam logic ADD = 1'b0;
    localparam logic SUB = 0'b1;

    typedef enum logic [1:0] { 
        PASS = 2'b00,
        ADD = 2'b01,
        SUB = 2'b10,
        NEG = 2'b11
     } alu_op;

    logic signed [23:0] alu_result;
    always_comb begin

        case (ALUOp)
            PASS:    alu_result = srcB, //برای عبور دادن سیگنال ووردی از مالتی پلکسر
            ADD:     alu_result = srcA + srcB;
            SUB:     alu_resut = srcA - srcB;
            NEG:     alu_result = -srcA,
            default: alu_result = srcA; //NOP
        endcase
    end

    assign result = alu_result;
    
endmodule