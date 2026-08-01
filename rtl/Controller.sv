module Controller (
    input logic clk,
    input logic rst,
    input logic [11:0] instr,
    input logic zero_flag,
    input logic sign_flag,
    
    // خروجی‌های کنترلی به Datapath
    output logic        PCWrite,
    output logic [1:0]  PCSrc,
    output logic        RegWrite,
    output logic        IRWrite,
    output logic        sav_en,
    output logic        swap_en,
    output logic [1:0]  ALUOp,
    output logic [3:0]  srcType
);

    logic branchTaken;
    logic Branch;
    logic PCUpdate;

    // ==========================================
    //              Main FSM
    // ==========================================
    FSM Main_FSM (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .PCUpdate(PCUpdate),
        .Branch(Branch),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .sav_en(sav_en),
        .swap_en(swap_en),
        .ALUOp(ALUOp),
        .srcType(srcType),
        .IRWrite(IRWrite)
    );

    BranchDecoder Branch_Decoder(
        .opCode(instr[11:8]),
        .Z(zero_flag),
        .S(sign_flag),
        .branchTaken(branchTaken)
    );

    assign PCWrite = (PCUpdate | (Branch & branchTaken));

endmodule