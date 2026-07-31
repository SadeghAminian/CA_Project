module Controller (
    input  logic        clk,
    input  logic        rst,
    input  logic [11:0] instr,
    input logic zero_flag,
    input logic sign_flag,
    
    // خروجی‌های کنترلی به Datapath
    output logic        PCWrite,
    output logic        PCSrc,
    output logic        RegWrite,
    output logic IRWrite,
    output logic        sav_en,
    output logic        swap_en,
    output logic [1:0]  ALUOp,
    output logic [3:0]  srcType
);

    // ==========================================
    // نمونه‌سازی از FSM
    // ==========================================
    FSM u_FSM (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .PCUpdate(PCWrite),
        .Branch(),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .sav_en(sav_en),
        .swap_en(swap_en),
        .ALUOp(ALUOp),
        .srcType(srcType),
        .IRWrite(IRWrite)
    );

endmodule