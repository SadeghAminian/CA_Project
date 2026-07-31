module t12Node #(
    parameter string FILE_NAME = "default.hex"
)(
    input  logic clk,
    input  logic rst,
    output logic [23:0] acc_out,
    output logic        zero_flag,
    output logic        sign_flag
);

    // ==========================================
    // سیگنال‌های کنترلی بین Controller و Datapath
    // ==========================================
    logic        PCWrite;
    logic        IRWrite;
    logic        PCSrc;
    logic        RegWrite;
    logic        sav_en;
    logic        swap_en;
    logic [1:0]  ALUOp;
    logic [3:0]  srcType;
    logic [11:0] up_instr;

    // ==========================================
    // نمونه‌سازی Controller
    // ==========================================
    Controller u_Controller (
        .clk(clk),
        .rst(rst),
        .instr(up_instr),
        .PCWrite(PCWrite),
        .IRWrite(IRWrite),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .sav_en(sav_en),
        .swap_en(swap_en),
        .ALUOp(ALUOp),
        .srcType(srcType),
        .sign_flag(sign_flag),
        .zero_flag(zero_flag)
    );

    // ==========================================
    // نمونه‌سازی Datapath
    // ==========================================
    datapath #(
        .FILE_NAME(FILE_NAME)
    ) u_datapath (
        .clk(clk),
        .rst(rst),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .IRWrite(IRWrite),
        .sav_en(sav_en),
        .swap_en(swap_en),
        .PCWrite(PCWrite),
        .ALUOp(ALUOp),
        .srcType(srcType),
        .zero_flag(zero_flag),
        .sign_flag(sign_flag),
        .up_instr(up_instr)
    );

    // خروجی ACC برای مشاهده در Testbench
    assign acc_out = u_datapath.acc_value;

endmodule