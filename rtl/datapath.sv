import cpu_type_pkg::*;
module datapath #(
    parameter string FILE_NAME = "default.hex"
)
(
    input logic clk, rst,
    input logic RegWrite,
    input logic IRWrite,
    input logic sav_en, swap_en,
    input logic PCWrite,
    input logic [1:0] PCSrc,
    input logic [1:0] ALUOp,
    input logic [3:0] srcType,

    output logic zero_flag,
    output logic sign_flag,
    output logic [11:0] up_instr,

    input  logic signed [23:0] port_data_in,  // دریافت دیتای پورت برای خواندن
    output logic signed [23:0] port_data_out  // ارسال دیتا به پورت برای نوشتن

);

    logic [3:0] pc;
    logic [3:0] pc_next;
    logic [3:0] oldPC;

    logic signed [23:0] pc_ext;

    logic signed [23:0] acc_value;
    logic signed [23:0] alu_out;

    logic [23:0] instr;
    logic [23:0] fetched_instr;
    logic signed [23:0] imm_extend;

    //==================================
    //         PC source logic 
    //==================================
     always_comb begin
        case (PCSrc)
            2'b00: pc_ext = $signed({20'd0, pc}) + 24'sd1;          // Default: PC + 1
            2'b01: pc_ext = imm_extend;                             // Other branches: Absolute IMM
            2'b10: pc_ext = $signed({20'd0, oldPC}) + acc_value;       // JRO ACC: PC + ACC
            2'b11: pc_ext = $signed({20'd0, oldPC}) + imm_extend;      // JRO IMM: PC + IMM
            default: begin
                pc_ext = $signed({20'd0, pc}) + 24'sd1; 
            end
        endcase
    end
    assign pc_next = pc_ext[3:0];

    always_ff @(posedge clk or posedge rst) begin : PC_Register
        if(rst)
            pc <= 4'b0;
        else if(PCWrite)
            pc <= pc_next;
    end

    always_ff @(posedge clk or posedge rst) begin : Old_PC_Register
        if(rst)
            oldPC <= 4'b0;
        else if(IRWrite)
            oldPC <= pc;  // ← آدرس PC قبل از +1 شدن ذخیره می‌شود
    end

    //==================================
    //         instruction memory 
    //==================================
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
            4'b11: src_mux_out = port_data_in;   // Ports (LEFT, RIGHT, UP, DOWN, ANY, LAST)
            default: src_mux_out = 24'sd0;     
        endcase
    end

    // اتصال داده‌ی منبع به پورت خروجی برای عملیات نوشتن روی همسایه
    assign port_data_out = src_mux_out;

    ALU u_ALU(
        .ALUOp(ALUOp),
        .srcA(acc_value),
        .srcB(src_mux_out),
        .result(alu_out)
    );


endmodule