`timescale 1ns/1ps
//=============================================================================
// Top module for TIS-100 Stage 6 (4 nodes)
// OUT sequence per pair: min(A,B), max(A,B), 0
//=============================================================================
module Top_stage6 (
    input  logic        clk,
    input  logic        rst,
    // IN.A -> N12.UP
    input  logic signed [23:0] in_a_data,
    input  logic               in_a_valid,
    output logic               in_a_ready,
    // IN.B -> N13.UP
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
    logic signed [23:0] n12_data_out, n13_data_out, n23_data_out, n33_data_out;

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

    logic signed [23:0] n23_up_data_in, n23_down_data_in, n23_left_data_in, n23_right_data_in;
    logic n23_up_valid_in, n23_down_valid_in, n23_left_valid_in, n23_right_valid_in;
    logic n23_up_ready_in, n23_down_ready_in, n23_left_ready_in, n23_right_ready_in;
    logic n23_up_valid_out, n23_down_valid_out, n23_left_valid_out, n23_right_valid_out;
    logic n23_up_ready_out, n23_down_ready_out, n23_left_ready_out, n23_right_ready_out;

    logic signed [23:0] n33_up_data_in, n33_down_data_in, n33_left_data_in, n33_right_data_in;
    logic n33_up_valid_in, n33_down_valid_in, n33_left_valid_in, n33_right_valid_in;
    logic n33_up_ready_in, n33_down_ready_in, n33_left_ready_in, n33_right_ready_in;
    logic n33_up_valid_out, n33_down_valid_out, n33_left_valid_out, n33_right_valid_out;
    logic n33_up_ready_out, n33_down_ready_out, n33_left_ready_out, n33_right_ready_out;

    //=================================================
    // Instance
    //=================================================
    // ! Repalce <prefix> by right address
    t12Node #(.FILE_NAME("prefix/hex/level6/node12.hex")) u_N12 (
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

    t12Node #(.FILE_NAME("prefix/hex/level6/node13.hex")) u_N13 (
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

    t12Node #(.FILE_NAME("prefix/hex/level6/node23.hex")) u_N23 (
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

    t12Node #(.FILE_NAME("prefix/hex/level6/node33.hex")) u_N33 (
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
    // Game paly topology links
    //=================================================
    // N12.RIGHT <-> N13.LEFT
    assign n13_left_data_in   = n12_data_out;
    assign n13_left_valid_in  = n12_right_valid_out;
    assign n12_right_ready_in = n13_left_ready_out;
    assign n12_right_data_in  = n13_data_out;
    assign n12_right_valid_in = n13_left_valid_out;
    assign n13_left_ready_in  = n12_right_ready_out;

    // N13.DOWN <-> N23.UP
    assign n23_up_data_in   = n13_data_out;
    assign n23_up_valid_in  = n13_down_valid_out;
    assign n13_down_ready_in = n23_up_ready_out;
    assign n13_down_data_in  = n23_data_out;
    assign n13_down_valid_in = n23_up_valid_out;
    assign n23_up_ready_in   = n13_down_ready_out;

    // N23.DOWN <-> N33.UP
    assign n33_up_data_in   = n23_data_out;
    assign n33_up_valid_in  = n23_down_valid_out;
    assign n23_down_ready_in = n33_up_ready_out;
    assign n23_down_data_in  = n33_data_out;
    assign n23_down_valid_in = n33_up_valid_out;
    assign n33_up_ready_in   = n23_down_ready_out;

    //=================================================
    // Main Input/Output data stream
    //=================================================
    // IN.A -> N12.UP
    assign n12_up_data_in  = in_a_data;
    assign n12_up_valid_in = in_a_valid;
    assign in_a_ready      = n12_up_ready_out;
    assign n12_up_ready_in = 1'b0;

    // IN.B -> N13.UP
    assign n13_up_data_in  = in_b_data;
    assign n13_up_valid_in = in_b_valid;
    assign in_b_ready      = n13_up_ready_out;
    assign n13_up_ready_in = 1'b0;

    // N33.DOWN -> OUT
    assign out_data          = n33_data_out;
    assign out_valid         = n33_down_valid_out;
    assign n33_down_ready_in = out_ready;
    assign n33_down_data_in  = 24'sd0;
    assign n33_down_valid_in = 1'b0;

    //=================================================
    // Hardwire
    //=================================================
    assign n12_left_data_in  = 24'sd0; assign n12_left_valid_in  = 1'b0; assign n12_left_ready_in  = 1'b1;
    assign n12_down_data_in  = 24'sd0; assign n12_down_valid_in  = 1'b0; assign n12_down_ready_in  = 1'b1;
    assign n13_right_data_in = 24'sd0; assign n13_right_valid_in = 1'b0; assign n13_right_ready_in = 1'b1;
    assign n23_left_data_in  = 24'sd0; assign n23_left_valid_in  = 1'b0; assign n23_left_ready_in  = 1'b1;
    assign n23_right_data_in = 24'sd0; assign n23_right_valid_in = 1'b0; assign n23_right_ready_in = 1'b1;
    assign n33_left_data_in  = 24'sd0; assign n33_left_valid_in  = 1'b0; assign n33_left_ready_in  = 1'b1;
    assign n33_right_data_in = 24'sd0; assign n33_right_valid_in = 1'b0; assign n33_right_ready_in = 1'b1;

endmodule