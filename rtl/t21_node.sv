module t21_node #(
    parameter int PROGRAM_SIZE = 16,
    parameter string INIT_FILE = ""
) (
    input  logic        clk,
    input  logic        rst,

    input  logic        left_rx_valid,
    input  logic signed [10:0] left_rx_data,
    output logic        left_rx_ready,
    output logic        left_tx_valid,
    output logic signed [10:0] left_tx_data,
    input  logic        left_tx_ready,

    input  logic        right_rx_valid,
    input  logic signed [10:0] right_rx_data,
    output logic        right_rx_ready,
    output logic        right_tx_valid,
    output logic signed [10:0] right_tx_data,
    input  logic        right_tx_ready,

    input  logic        up_rx_valid,
    input  logic signed [10:0] up_rx_data,
    output logic        up_rx_ready,
    output logic        up_tx_valid,
    output logic signed [10:0] up_tx_data,
    input  logic        up_tx_ready,

    input  logic        down_rx_valid,
    input  logic signed [10:0] down_rx_data,
    output logic        down_rx_ready,
    output logic        down_tx_valid,
    output logic signed [10:0] down_tx_data,
    input  logic        down_tx_ready,

    output logic [3:0]  pc_debug,
    output logic signed [10:0] acc_debug
);
    logic [3:0] pc;
    logic [23:0] instr;

    logic exec_en;
    logic latch_port_data;

    logic port_rd;
    logic port_wr;
    logic [2:0] port_sel;
    logic port_ready;

    logic signed [10:0] port_rd_data;
    logic signed [10:0] port_wr_data;

    assign pc_debug = pc;

    instr_mem #(
        .PROGRAM_SIZE(PROGRAM_SIZE),
        .INIT_FILE(INIT_FILE)
    ) u_instr_mem (
        .addr(pc),
        .instr(instr)
    );

    control_unit u_control_unit (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .port_ready(port_ready),
        .exec_en(exec_en),
        .latch_port_data(latch_port_data),
        .port_rd(port_rd),
        .port_wr(port_wr),
        .port_sel(port_sel)
    );

    datapath #(
        .PROGRAM_SIZE(PROGRAM_SIZE)
    ) u_datapath (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .exec_en(exec_en),
        .latch_port_data(latch_port_data),
        .port_rd_data(port_rd_data),
        .port_wr_data(port_wr_data),
        .pc(pc),
        .acc_out(acc_debug)
    );

    port_interface u_port_interface (
        .clk(clk),
        .rst(rst),

        .port_rd(port_rd),
        .port_wr(port_wr),
        .port_sel(port_sel),
        .port_ready(port_ready),

        .rd_data(port_rd_data),
        .wr_data(port_wr_data),

        .left_rx_valid(left_rx_valid),
        .left_rx_data(left_rx_data),
        .left_rx_ready(left_rx_ready),
        .left_tx_valid(left_tx_valid),
        .left_tx_data(left_tx_data),
        .left_tx_ready(left_tx_ready),

        .right_rx_valid(right_rx_valid),
        .right_rx_data(right_rx_data),
        .right_rx_ready(right_rx_ready),
        .right_tx_valid(right_tx_valid),
        .right_tx_data(right_tx_data),
        .right_tx_ready(right_tx_ready),

        .up_rx_valid(up_rx_valid),
        .up_rx_data(up_rx_data),
        .up_rx_ready(up_rx_ready),
        .up_tx_valid(up_tx_valid),
        .up_tx_data(up_tx_data),
        .up_tx_ready(up_tx_ready),

        .down_rx_valid(down_rx_valid),
        .down_rx_data(down_rx_data),
        .down_rx_ready(down_rx_ready),
        .down_tx_valid(down_tx_valid),
        .down_tx_data(down_tx_data),
        .down_tx_ready(down_tx_ready)
    );
endmodule
