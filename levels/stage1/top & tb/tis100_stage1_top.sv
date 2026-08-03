`timescale 1ns/1ps

module tis100_stage1_top #(
    parameter string N00_HEX = "n00.hex",
    parameter string N10_HEX = "n10.hex",
    parameter string N20_HEX = "n20.hex",
    parameter string N03_HEX = "n03.hex",
    parameter string N02_HEX = "n02.hex",
    parameter string N12_HEX = "n12.hex",
    parameter string N22_HEX = "n22.hex",
    parameter string N23_HEX = "n23.hex"
)(
    input  logic clk,
    input  logic rst,

    input  logic signed [23:0] in_x_data,
    input  logic               in_x_valid,
    output logic               in_x_ready,

    input  logic signed [23:0] in_a_data,
    input  logic               in_a_valid,
    output logic               in_a_ready,

    output logic signed [23:0] out_x_data,
    output logic               out_x_valid,
    input  logic               out_x_ready,

    output logic signed [23:0] out_a_data,
    output logic               out_a_valid,
    input  logic               out_a_ready
);

    logic signed [23:0] zero_data;
    assign zero_data = 24'sd0;

    logic unused_ready;

    logic [23:0] acc_n00, acc_n10, acc_n20, acc_n03, acc_n02, acc_n12, acc_n22, acc_n23;
    logic zero_n00, zero_n10, zero_n20, zero_n03, zero_n02, zero_n12, zero_n22, zero_n23;
    logic sign_n00, sign_n10, sign_n20, sign_n03, sign_n02, sign_n12, sign_n22, sign_n23;

    logic signed [23:0] n00_data_out, n10_data_out, n20_data_out, n03_data_out;
    logic signed [23:0] n02_data_out, n12_data_out, n22_data_out, n23_data_out;

    logic n00_left_ready_out,  n00_right_ready_out,  n00_up_ready_out,  n00_down_ready_out;
    logic n10_left_ready_out,  n10_right_ready_out,  n10_up_ready_out,  n10_down_ready_out;
    logic n20_left_ready_out,  n20_right_ready_out,  n20_up_ready_out,  n20_down_ready_out;
    logic n03_left_ready_out,  n03_right_ready_out,  n03_up_ready_out,  n03_down_ready_out;
    logic n02_left_ready_out,  n02_right_ready_out,  n02_up_ready_out,  n02_down_ready_out;
    logic n12_left_ready_out,  n12_right_ready_out,  n12_up_ready_out,  n12_down_ready_out;
    logic n22_left_ready_out,  n22_right_ready_out,  n22_up_ready_out,  n22_down_ready_out;
    logic n23_left_ready_out,  n23_right_ready_out,  n23_up_ready_out,  n23_down_ready_out;

    logic n00_left_valid_out,  n00_right_valid_out,  n00_up_valid_out,  n00_down_valid_out;
    logic n10_left_valid_out,  n10_right_valid_out,  n10_up_valid_out,  n10_down_valid_out;
    logic n20_left_valid_out,  n20_right_valid_out,  n20_up_valid_out,  n20_down_valid_out;
    logic n03_left_valid_out,  n03_right_valid_out,  n03_up_valid_out,  n03_down_valid_out;
    logic n02_left_valid_out,  n02_right_valid_out,  n02_up_valid_out,  n02_down_valid_out;
    logic n12_left_valid_out,  n12_right_valid_out,  n12_up_valid_out,  n12_down_valid_out;
    logic n22_left_valid_out,  n22_right_valid_out,  n22_up_valid_out,  n22_down_valid_out;
    logic n23_left_valid_out,  n23_right_valid_out,  n23_up_valid_out,  n23_down_valid_out;

    t12Node #(
        .FILE_NAME(N00_HEX)
    ) n00 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n00),
        .zero_flag(zero_n00),
        .sign_flag(sign_n00),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(in_x_data),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(in_x_valid),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(n10_up_ready_out),

        .data_out(n00_data_out),
        .left_ready_out(n00_left_ready_out),
        .right_ready_out(n00_right_ready_out),
        .up_ready_out(in_x_ready),
        .down_ready_out(n00_down_ready_out),

        .left_valid_out(n00_left_valid_out),
        .right_valid_out(n00_right_valid_out),
        .up_valid_out(n00_up_valid_out),
        .down_valid_out(n00_down_valid_out)
    );

    t12Node #(
        .FILE_NAME(N10_HEX)
    ) n10 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n10),
        .zero_flag(zero_n10),
        .sign_flag(sign_n10),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(n00_data_out),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(n00_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(n20_up_ready_out),

        .data_out(n10_data_out),
        .left_ready_out(n10_left_ready_out),
        .right_ready_out(n10_right_ready_out),
        .up_ready_out(n10_up_ready_out),
        .down_ready_out(n10_down_ready_out),

        .left_valid_out(n10_left_valid_out),
        .right_valid_out(n10_right_valid_out),
        .up_valid_out(n10_up_valid_out),
        .down_valid_out(n10_down_valid_out)
    );

    t12Node #(
        .FILE_NAME(N20_HEX)
    ) n20 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n20),
        .zero_flag(zero_n20),
        .sign_flag(sign_n20),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(n10_data_out),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(n10_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(out_x_ready),

        .data_out(out_x_data),
        .left_ready_out(n20_left_ready_out),
        .right_ready_out(n20_right_ready_out),
        .up_ready_out(n20_up_ready_out),
        .down_ready_out(unused_ready),

        .left_valid_out(n20_left_valid_out),
        .right_valid_out(n20_right_valid_out),
        .up_valid_out(n20_up_valid_out),
        .down_valid_out(out_x_valid)
    );

    t12Node #(
    .FILE_NAME(N03_HEX)
    ) n03 (
        .clk(clk),
        .rst(rst),
    
        .acc_out(acc_n03),
        .zero_flag(zero_n03),
        .sign_flag(sign_n03),
    
        .left_data_in(24'sd0),
        .right_data_in(24'sd0),
        .up_data_in(in_a_data),
        .down_data_in(24'sd0),
    
        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(in_a_valid),
        .down_valid_in(1'b0),
    
        .left_ready_in(n02_right_ready_out),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(1'b0),
    
        .data_out(n03_data_out),
    
        .left_ready_out(n03_left_ready_out),
        .right_ready_out(n03_right_ready_out),
        .up_ready_out(in_a_ready),
        .down_ready_out(n03_down_ready_out),
    
        .left_valid_out(n03_left_valid_out),
        .right_valid_out(n03_right_valid_out),
        .up_valid_out(n03_up_valid_out),
        .down_valid_out(n03_down_valid_out)
    );

    t12Node #(
        .FILE_NAME(N02_HEX)
    ) n02 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n02),
        .zero_flag(zero_n02),
        .sign_flag(sign_n02),

        .left_data_in(zero_data),
        .right_data_in(n03_data_out),
        .up_data_in(zero_data),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(n03_left_valid_out),
        .up_valid_in(1'b0),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(n12_up_ready_out),

        .data_out(n02_data_out),
        .left_ready_out(n02_left_ready_out),
        .right_ready_out(n02_right_ready_out),
        .up_ready_out(n02_up_ready_out),
        .down_ready_out(n02_down_ready_out),

        .left_valid_out(n02_left_valid_out),
        .right_valid_out(n02_right_valid_out),
        .up_valid_out(n02_up_valid_out),
        .down_valid_out(n02_down_valid_out)
    );

    t12Node #(
        .FILE_NAME(N12_HEX)
    ) n12 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n12),
        .zero_flag(zero_n12),
        .sign_flag(sign_n12),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(n02_data_out),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(n02_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(n22_up_ready_out),

        .data_out(n12_data_out),
        .left_ready_out(n12_left_ready_out),
        .right_ready_out(n12_right_ready_out),
        .up_ready_out(n12_up_ready_out),
        .down_ready_out(n12_down_ready_out),

        .left_valid_out(n12_left_valid_out),
        .right_valid_out(n12_right_valid_out),
        .up_valid_out(n12_up_valid_out),
        .down_valid_out(n12_down_valid_out)
    );

    t12Node #(
        .FILE_NAME(N22_HEX)
    ) n22 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n22),
        .zero_flag(zero_n22),
        .sign_flag(sign_n22),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(n12_data_out),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(n12_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(n23_left_ready_out),
        .up_ready_in(1'b0),
        .down_ready_in(1'b0),

        .data_out(n22_data_out),
        .left_ready_out(n22_left_ready_out),
        .right_ready_out(n22_right_ready_out),
        .up_ready_out(n22_up_ready_out),
        .down_ready_out(n22_down_ready_out),

        .left_valid_out(n22_left_valid_out),
        .right_valid_out(n22_right_valid_out),
        .up_valid_out(n22_up_valid_out),
        .down_valid_out(n22_down_valid_out)
    );

    t12Node #(
        .FILE_NAME(N23_HEX)
    ) n23 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n23),
        .zero_flag(zero_n23),
        .sign_flag(sign_n23),

        .left_data_in(n22_data_out),
        .right_data_in(zero_data),
        .up_data_in(zero_data),
        .down_data_in(zero_data),

        .left_valid_in(n22_right_valid_out),
        .right_valid_in(1'b0),
        .up_valid_in(1'b0),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(out_a_ready),

        .data_out(out_a_data),
        .left_ready_out(n23_left_ready_out),
        .right_ready_out(n23_right_ready_out),
        .up_ready_out(n23_up_ready_out),
        .down_ready_out(unused_ready),

        .left_valid_out(n23_left_valid_out),
        .right_valid_out(n23_right_valid_out),
        .up_valid_out(n23_up_valid_out),
        .down_valid_out(out_a_valid)
    );

endmodule
