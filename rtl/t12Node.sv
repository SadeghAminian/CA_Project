import cpu_type_pkg::*;
module t12Node #(
    parameter string FILE_NAME = "default.hex"
)(
    input  logic clk,
    input  logic rst,
    output logic [23:0] acc_out,
    output logic zero_flag,
    output logic sign_flag,

    // ==========================================
    // پورت‌های فیزیکی ۴ جهت شبکه
    // ==========================================
    input  logic signed [23:0] left_data_in, right_data_in, up_data_in, down_data_in,
    input  logic left_valid_in, right_valid_in, up_valid_in, down_valid_in,
    input  logic left_ready_in, right_ready_in, up_ready_in, down_ready_in,
    
    output logic signed [23:0] data_out,
    output logic left_ready_out, right_ready_out, up_ready_out, down_ready_out,
    output logic left_valid_out, right_valid_out, up_valid_out, down_valid_out
);

    // ==========================================
    // سیگنال‌های میانی
    // ==========================================
    logic        PCWrite, IRWrite, RegWrite, sav_en, swap_en;
    logic [1:0]  PCSrc, ALUOp;
    logic [3:0]  srcType;
    logic [11:0] up_instr;

    // سیگنال‌های ارتباطی هندشیک (بین Controller و Port_Interface)
    logic        read_done, write_done, ready_en, write_en;
    PortType     port_src, port_dst;

    // سیگنال‌های ارتباطی داده (بین Datapath و Port_Interface)
    logic signed [23:0] port_data_to_datapath;
    logic signed [23:0] port_data_from_datapath;

    // ==========================================
    // ۱. نمونه‌سازی Controller
    // ==========================================
    Controller u_Controller (
        .clk(clk),
        .rst(rst),
        .instr(up_instr),
        .zero_flag(zero_flag),
        .sign_flag(sign_flag),
        // Handshake In
        .read_done(read_done),
        .write_done(write_done),
        // Datapath Out
        .PCWrite(PCWrite),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .IRWrite(IRWrite),
        .sav_en(sav_en),
        .swap_en(swap_en),
        .ALUOp(ALUOp),
        .srcType(srcType),
        // Handshake Out
        .write_en(write_en),
        .ready_en(ready_en),
        .port_src(port_src),
        .port_dst(port_dst)
    );

    // ==========================================
    // ۲. نمونه‌سازی Datapath
    // ==========================================
    datapath #(
        .FILE_NAME(FILE_NAME)
    ) u_datapath (
        .clk(clk),
        .rst(rst),
        .RegWrite(RegWrite),
        .IRWrite(IRWrite),
        .sav_en(sav_en),
        .swap_en(swap_en),
        .PCWrite(PCWrite),
        .PCSrc(PCSrc),
        .ALUOp(ALUOp),
        .srcType(srcType),
        .zero_flag(zero_flag),
        .sign_flag(sign_flag),
        .up_instr(up_instr),
        // اتصالات داده پورت
        .port_data_in(port_data_to_datapath),
        .port_data_out(port_data_from_datapath)
    );

    // ==========================================
    // ۳. نمونه‌سازی Port Interface
    // ==========================================
    port_interface u_port_interface (
        .clk(clk),
        .rst(rst),
        // اتصالات از سمت Controller
        .port_dst(port_dst),
        .port_src(port_src),
        .ready_en(ready_en),
        .write_en(write_en),
        // اتصال از/به Datapath
        .write_data(port_data_from_datapath),
        .buffered_data_out(port_data_to_datapath),
        .read_done(read_done),
        .write_done(write_done),
        // اتصالات محیطی (تودرتو کردن با پورت‌های خود t12Node)
        .left_data_in(left_data_in), .right_data_in(right_data_in), .up_data_in(up_data_in), .down_data_in(down_data_in),
        .left_valid_in(left_valid_in), .right_valid_in(right_valid_in), .up_valid_in(up_valid_in), .down_valid_in(down_valid_in),
        .left_ready_in(left_ready_in), .right_ready_in(right_ready_in), .up_ready_in(up_ready_in), .down_ready_in(down_ready_in),
        
        .data_out(data_out),
        .left_ready_out(left_ready_out), .right_ready_out(right_ready_out), .up_ready_out(up_ready_out), .down_ready_out(down_ready_out),
        .left_valid_out(left_valid_out), .right_valid_out(right_valid_out), .up_valid_out(up_valid_out), .down_valid_out(down_valid_out)
    );

    // خروجی تست
    assign acc_out = u_datapath.acc_value;

endmodule
