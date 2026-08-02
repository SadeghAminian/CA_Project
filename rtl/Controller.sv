import cpu_type_pkg::*;
module Controller (
    input logic clk,
    input logic rst,
    input logic [11:0] instr,
    input logic zero_flag,
    input logic sign_flag,
    input  logic read_done, 
    input  logic write_done, 
    
    // خروجی‌های کنترلی به Datapath
    output logic        PCWrite,
    output logic [1:0]  PCSrc,
    output logic        RegWrite,
    output logic        IRWrite,
    output logic        sav_en,
    output logic        swap_en,
    output logic [1:0]  ALUOp,
    output logic [3:0]  srcType,

    output logic    write_en, 
    output logic    ready_en,
    output PortType port_src, 
    output PortType port_dst
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
        .read_done(read_done),
        .write_done(write_done),
        .PCUpdate(PCUpdate),
        .Branch(Branch),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .sav_en(sav_en),
        .swap_en(swap_en),
        .ALUOp(ALUOp),
        .srcType(srcType),
        .write_en(write_en),
        .ready_en(ready_en),
        .port_src(port_src),
        .port_dst(port_dst),
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