`timescale 1ns/1ps

module t14_top #(
    parameter string N01_HEX     = "t14_n01.hex",
    parameter string N02_HEX     = "t14_n02.hex",
    parameter string N11_HEX     = "t14_n11.hex",
    parameter string N12_HEX     = "t14_n12.hex",
    parameter string N22_HEX     = "t14_n22.hex",
    parameter int    STACK_DEPTH = 15,
    parameter int    DATA_WIDTH  = 24
)(
    input  logic clk,
    input  logic rst,

    input  logic signed [DATA_WIDTH-1:0] in_a_data,
    input  logic                         in_a_valid,
    output logic                         in_a_ready,

    input  logic signed [DATA_WIDTH-1:0] in_b_data,
    input  logic                         in_b_valid,
    output logic                         in_b_ready,

    output logic signed [DATA_WIDTH-1:0] out_data,
    output logic                         out_valid,
    input  logic                         out_ready
);

    logic signed [DATA_WIDTH-1:0] zero_data;
    assign zero_data = '0;

    logic [23:0] acc_n01;
    logic [23:0] acc_n02;
    logic [23:0] acc_n11;
    logic [23:0] acc_n12;
    logic [23:0] acc_n22;

    logic zero_n01;
    logic zero_n02;
    logic zero_n11;
    logic zero_n12;
    logic zero_n22;

    logic sign_n01;
    logic sign_n02;
    logic sign_n11;
    logic sign_n12;
    logic sign_n22;

    logic signed [DATA_WIDTH-1:0] data_out_n01;
    logic signed [DATA_WIDTH-1:0] data_out_n02;
    logic signed [DATA_WIDTH-1:0] data_out_n11;
    logic signed [DATA_WIDTH-1:0] data_out_n12;
    logic signed [DATA_WIDTH-1:0] data_out_n22;

    logic n01_left_ready_out;
    logic n01_right_ready_out;
    logic n01_up_ready_out;
    logic n01_down_ready_out;
    logic n01_left_valid_out;
    logic n01_right_valid_out;
    logic n01_up_valid_out;
    logic n01_down_valid_out;

    logic n02_left_ready_out;
    logic n02_right_ready_out;
    logic n02_up_ready_out;
    logic n02_down_ready_out;
    logic n02_left_valid_out;
    logic n02_right_valid_out;
    logic n02_up_valid_out;
    logic n02_down_valid_out;

    logic n11_left_ready_out;
    logic n11_right_ready_out;
    logic n11_up_ready_out;
    logic n11_down_ready_out;
    logic n11_left_valid_out;
    logic n11_right_valid_out;
    logic n11_up_valid_out;
    logic n11_down_valid_out;

    logic n12_left_ready_out;
    logic n12_right_ready_out;
    logic n12_up_ready_out;
    logic n12_down_ready_out;
    logic n12_left_valid_out;
    logic n12_right_valid_out;
    logic n12_up_valid_out;
    logic n12_down_valid_out;

    logic n22_left_ready_out;
    logic n22_right_ready_out;
    logic n22_up_ready_out;
    logic n22_down_ready_out;
    logic n22_left_valid_out;
    logic n22_right_valid_out;
    logic n22_up_valid_out;
    logic n22_down_valid_out;

    logic n13_valid_out_u;
    logic n13_ready_out_u;
    logic signed [DATA_WIDTH-1:0] n13_data_out_u;

    logic n13_valid_out_d;
    logic n13_ready_out_d;
    logic signed [DATA_WIDTH-1:0] n13_data_out_d;

    logic n13_valid_out_l;
    logic n13_ready_out_l;
    logic signed [DATA_WIDTH-1:0] n13_data_out_l;

    logic n13_valid_out_r;
    logic n13_ready_out_r;
    logic signed [DATA_WIDTH-1:0] n13_data_out_r;

    t12Node #(
        .FILE_NAME(N01_HEX)
    ) n01 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n01),
        .zero_flag(zero_n01),
        .sign_flag(sign_n01),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(in_a_data),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(in_a_valid),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(n11_up_ready_out),

        .data_out(data_out_n01),

        .left_ready_out(n01_left_ready_out),
        .right_ready_out(n01_right_ready_out),
        .up_ready_out(in_a_ready),
        .down_ready_out(n01_down_ready_out),

        .left_valid_out(n01_left_valid_out),
        .right_valid_out(n01_right_valid_out),
        .up_valid_out(n01_up_valid_out),
        .down_valid_out(n01_down_valid_out)
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
        .right_data_in(zero_data),
        .up_data_in(in_b_data),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(in_b_valid),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(n12_up_ready_out),

        .data_out(data_out_n02),

        .left_ready_out(n02_left_ready_out),
        .right_ready_out(n02_right_ready_out),
        .up_ready_out(in_b_ready),
        .down_ready_out(n02_down_ready_out),

        .left_valid_out(n02_left_valid_out),
        .right_valid_out(n02_right_valid_out),
        .up_valid_out(n02_up_valid_out),
        .down_valid_out(n02_down_valid_out)
    );

    t30_node #(
        .DATA_WIDTH(DATA_WIDTH),
        .STACK_DEPTH(STACK_DEPTH)
    ) n10 (
        .clk(clk),
        .rst(rst),

        .valid_in_u(1'b0),
        .ready_in_u(1'b0),
        .data_in_u(zero_data),
        .valid_out_u(),
        .ready_out_u(),
        .data_out_u(),

        .valid_in_d(1'b0),
        .ready_in_d(1'b0),
        .data_in_d(zero_data),
        .valid_out_d(),
        .ready_out_d(),
        .data_out_d(),

        .valid_in_l(1'b0),
        .ready_in_l(1'b0),
        .data_in_l(zero_data),
        .valid_out_l(),
        .ready_out_l(),
        .data_out_l(),

        .valid_in_r(1'b0),
        .ready_in_r(1'b0),
        .data_in_r(zero_data),
        .valid_out_r(),
        .ready_out_r(),
        .data_out_r()
    );

    t12Node #(
        .FILE_NAME(N11_HEX)
    ) n11 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n11),
        .zero_flag(zero_n11),
        .sign_flag(sign_n11),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(data_out_n01),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(n01_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(n12_left_ready_out),
        .up_ready_in(1'b0),
        .down_ready_in(1'b0),

        .data_out(data_out_n11),

        .left_ready_out(n11_left_ready_out),
        .right_ready_out(n11_right_ready_out),
        .up_ready_out(n11_up_ready_out),
        .down_ready_out(n11_down_ready_out),

        .left_valid_out(n11_left_valid_out),
        .right_valid_out(n11_right_valid_out),
        .up_valid_out(n11_up_valid_out),
        .down_valid_out(n11_down_valid_out)
    );

    t12Node #(
        .FILE_NAME(N12_HEX)
    ) n12 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n12),
        .zero_flag(zero_n12),
        .sign_flag(sign_n12),

        .left_data_in(data_out_n11),
        .right_data_in(n13_data_out_l),
        .up_data_in(data_out_n02),
        .down_data_in(zero_data),

        .left_valid_in(n11_right_valid_out),
        .right_valid_in(n13_valid_out_l),
        .up_valid_in(n02_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(n13_ready_out_l),
        .up_ready_in(1'b0),
        .down_ready_in(n22_up_ready_out),

        .data_out(data_out_n12),

        .left_ready_out(n12_left_ready_out),
        .right_ready_out(n12_right_ready_out),
        .up_ready_out(n12_up_ready_out),
        .down_ready_out(n12_down_ready_out),

        .left_valid_out(n12_left_valid_out),
        .right_valid_out(n12_right_valid_out),
        .up_valid_out(n12_up_valid_out),
        .down_valid_out(n12_down_valid_out)
    );

    t30_node #(
        .DATA_WIDTH(DATA_WIDTH),
        .STACK_DEPTH(STACK_DEPTH)
    ) n13 (
        .clk(clk),
        .rst(rst),

        .valid_in_u(1'b0),
        .ready_in_u(1'b0),
        .data_in_u(zero_data),
        .valid_out_u(n13_valid_out_u),
        .ready_out_u(n13_ready_out_u),
        .data_out_u(n13_data_out_u),

        .valid_in_d(1'b0),
        .ready_in_d(1'b0),
        .data_in_d(zero_data),
        .valid_out_d(n13_valid_out_d),
        .ready_out_d(n13_ready_out_d),
        .data_out_d(n13_data_out_d),

        .valid_in_l(n12_right_valid_out),
        .ready_in_l(n12_right_ready_out),
        .data_in_l(data_out_n12),
        .valid_out_l(n13_valid_out_l),
        .ready_out_l(n13_ready_out_l),
        .data_out_l(n13_data_out_l),

        .valid_in_r(1'b0),
        .ready_in_r(1'b0),
        .data_in_r(zero_data),
        .valid_out_r(n13_valid_out_r),
        .ready_out_r(n13_ready_out_r),
        .data_out_r(n13_data_out_r)
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
        .up_data_in(data_out_n12),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(n12_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(out_ready),

        .data_out(data_out_n22),

        .left_ready_out(n22_left_ready_out),
        .right_ready_out(n22_right_ready_out),
        .up_ready_out(n22_up_ready_out),
        .down_ready_out(n22_down_ready_out),

        .left_valid_out(n22_left_valid_out),
        .right_valid_out(n22_right_valid_out),
        .up_valid_out(n22_up_valid_out),
        .down_valid_out(n22_down_valid_out)
    );

    assign out_data  = data_out_n22;
    assign out_valid = n22_down_valid_out;

endmodule
