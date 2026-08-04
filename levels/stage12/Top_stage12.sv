`timescale 1ns/1ps
//=============================================================================
// Top module for TIS-100 Stage 12 (8 nodes)
// Zero-terminated sequences: OUT.I = min, OUT.A = max
// prefix = C:/Users/Bob/CA Project/hex/level11
//=============================================================================
module Top_stage12 (
    input  logic        clk,
    input  logic        rst,
    // IN.A -> N12.UP
    input  logic signed [23:0] in_a_data,
    input  logic               in_a_valid,
    output logic               in_a_ready,
    // OUT.I <- N32.DOWN
    output logic signed [23:0] out_i_data,
    output logic               out_i_valid,
    input  logic               out_i_ready,
    // OUT.A <- N33.DOWN
    output logic signed [23:0] out_a_data,
    output logic               out_a_valid,
    input  logic               out_a_ready
);

    //=================================================
    // Node's external wire
    //=================================================
    logic signed [23:0] n12_data_out, n13_data_out, n14_data_out, n21_data_out;
    logic signed [23:0] n22_data_out, n23_data_out, n32_data_out, n33_data_out;

    logic signed [23:0] n12_up_data_in, n12_down_data_in, n12_left_data_in, n12_right_data_in;
    logic n12_up_valid_in, n12_down_valid_in, n12_left_valid_in, n12_right_valid_in;
    logic n12_up_ready_in, n12_down_ready_in, n12_left_ready_in, n12_right_ready_in;
    logic n12_up_valid_out, n12_down_valid_out, n12_left_valid_out, n12_right_valid_out;
    logic n12_up_ready_out, n12_down_ready_out, n12_left_ready_out, n12_right_ready_out;

    logic signed [23:0] n13_up_data_in, n13_down_data_in, n13_left_data_in, n13_right_data_in;
    logic n13_up_valid_in, n13_down_valid_in, n13_left_valid_in, n13_right_valid_in;
    logic n13_up_ready_in, n13_down_ready_in, n13_left_ready_in, n13_right_ready_in;
    logic n13_up_valid_out, n13_down_valid_out, n13_left_valid_out, n13_right_valid_out;
    logic n13_up_ready_out, n13_down_ready_out, n13_left_ready_out, n13_right_ready_out;

    logic signed [23:0] n14_up_data_in, n14_down_data_in, n14_left_data_in, n14_right_data_in;
    logic n14_up_valid_in, n14_down_valid_in, n14_left_valid_in, n14_right_valid_in;
    logic n14_up_ready_in, n14_down_ready_in, n14_left_ready_in, n14_right_ready_in;
    logic n14_up_valid_out, n14_down_valid_out, n14_left_valid_out, n14_right_valid_out;
    logic n14_up_ready_out, n14_down_ready_out, n14_left_ready_out, n14_right_ready_out;

    logic signed [23:0] n21_up_data_in, n21_down_data_in, n21_left_data_in, n21_right_data_in;
    logic n21_up_valid_in, n21_down_valid_in, n21_left_valid_in, n21_right_valid_in;
    logic n21_up_ready_in, n21_down_ready_in, n21_left_ready_in, n21_right_ready_in;
    logic n21_up_valid_out, n21_down_valid_out, n21_left_valid_out, n21_right_valid_out;
    logic n21_up_ready_out, n21_down_ready_out, n21_left_ready_out, n21_right_ready_out;

    logic signed [23:0] n22_up_data_in, n22_down_data_in, n22_left_data_in, n22_right_data_in;
    logic n22_up_valid_in, n22_down_valid_in, n22_left_valid_in, n22_right_valid_in;
    logic n22_up_ready_in, n22_down_ready_in, n22_left_ready_in, n22_right_ready_in;
    logic n22_up_valid_out, n22_down_valid_out, n22_left_valid_out, n22_right_valid_out;
    logic n22_up_ready_out, n22_down_ready_out, n22_left_ready_out, n22_right_ready_out;

    logic signed [23:0] n23_up_data_in, n23_down_data_in, n23_left_data_in, n23_right_data_in;
    logic n23_up_valid_in, n23_down_valid_in, n23_left_valid_in, n23_right_valid_in;
    logic n23_up_ready_in, n23_down_ready_in, n23_left_ready_in, n23_right_ready_in;
    logic n23_up_valid_out, n23_down_valid_out, n23_left_valid_out, n23_right_valid_out;
    logic n23_up_ready_out, n23_down_ready_out, n23_left_ready_out, n23_right_ready_out;

    logic signed [23:0] n32_up_data_in, n32_down_data_in, n32_left_data_in, n32_right_data_in;
    logic n32_up_valid_in, n32_down_valid_in, n32_left_valid_in, n32_right_valid_in;
    logic n32_up_ready_in, n32_down_ready_in, n32_left_ready_in, n32_right_ready_in;
    logic n32_up_valid_out, n32_down_valid_out, n32_left_valid_out, n32_right_valid_out;
    logic n32_up_ready_out, n32_down_ready_out, n32_left_ready_out, n32_right_ready_out;

    logic signed [23:0] n33_up_data_in, n33_down_data_in, n33_left_data_in, n33_right_data_in;
    logic n33_up_valid_in, n33_down_valid_in, n33_left_valid_in, n33_right_valid_in;
    logic n33_up_ready_in, n33_down_ready_in, n33_left_ready_in, n33_right_ready_in;
    logic n33_up_valid_out, n33_down_valid_out, n33_left_valid_out, n33_right_valid_out;
    logic n33_up_ready_out, n33_down_ready_out, n33_left_ready_out, n33_right_ready_out;

    //=================================================
    // Instance
    //=================================================
    t12Node #(.FILE_NAME("prefix/node12.hex")) u_N12 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n12_data_out),
        .up_data_in(n12_up_data_in), .up_valid_in(n12_up_valid_in), .up_ready_in(n12_up_ready_in),
        .up_valid_out(n12_up_valid_out), .up_ready_out(n12_up_ready_out),
        .down_data_in(n12_down_data_in), .down_valid_in(n12_down_valid_in), .down_ready_in(n12_down_ready_in),
        .down_valid_out(n12_down_valid_out), .down_ready_out(n12_down_ready_out),
        .left_data_in(n12_left_data_in), .left_valid_in(n12_left_valid_in), .left_ready_in(n12_left_ready_in),
        .left_valid_out(n12_left_valid_out), .left_ready_out(n12_left_ready_out),
        .right_data_in(n12_right_data_in), .right_valid_in(n12_right_valid_in), .right_ready_in(n12_right_ready_in),
        .right_valid_out(n12_right_valid_out), .right_ready_out(n12_right_ready_out)
    );

    t12Node #(.FILE_NAME("prefix/node13.hex")) u_N13 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n13_data_out),
        .up_data_in(n13_up_data_in), .up_valid_in(n13_up_valid_in), .up_ready_in(n13_up_ready_in),
        .up_valid_out(n13_up_valid_out), .up_ready_out(n13_up_ready_out),
        .down_data_in(n13_down_data_in), .down_valid_in(n13_down_valid_in), .down_ready_in(n13_down_ready_in),
        .down_valid_out(n13_down_valid_out), .down_ready_out(n13_down_ready_out),
        .left_data_in(n13_left_data_in), .left_valid_in(n13_left_valid_in), .left_ready_in(n13_left_ready_in),
        .left_valid_out(n13_left_valid_out), .left_ready_out(n13_left_ready_out),
        .right_data_in(n13_right_data_in), .right_valid_in(n13_right_valid_in), .right_ready_in(n13_right_ready_in),
        .right_valid_out(n13_right_valid_out), .right_ready_out(n13_right_ready_out)
    );

    t12Node #(.FILE_NAME("prefix/node14.hex")) u_N14 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n14_data_out),
        .up_data_in(n14_up_data_in), .up_valid_in(n14_up_valid_in), .up_ready_in(n14_up_ready_in),
        .up_valid_out(n14_up_valid_out), .up_ready_out(n14_up_ready_out),
        .down_data_in(n14_down_data_in), .down_valid_in(n14_down_valid_in), .down_ready_in(n14_down_ready_in),
        .down_valid_out(n14_down_valid_out), .down_ready_out(n14_down_ready_out),
        .left_data_in(n14_left_data_in), .left_valid_in(n14_left_valid_in), .left_ready_in(n14_left_ready_in),
        .left_valid_out(n14_left_valid_out), .left_ready_out(n14_left_ready_out),
        .right_data_in(n14_right_data_in), .right_valid_in(n14_right_valid_in), .right_ready_in(n14_right_ready_in),
        .right_valid_out(n14_right_valid_out), .right_ready_out(n14_right_ready_out)
    );

    t12Node #(.FILE_NAME("prefix/node21.hex")) u_N21 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n21_data_out),
        .up_data_in(n21_up_data_in), .up_valid_in(n21_up_valid_in), .up_ready_in(n21_up_ready_in),
        .up_valid_out(n21_up_valid_out), .up_ready_out(n21_up_ready_out),
        .down_data_in(n21_down_data_in), .down_valid_in(n21_down_valid_in), .down_ready_in(n21_down_ready_in),
        .down_valid_out(n21_down_valid_out), .down_ready_out(n21_down_ready_out),
        .left_data_in(n21_left_data_in), .left_valid_in(n21_left_valid_in), .left_ready_in(n21_left_ready_in),
        .left_valid_out(n21_left_valid_out), .left_ready_out(n21_left_ready_out),
        .right_data_in(n21_right_data_in), .right_valid_in(n21_right_valid_in), .right_ready_in(n21_right_ready_in),
        .right_valid_out(n21_right_valid_out), .right_ready_out(n21_right_ready_out)
    );

    t12Node #(.FILE_NAME("prefix/node22.hex")) u_N22 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n22_data_out),
        .up_data_in(n22_up_data_in), .up_valid_in(n22_up_valid_in), .up_ready_in(n22_up_ready_in),
        .up_valid_out(n22_up_valid_out), .up_ready_out(n22_up_ready_out),
        .down_data_in(n22_down_data_in), .down_valid_in(n22_down_valid_in), .down_ready_in(n22_down_ready_in),
        .down_valid_out(n22_down_valid_out), .down_ready_out(n22_down_ready_out),
        .left_data_in(n22_left_data_in), .left_valid_in(n22_left_valid_in), .left_ready_in(n22_left_ready_in),
        .left_valid_out(n22_left_valid_out), .left_ready_out(n22_left_ready_out),
        .right_data_in(n22_right_data_in), .right_valid_in(n22_right_valid_in), .right_ready_in(n22_right_ready_in),
        .right_valid_out(n22_right_valid_out), .right_ready_out(n22_right_ready_out)
    );

    t12Node #(.FILE_NAME("prefix/node23.hex")) u_N23 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n23_data_out),
        .up_data_in(n23_up_data_in), .up_valid_in(n23_up_valid_in), .up_ready_in(n23_up_ready_in),
        .up_valid_out(n23_up_valid_out), .up_ready_out(n23_up_ready_out),
        .down_data_in(n23_down_data_in), .down_valid_in(n23_down_valid_in), .down_ready_in(n23_down_ready_in),
        .down_valid_out(n23_down_valid_out), .down_ready_out(n23_down_ready_out),
        .left_data_in(n23_left_data_in), .left_valid_in(n23_left_valid_in), .left_ready_in(n23_left_ready_in),
        .left_valid_out(n23_left_valid_out), .left_ready_out(n23_left_ready_out),
        .right_data_in(n23_right_data_in), .right_valid_in(n23_right_valid_in), .right_ready_in(n23_right_ready_in),
        .right_valid_out(n23_right_valid_out), .right_ready_out(n23_right_ready_out)
    );

    t12Node #(.FILE_NAME("prefix/node32.hex")) u_N32 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n32_data_out),
        .up_data_in(n32_up_data_in), .up_valid_in(n32_up_valid_in), .up_ready_in(n32_up_ready_in),
        .up_valid_out(n32_up_valid_out), .up_ready_out(n32_up_ready_out),
        .down_data_in(n32_down_data_in), .down_valid_in(n32_down_valid_in), .down_ready_in(n32_down_ready_in),
        .down_valid_out(n32_down_valid_out), .down_ready_out(n32_down_ready_out),
        .left_data_in(n32_left_data_in), .left_valid_in(n32_left_valid_in), .left_ready_in(n32_left_ready_in),
        .left_valid_out(n32_left_valid_out), .left_ready_out(n32_left_ready_out),
        .right_data_in(n32_right_data_in), .right_valid_in(n32_right_valid_in), .right_ready_in(n32_right_ready_in),
        .right_valid_out(n32_right_valid_out), .right_ready_out(n32_right_ready_out)
    );

    t12Node #(.FILE_NAME("prefix/node33.hex")) u_N33 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n33_data_out),
        .up_data_in(n33_up_data_in), .up_valid_in(n33_up_valid_in), .up_ready_in(n33_up_ready_in),
        .up_valid_out(n33_up_valid_out), .up_ready_out(n33_up_ready_out),
        .down_data_in(n33_down_data_in), .down_valid_in(n33_down_valid_in), .down_ready_in(n33_down_ready_in),
        .down_valid_out(n33_down_valid_out), .down_ready_out(n33_down_ready_out),
        .left_data_in(n33_left_data_in), .left_valid_in(n33_left_valid_in), .left_ready_in(n33_left_ready_in),
        .left_valid_out(n33_left_valid_out), .left_ready_out(n33_left_ready_out),
        .right_data_in(n33_right_data_in), .right_valid_in(n33_right_valid_in), .right_ready_in(n33_right_ready_in),
        .right_valid_out(n33_right_valid_out), .right_ready_out(n33_right_ready_out)
    );

    //=================================================
    // Topology
    //=================================================
    // N12.RIGHT <-> N13.LEFT
    assign n13_left_data_in   = n12_data_out;
    assign n13_left_valid_in  = n12_right_valid_out;
    assign n12_right_ready_in = n13_left_ready_out;
    assign n12_right_data_in  = n13_data_out;
    assign n12_right_valid_in = n13_left_valid_out;
    assign n13_left_ready_in  = n12_right_ready_out;

    // N12.DOWN <-> N22.UP
    assign n22_up_data_in   = n12_data_out;
    assign n22_up_valid_in  = n12_down_valid_out;
    assign n12_down_ready_in = n22_up_ready_out;
    assign n12_down_data_in  = n22_data_out;
    assign n12_down_valid_in = n22_up_valid_out;
    assign n22_up_ready_in   = n12_down_ready_out;

    // N13.RIGHT <-> N14.LEFT
    assign n14_left_data_in   = n13_data_out;
    assign n14_left_valid_in  = n13_right_valid_out;
    assign n13_right_ready_in = n14_left_ready_out;
    assign n13_right_data_in  = n14_data_out;
    assign n13_right_valid_in = n14_left_valid_out;
    assign n14_left_ready_in  = n13_right_ready_out;

    // N13.DOWN <-> N23.UP
    assign n23_up_data_in   = n13_data_out;
    assign n23_up_valid_in  = n13_down_valid_out;
    assign n13_down_ready_in = n23_up_ready_out;
    assign n13_down_data_in  = n23_data_out;
    assign n13_down_valid_in = n23_up_valid_out;
    assign n23_up_ready_in   = n13_down_ready_out;

    // N21.RIGHT <-> N22.LEFT
    assign n22_left_data_in   = n21_data_out;
    assign n22_left_valid_in  = n21_right_valid_out;
    assign n21_right_ready_in = n22_left_ready_out;
    assign n21_right_data_in  = n22_data_out;
    assign n21_right_valid_in = n22_left_valid_out;
    assign n22_left_ready_in  = n21_right_ready_out;

    // N22.RIGHT <-> N23.LEFT
    assign n23_left_data_in   = n22_data_out;
    assign n23_left_valid_in  = n22_right_valid_out;
    assign n22_right_ready_in = n23_left_ready_out;
    assign n22_right_data_in  = n23_data_out;
    assign n22_right_valid_in = n23_left_valid_out;
    assign n23_left_ready_in  = n22_right_ready_out;

    // N22.DOWN <-> N32.UP
    assign n32_up_data_in   = n22_data_out;
    assign n32_up_valid_in  = n22_down_valid_out;
    assign n22_down_ready_in = n32_up_ready_out;
    assign n22_down_data_in  = n32_data_out;
    assign n22_down_valid_in = n32_up_valid_out;
    assign n32_up_ready_in   = n22_down_ready_out;

    // N23.DOWN <-> N33.UP
    assign n33_up_data_in   = n23_data_out;
    assign n33_up_valid_in  = n23_down_valid_out;
    assign n23_down_ready_in = n33_up_ready_out;
    assign n23_down_data_in  = n33_data_out;
    assign n23_down_valid_in = n33_up_valid_out;
    assign n33_up_ready_in   = n23_down_ready_out;

    // N32.RIGHT <-> N33.LEFT
    assign n33_left_data_in   = n32_data_out;
    assign n33_left_valid_in  = n32_right_valid_out;
    assign n32_right_ready_in = n33_left_ready_out;
    assign n32_right_data_in  = n33_data_out;
    assign n32_right_valid_in = n33_left_valid_out;
    assign n33_left_ready_in  = n32_right_ready_out;

    //=================================================
    // Main input/output data stream
    //=================================================
    // IN.A -> N12.UP
    assign n12_up_data_in  = in_a_data;
    assign n12_up_valid_in = in_a_valid;
    assign in_a_ready      = n12_up_ready_out;
    assign n12_up_ready_in = 1'b0;

    // N32.DOWN -> OUT.I
    assign out_i_data        = n32_data_out;
    assign out_i_valid       = n32_down_valid_out;
    assign n32_down_ready_in = out_i_ready;
    assign n32_down_data_in  = 24'sd0;
    assign n32_down_valid_in = 1'b0;

    // N33.DOWN -> OUT.A
    assign out_a_data        = n33_data_out;
    assign out_a_valid       = n33_down_valid_out;
    assign n33_down_ready_in = out_a_ready;
    assign n33_down_data_in  = 24'sd0;
    assign n33_down_valid_in = 1'b0;

    //=================================================
    // Hardwire
    //=================================================
    assign n12_left_data_in  = 24'sd0; assign n12_left_valid_in  = 1'b0; assign n12_left_ready_in  = 1'b1;
    assign n14_right_data_in = 24'sd0; assign n14_right_valid_in = 1'b0; assign n14_right_ready_in = 1'b1;
    assign n14_down_data_in  = 24'sd0; assign n14_down_valid_in  = 1'b0; assign n14_down_ready_in  = 1'b1;
    assign n21_up_data_in    = 24'sd0; assign n21_up_valid_in    = 1'b0; assign n21_up_ready_in    = 1'b1;
    assign n21_down_data_in  = 24'sd0; assign n21_down_valid_in  = 1'b0; assign n21_down_ready_in  = 1'b1;
    assign n21_left_data_in  = 24'sd0; assign n21_left_valid_in  = 1'b0; assign n21_left_ready_in  = 1'b1;
    assign n32_left_data_in  = 24'sd0; assign n32_left_valid_in  = 1'b0; assign n32_left_ready_in  = 1'b1;
    assign n33_right_data_in = 24'sd0; assign n33_right_valid_in = 1'b0; assign n33_right_ready_in = 1'b1;

endmodule