module datapath #(
    parameter string FILE_NAME = "default.hex"
)
(
    input logic clk, rst,
    input logic RegWrite,
    input logic IRWrite,
    input logic sav_en, swap_en,
    input logic PCWrite,
    input logic PCSrc,
    input logic [1:0] ALUOp,
    input logic [3:0] srcType,

    output logic zero_flag,
    output logic sign_flag,
    output logic [11:0] up_instr

    
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
    logic [23:0] fetched_instr;
    logic signed [23:0] imm_extend;

    assign imm_extend = {{12{instr[11]}}, instr[11:0]}; // Extended immediate 
    assign up_instr = instr[23:12];  // send to contorler

    instr_mem #(
        .DATA_WIDTH(24),
        .ADDR_WIDTH(4),
        .FILE_NAME(FILE_NAME)
    ) InstrMem (
        .addr(pc),
        .instr(fetched_instr)
    );

    always_ff @(posedge clk) begin
        if(IRWrite)
            instr <= fetched_instr;
    end

    //==================================
    //        Register File 
    //==================================

    logic signed [23:0] acc_value;
    logic signed [23:0] alu_out;
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
    logic signed [23:0] src_mux_out;
    always_comb begin
        case (srcType)
            4'b00: src_mux_out = acc_value;      // ACC
            4'b01: src_mux_out = 24'sd0;             // NIL
            4'b10: src_mux_out = imm_extend;         // IMM
            default: src_mux_out = 24'sd0;     // LEFT, RIGHT, UP, DOWN, ANY, LAST هنوز تعریف نشده در رابط پورت ها
        endcase
    end

    ALU u_ALU(
        .ALUOp(ALUOp),
        .srcA(acc_value),
        .srcB(src_mux_out),
        .result(alu_out)
    );


endmodule