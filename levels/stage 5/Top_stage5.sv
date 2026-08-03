`timescale 1ns/1ps
//=============================================================================
// Top module for TIS-100 Stage 5 (7 nodes)
// OUT = A (S=-1) | B (S=1) | A+B (S=0)
//=============================================================================
module Top_stage5 (
    input  logic        clk,
    input  logic        rst,
    // IN.A -> N12.UP
    input  logic signed [23:0] in_a_data,
    input  logic               in_a_valid,
    output logic               in_a_ready,
    // IN.S -> N13.UP
    input  logic signed [23:0] in_s_data,
    input  logic               in_s_valid,
    output logic               in_s_ready,
    // IN.B -> N14.UP
    input  logic signed [23:0] in_b_data,
    input  logic               in_b_valid,
    output logic               in_b_ready,
    // OUT <- N33.DOWN
    output logic signed [23:0] out_data,
    output logic               out_valid,
    input  logic               out_ready
);

    //=================================================
    // Node's external wire
    //=================================================
    logic signed [23:0] n12_data_out, n13_data_out, n14_data_out, n22_data_out, n23_data_out, n24_data_out, n33_data_out;

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

    logic signed [23:0] n24_up_data_in, n24_down_data_in, n24_left_data_in, n24_right_data_in;
    logic n24_up_valid_in, n24_down_valid_in, n24_left_valid_in, n24_right_valid_in;
    logic n24_up_ready_in, n24_down_ready_in, n24_left_ready_in, n24_right_ready_in;
    logic n24_up_valid_out, n24_down_valid_out, n24_left_valid_out, n24_right_valid_out;
    logic n24_up_ready_out, n24_down_ready_out, n24_left_ready_out, n24_right_ready_out;

    logic signed [23:0] n33_up_data_in, n33_down_data_in, n33_left_data_in, n33_right_data_in;
    logic n33_up_valid_in, n33_down_valid_in, n33_left_valid_in, n33_right_valid_in;
    logic n33_up_ready_in, n33_down_ready_in, n33_left_ready_in, n33_right_ready_in;
    logic n33_up_valid_out, n33_down_valid_out, n33_left_valid_out, n33_right_valid_out;
    logic n33_up_ready_out, n33_down_ready_out, n33_left_ready_out, n33_right_ready_out;

    //=================================================
    // Instances 
    //=================================================
    // ! Repalce <prefix> whit correct address
    t12Node #(.FILE_NAME("prefix/hex/level5/node12.hex")) u_N12 (
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

    t12Node #(.FILE_NAME("prefix/hex/level5/node13.hex")) u_N13 (
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

    t12Node #(.FILE_NAME("prefix/hex/level5/node14.hex")) u_N14 (
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

    t12Node #(.FILE_NAME("prefix/hex/level5/node22.hex")) u_N22 (
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

    t12Node #(.FILE_NAME("prefix/hex/level5/node23.hex")) u_N23 (
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

    t12Node #(.FILE_NAME("prefix/hex/level5/node24.hex")) u_N24 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n24_data_out),
        .up_data_in(n24_up_data_in), .up_valid_in(n24_up_valid_in), .up_ready_in(n24_up_ready_in),
        .up_valid_out(n24_up_valid_out), .up_ready_out(n24_up_ready_out),
        .down_data_in(n24_down_data_in), .down_valid_in(n24_down_valid_in), .down_ready_in(n24_down_ready_in),
        .down_valid_out(n24_down_valid_out), .down_ready_out(n24_down_ready_out),
        .left_data_in(n24_left_data_in), .left_valid_in(n24_left_valid_in), .left_ready_in(n24_left_ready_in),
        .left_valid_out(n24_left_valid_out), .left_ready_out(n24_left_ready_out),
        .right_data_in(n24_right_data_in), .right_valid_in(n24_right_valid_in), .right_ready_in(n24_right_ready_in),
        .right_valid_out(n24_right_valid_out), .right_ready_out(n24_right_ready_out)
    );

    t12Node #(.FILE_NAME("prefix/hex/level5/node33.hex")) u_N33 (
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
    // Game paly topology linkes
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

    // N14.DOWN <-> N24.UP
    assign n24_up_data_in   = n14_data_out;
    assign n24_up_valid_in  = n14_down_valid_out;
    assign n14_down_ready_in = n24_up_ready_out;
    assign n14_down_data_in  = n24_data_out;
    assign n14_down_valid_in = n24_up_valid_out;
    assign n24_up_ready_in   = n14_down_ready_out;

    // N13.DOWN <-> N23.UP
    assign n23_up_data_in   = n13_data_out;
    assign n23_up_valid_in  = n13_down_valid_out;
    assign n13_down_ready_in = n23_up_ready_out;
    assign n13_down_data_in  = n23_data_out;
    assign n13_down_valid_in = n23_up_valid_out;
    assign n23_up_ready_in   = n13_down_ready_out;

    // N22.RIGHT <-> N23.LEFT
    assign n23_left_data_in   = n22_data_out;
    assign n23_left_valid_in  = n22_right_valid_out;
    assign n22_right_ready_in = n23_left_ready_out;
    assign n22_right_data_in  = n23_data_out;
    assign n22_right_valid_in = n23_left_valid_out;
    assign n23_left_ready_in  = n22_right_ready_out;

    // N23.RIGHT <-> N24.LEFT
    assign n24_left_data_in   = n23_data_out;
    assign n24_left_valid_in  = n23_right_valid_out;
    assign n23_right_ready_in = n24_left_ready_out;
    assign n23_right_data_in  = n24_data_out;
    assign n23_right_valid_in = n24_left_valid_out;
    assign n24_left_ready_in  = n23_right_ready_out;

    // N23.DOWN <-> N33.UP
    assign n33_up_data_in   = n23_data_out;
    assign n33_up_valid_in  = n23_down_valid_out;
    assign n23_down_ready_in = n33_up_ready_out;
    assign n23_down_data_in  = n33_data_out;
    assign n23_down_valid_in = n33_up_valid_out;
    assign n33_up_ready_in   = n23_down_ready_out;

    //=================================================
    // Main input/output data stream
    //=================================================
    // IN.A -> N12.UP
    assign n12_up_data_in  = in_a_data;
    assign n12_up_valid_in = in_a_valid;
    assign in_a_ready      = n12_up_ready_out;
    assign n12_up_ready_in = 1'b0;

    // IN.S -> N13.UP
    assign n13_up_data_in  = in_s_data;
    assign n13_up_valid_in = in_s_valid;
    assign in_s_ready      = n13_up_ready_out;
    assign n13_up_ready_in = 1'b0;

    // IN.B -> N14.UP
    assign n14_up_data_in  = in_b_data;
    assign n14_up_valid_in = in_b_valid;
    assign in_b_ready      = n14_up_ready_out;
    assign n14_up_ready_in = 1'b0;

    // N33.DOWN -> OUT
    assign out_data        = n33_data_out;
    assign out_valid       = n33_down_valid_out;
    assign n33_down_ready_in = out_ready;
    assign n33_down_data_in  = 24'sd0;
    assign n33_down_valid_in = 1'b0;

    //=================================================
    // Hardwire
    //=================================================
    assign n12_left_data_in = 24'sd0;  assign n12_left_valid_in = 1'b0;  assign n12_left_ready_in = 1'b1;
    assign n14_right_data_in = 24'sd0; assign n14_right_valid_in = 1'b0; assign n14_right_ready_in = 1'b1;
    assign n22_left_data_in = 24'sd0;  assign n22_left_valid_in = 1'b0;  assign n22_left_ready_in = 1'b1;
    assign n22_down_data_in = 24'sd0;  assign n22_down_valid_in = 1'b0;  assign n22_down_ready_in = 1'b1;
    assign n24_right_data_in = 24'sd0; assign n24_right_valid_in = 1'b0; assign n24_right_ready_in = 1'b1;
    assign n24_down_data_in = 24'sd0;  assign n24_down_valid_in = 1'b0;  assign n24_down_ready_in = 1'b1;
    assign n33_left_data_in = 24'sd0;  assign n33_left_valid_in = 1'b0;  assign n33_left_ready_in = 1'b1;
    assign n33_right_data_in = 24'sd0; assign n33_right_valid_in = 1'b0; assign n33_right_ready_in = 1'b1;

endmodule