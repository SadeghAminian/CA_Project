module tis100_stage4_top #(
    parameter string N00_HEX = "n00.hex",
    parameter string N10_HEX = "n10.hex",
    parameter string N20_HEX = "n20.hex",
    parameter string N21_HEX = "n21.hex",
    parameter string N22_HEX = "n22.hex",
    parameter string N23_HEX = "n23.hex"
) (
    input  logic clk,
    input  logic rst,

    input  logic signed [23:0] in_data,
    input  logic in_valid,
    output logic in_ready,

    output logic signed [23:0] out_g_data,
    output logic out_g_valid,
    input  logic out_g_ready,

    output logic signed [23:0] out_e_data,
    output logic out_e_valid,
    input  logic out_e_ready,

    output logic signed [23:0] out_l_data,
    output logic out_l_valid,
    input  logic out_l_ready,

    output logic signed [23:0] acc_n00,
    output logic signed [23:0] acc_n10,
    output logic signed [23:0] acc_n20,
    output logic signed [23:0] acc_n21,
    output logic signed [23:0] acc_n22,
    output logic signed [23:0] acc_n23,

    output logic zero_n00,
    output logic zero_n10,
    output logic zero_n20,
    output logic zero_n21,
    output logic zero_n22,
    output logic zero_n23,

    output logic sign_n00,
    output logic sign_n10,
    output logic sign_n20,
    output logic sign_n21,
    output logic sign_n22,
    output logic sign_n23
);

    localparam logic signed [23:0] zero_data = 24'sd0;

    logic signed [23:0] n00_data_out;
    logic signed [23:0] n10_data_out;
    logic signed [23:0] n20_data_out;
    logic signed [23:0] n21_data_out;
    logic signed [23:0] n22_data_out;
    logic signed [23:0] n23_data_out;

    logic n00_left_ready_out, n00_right_ready_out, n00_up_ready_out, n00_down_ready_out;
    logic n10_left_ready_out, n10_right_ready_out, n10_up_ready_out, n10_down_ready_out;
    logic n20_left_ready_out, n20_right_ready_out, n20_up_ready_out, n20_down_ready_out;
    logic n21_left_ready_out, n21_right_ready_out, n21_up_ready_out, n21_down_ready_out;
    logic n22_left_ready_out, n22_right_ready_out, n22_up_ready_out, n22_down_ready_out;
    logic n23_left_ready_out, n23_right_ready_out, n23_up_ready_out, n23_down_ready_out;

    logic n00_left_valid_out, n00_right_valid_out, n00_up_valid_out, n00_down_valid_out;
    logic n10_left_valid_out, n10_right_valid_out, n10_up_valid_out, n10_down_valid_out;
    logic n20_left_valid_out, n20_right_valid_out, n20_up_valid_out, n20_down_valid_out;
    logic n21_left_valid_out, n21_right_valid_out, n21_up_valid_out, n21_down_valid_out;
    logic n22_left_valid_out, n22_right_valid_out, n22_up_valid_out, n22_down_valid_out;
    logic n23_left_valid_out, n23_right_valid_out, n23_up_valid_out, n23_down_valid_out;

    assign out_g_data  = n21_data_out;
    assign out_g_valid = n21_down_valid_out;

    assign out_e_data  = n22_data_out;
    assign out_e_valid = n22_down_valid_out;

    assign out_l_data  = n23_data_out;
    assign out_l_valid = n23_down_valid_out;

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
        .up_data_in(in_data),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(in_valid),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(n10_up_ready_out),

        .data_out(n00_data_out),

        .left_ready_out(n00_left_ready_out),
        .right_ready_out(n00_right_ready_out),
        .up_ready_out(in_ready),
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
        .right_ready_in(n21_left_ready_out),
        .up_ready_in(1'b0),
        .down_ready_in(1'b0),

        .data_out(n20_data_out),

        .left_ready_out(n20_left_ready_out),
        .right_ready_out(n20_right_ready_out),
        .up_ready_out(n20_up_ready_out),
        .down_ready_out(n20_down_ready_out),

        .left_valid_out(n20_left_valid_out),
        .right_valid_out(n20_right_valid_out),
        .up_valid_out(n20_up_valid_out),
        .down_valid_out(n20_down_valid_out)
    );

    t12Node #(
        .FILE_NAME(N21_HEX)
    ) n21 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n21),
        .zero_flag(zero_n21),
        .sign_flag(sign_n21),

        .left_data_in(n20_data_out),
        .right_data_in(zero_data),
        .up_data_in(zero_data),
        .down_data_in(zero_data),

        .left_valid_in(n20_right_valid_out),
        .right_valid_in(1'b0),
        .up_valid_in(1'b0),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(n22_left_ready_out),
        .up_ready_in(1'b0),
        .down_ready_in(out_g_ready),

        .data_out(n21_data_out),

        .left_ready_out(n21_left_ready_out),
        .right_ready_out(n21_right_ready_out),
        .up_ready_out(n21_up_ready_out),
        .down_ready_out(n21_down_ready_out),

        .left_valid_out(n21_left_valid_out),
        .right_valid_out(n21_right_valid_out),
        .up_valid_out(n21_up_valid_out),
        .down_valid_out(n21_down_valid_out)
    );

    t12Node #(
        .FILE_NAME(N22_HEX)
    ) n22 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n22),
        .zero_flag(zero_n22),
        .sign_flag(sign_n22),

        .left_data_in(n21_data_out),
        .right_data_in(zero_data),
        .up_data_in(zero_data),
        .down_data_in(zero_data),

        .left_valid_in(n21_right_valid_out),
        .right_valid_in(1'b0),
        .up_valid_in(1'b0),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(n23_left_ready_out),
        .up_ready_in(1'b0),
        .down_ready_in(out_e_ready),

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
        .down_ready_in(out_l_ready),

        .data_out(n23_data_out),

        .left_ready_out(n23_left_ready_out),
        .right_ready_out(n23_right_ready_out),
        .up_ready_out(n23_up_ready_out),
        .down_ready_out(n23_down_ready_out),

        .left_valid_out(n23_left_valid_out),
        .right_valid_out(n23_right_valid_out),
        .up_valid_out(n23_up_valid_out),
        .down_valid_out(n23_down_valid_out)
    );

endmodule
