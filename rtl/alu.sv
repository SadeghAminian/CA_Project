module ALU (
    input  logic [1:0] ALUOp,
    input  logic signed [23:0] srcA,
    input  logic signed [23:0] srcB,
    output logic signed [23:0] result
);

    typedef enum logic [1:0] {
        PASS = 2'b00,
        ADD  = 2'b01,
        SUB  = 2'b10,
        NEG  = 2'b11
    } alu_op;

    logic signed [23:0] alu_result;

    always_comb begin
        case (ALUOp)
            PASS:    alu_result = srcB;
            ADD:     alu_result = srcA + srcB;
            SUB:     alu_result = srcA - srcB;
            NEG:     alu_result = -srcA;
            default: alu_result = srcA;
        endcase
    end

    assign result = alu_result;

endmodule