`timescale 1ns/1ps
//=============================================================================
// Top module for TIS-100 Stage 8 (5 nodes)
// OUT[0]=0 ; OUT[i] = (|IN[i]-IN[i-1]| >= 10) ? 1 : 0
//=============================================================================
module Top_stage8 (
    input  logic        clk,
    input  logic        rst,
    // IN.A -> N12.UP
    input  logic signed [23:0] in_a_data,
    input  logic               in_a_valid,
    output logic               in_a_ready,
    // OUT <- N33.DOWN
    output logic signed [23:0] out_data,
    output logic               out_valid,
    input  logic               out_ready
);

    //=================================================
    // Node's external wire
    //=================================================
    logic signed [23:0] n11_data_out, n12_data_out, n22_data_out, n32_data_out, n33_data_out;

    logic signed [23:0] n11_up_data_in, n11_down_data_in, n11_left_data_in, n11_right_data_in;
    logic n11_up_valid_in, n11_down_valid_in, n11_left_valid_in, n11_right_valid_in;
    logic n11_up_ready_in, n11_down_ready_in, n11_left_ready_in, n11_right_ready_in;
    logic n11_up_valid_out, n11_down_valid_out, n11_left_valid_out, n11_right_valid_out;
    logic n11_up_ready_out, n11_down_ready_out, n11_left_ready_out, n11_right_ready_out;

    logic signed [23:0] n12_up_data_in, n12_down_data_in, n12_left_data_in, n12_right_data_in;
    logic n12_up_valid_in, n12_down_valid_in, n12_left_valid_in, n12_right_valid_in;
    logic n12_up_ready_in, n12_down_ready_in, n12_left_ready_in, n12_right_ready_in;
    logic n12_up_valid_out, n12_down_valid_out, n12_left_valid_out, n12_right_valid_out;
    logic n12_up_ready_out, n12_down_ready_out, n12_left_ready_out, n12_right_ready_out;

    logic signed [23:0] n22_up_data_in, n22_down_data_in, n22_left_data_in, n22_right_data_in;
    logic n22_up_valid_in, n22_down_valid_in, n22_left_valid_in, n22_right_valid_in;
    logic n22_up_ready_in, n22_down_ready_in, n22_left_ready_in, n22_right_ready_in;
    logic n22_up_valid_out, n22_down_valid_out, n22_left_valid_out, n22_right_valid_out;
    logic n22_up_ready_out, n22_down_ready_out, n22_left_ready_out, n22_right_ready_out;

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
    // ! Replace <prefix> by right address
    t12Node #(.FILE_NAME("prefix/hex/level8/node11.hex")) u_N11 (
        .clk(clk), .rst(rst), .acc_out(), .zero_flag(), .sign_flag(), .data_out(n11_data_out),
        .up_data_in(n11_up_data_in), .up_valid_in(n11_up_valid_in), .up_ready_in(n11_up_ready_in),
        .up_valid_out(n11_up_valid_out), .up_ready_out(n11_up_ready_out),
        .down_data_in(n11_down_data_in), .down_valid_in(n11_down_valid_in), .down_ready_in(n11_down_ready_in),
        .down_valid_out(n11_down_valid_out), .down_ready_out(n11_down_ready_out),
        .left_data_in(n11_left_data_in), .left_valid_in(n11_left_valid_in), .left_ready_in(n11_left_ready_in),
        .left_valid_out(n11_left_valid_out), .left_ready_out(n11_left_ready_out),
        .right_data_in(n11_right_data_in), .right_valid_in(n11_right_valid_in), .right_ready_in(n11_right_ready_in),
        .right_valid_out(n11_right_valid_out), .right_ready_out(n11_right_ready_out)
    );

    t12Node #(.FILE_NAME("prefix/hex/level8/node12.hex")) u_N12 (
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

    t12Node #(.FILE_NAME("prefix/hex/level8/node22.hex")) u_N22 (
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

    t12Node #(.FILE_NAME("prefix/hex/level8/node32.hex")) u_N32 (
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

    t12Node #(.FILE_NAME("prefix/hex/level8/node33.hex")) u_N33 (
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
    // Game play topology links
    //=================================================
    // N11.RIGHT <-> N12.LEFT
    assign n12_left_data_in   = n11_data_out;
    assign n12_left_valid_in  = n11_right_valid_out;
    assign n11_right_ready_in = n12_left_ready_out;
    assign n11_right_data_in  = n12_data_out;
    assign n11_right_valid_in = n12_left_valid_out;
    assign n12_left_ready_in  = n11_right_ready_out;

    // N12.DOWN <-> N22.UP
    assign n22_up_data_in   = n12_data_out;
    assign n22_up_valid_in  = n12_down_valid_out;
    assign n12_down_ready_in = n22_up_ready_out;
    assign n12_down_data_in  = n22_data_out;
    assign n12_down_valid_in = n22_up_valid_out;
    assign n22_up_ready_in   = n12_down_ready_out;

    // N22.DOWN <-> N32.UP
    assign n32_up_data_in   = n22_data_out;
    assign n32_up_valid_in  = n22_down_valid_out;
    assign n22_down_ready_in = n32_up_ready_out;
    assign n22_down_data_in  = n32_data_out;
    assign n22_down_valid_in = n32_up_valid_out;
    assign n32_up_ready_in   = n22_down_ready_out;

    // N32.RIGHT <-> N33.LEFT
    assign n33_left_data_in   = n32_data_out;
    assign n33_left_valid_in  = n32_right_valid_out;
    assign n32_right_ready_in = n33_left_ready_out;
    assign n32_right_data_in  = n33_data_out;
    assign n32_right_valid_in = n33_left_valid_out;
    assign n33_left_ready_in  = n32_right_ready_out;

    //=================================================
    // Main Input/Output data stream
    //=================================================
    // IN.A -> N12.UP
    assign n12_up_data_in  = in_a_data;
    assign n12_up_valid_in = in_a_valid;
    assign in_a_ready      = n12_up_ready_out;
    assign n12_up_ready_in = 1'b0;

    // N33.DOWN -> OUT
    assign out_data          = n33_data_out;
    assign out_valid         = n33_down_valid_out;
    assign n33_down_ready_in = out_ready;
    assign n33_down_data_in  = 24'sd0;
    assign n33_down_valid_in = 1'b0;

    //=================================================
    // Hardwire
    //=================================================
    assign n11_up_data_in    = 24'sd0; assign n11_up_valid_in    = 1'b0; assign n11_up_ready_in    = 1'b1;
    assign n11_down_data_in  = 24'sd0; assign n11_down_valid_in  = 1'b0; assign n11_down_ready_in  = 1'b1;
    assign n11_left_data_in  = 24'sd0; assign n11_left_valid_in  = 1'b0; assign n11_left_ready_in  = 1'b1;
    assign n12_right_data_in = 24'sd0; assign n12_right_valid_in = 1'b0; assign n12_right_ready_in = 1'b1;
    assign n22_left_data_in  = 24'sd0; assign n22_left_valid_in  = 1'b0; assign n22_left_ready_in  = 1'b1;
    assign n22_right_data_in = 24'sd0; assign n22_right_valid_in = 1'b0; assign n22_right_ready_in = 1'b1;
    assign n32_left_data_in  = 24'sd0; assign n32_left_valid_in  = 1'b0; assign n32_left_ready_in  = 1'b1;
    assign n32_down_data_in  = 24'sd0; assign n32_down_valid_in  = 1'b0; assign n32_down_ready_in  = 1'b1;
    assign n33_up_data_in    = 24'sd0; assign n33_up_valid_in    = 1'b0; assign n33_up_ready_in    = 1'b1;
    assign n33_right_data_in = 24'sd0; assign n33_right_valid_in = 1'b0; assign n33_right_ready_in = 1'b1;

endmodule