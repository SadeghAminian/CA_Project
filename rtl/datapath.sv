module datapath #(
    parameter FILE_NAME = "default.hex"
)
(
    input logic clk, rst,
    input logic RegWrite,
    input logic sav_en, swap_en,
    input logic PCWrite,
    input logic [1:0] ALUOp,
    input logic [3:0] srcType,

    output logic zero_flag,
    output logic sign_flag

    
);

    logic [3:0] pc;
    logic [3:0] pc_next;
    assign pc_next = pc + 1;

    always_ff @(posedge clk or posedge rst) begin : PC_Register
        if(rst)
            pc <= 4'b0;
        else if(PCWrite)
            pc <= pc_next;
    end

    //==================================
    //         instruction memory 
    //==================================
    logic [23:0] instr;
    logic [23:0] imm_extend;
    assign imm_extend = {{12{instr[11]}}, instr[11:0]};

    instr_mem #(
        .DATA_WIDTH(24),
        .ADDR_WIDTH(4),
        .FILE_NAME(FILE_NAME)
    ) InstrMem (
        .addr(pc),
        .instr(instr)
    );

    //==================================
    //        Register File 
    //==================================

    logic [23:0] acc_value;
    RegisterFile RF(
        .rst(rst),
        .clk(clk),
        .swap(swap_en),
        .sav(sav_en),
        .write_en(RegWrite),
        .write_addr(instr[19:16]),
        .acc_out(acc_value),
        .data_in(alu_out)
    );

    //فلگ ها
    assign zero_flag = (acc_value == 24'sd0);
    assign sign_flag = acc_value[23];

    //==================================
    //             ALU 
    //==================================
    logic [23:0] src_mux_out;
    always_comb begin
        case (srcType)
            4'h0: src_mux_out = acc_value;      // ACC
            4'h1: src_mux_out = 24'sd0;             // NIL
            4'h8: src_mux_out = imm_extend;         // IMM
            default: src_mux_out = 24'sd0;     // LEFT, RIGHT, UP, DOWN, ANY, LAST هنوز تعریف نشده در رابط پورت ها
        endcase
    end

    logic [23:0] alu_out;
    ALU u_ALU(
        .ALUOp(ALUOp),
        .srcA(acc_value),
        .srcB(src_mux_out),
        .result(alu_out)
    );


endmodule