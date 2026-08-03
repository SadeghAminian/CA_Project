module tis100_stage7_top #(
    parameter string N10_HEX = "n10.hex",
    parameter string N20_HEX = "n20.hex",
    parameter string N11_HEX = "n11.hex",
    parameter string N21_HEX = "n21.hex",
    parameter string N12_HEX = "n12.hex",
    parameter string N22_HEX = "n22.hex"
) (
    input  logic clk,
    input  logic rst,

    input  logic signed [23:0] in_data,
    input  logic in_valid,
    output logic in_ready,

    output logic signed [23:0] out_s_data,
    output logic out_s_valid,
    input  logic out_s_ready,

    output logic signed [23:0] out_l_data,
    output logic out_l_valid,
    input  logic out_l_ready,

    output logic signed [23:0] acc_n10,
    output logic signed [23:0] acc_n20,
    output logic signed [23:0] acc_n11,
    output logic signed [23:0] acc_n21,
    output logic signed [23:0] acc_n12,
    output logic signed [23:0] acc_n22,

    output logic zero_n10,
    output logic zero_n20,
    output logic zero_n11,
    output logic zero_n21,
    output logic zero_n12,
    output logic zero_n22,

    output logic sign_n10,
    output logic sign_n20,
    output logic sign_n11,
    output logic sign_n21,
    output logic sign_n12,
    output logic sign_n22
);

    localparam logic signed [23:0] zero_data = 24'sd0;

    logic signed [23:0] n10_data_out;
    logic signed [23:0] n20_data_out;
    logic signed [23:0] n11_data_out;
    logic signed [23:0] n21_data_out;
    logic signed [23:0] n12_data_out;
    logic signed [23:0] n22_data_out;

    logic n10_left_ready_out, n10_right_ready_out, n10_up_ready_out, n10_down_ready_out;
    logic n20_left_ready_out, n20_right_ready_out, n20_up_ready_out, n20_down_ready_out;
    logic n11_left_ready_out, n11_right_ready_out, n11_up_ready_out, n11_down_ready_out;
    logic n21_left_ready_out, n21_right_ready_out, n21_up_ready_out, n21_down_ready_out;
    logic n12_left_ready_out, n12_right_ready_out, n12_up_ready_out, n12_down_ready_out;
    logic n22_left_ready_out, n22_right_ready_out, n22_up_ready_out, n22_down_ready_out;

    logic n10_left_valid_out, n10_right_valid_out, n10_up_valid_out, n10_down_valid_out;
    logic n20_left_valid_out, n20_right_valid_out, n20_up_valid_out, n20_down_valid_out;
    logic n11_left_valid_out, n11_right_valid_out, n11_up_valid_out, n11_down_valid_out;
    logic n21_left_valid_out, n21_right_valid_out, n21_up_valid_out, n21_down_valid_out;
    logic n12_left_valid_out, n12_right_valid_out, n12_up_valid_out, n12_down_valid_out;
    logic n22_left_valid_out, n22_right_valid_out, n22_up_valid_out, n22_down_valid_out;

    assign out_s_data  = n12_data_out;
    assign out_s_valid = n12_down_valid_out;

    assign out_l_data  = n22_data_out;
    assign out_l_valid = n22_down_valid_out;

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
        .up_data_in(in_data),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(in_valid),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(n20_left_ready_out),
        .up_ready_in(1'b0),
        .down_ready_in(n11_up_ready_out),

        .data_out(n10_data_out),

        .left_ready_out(n10_left_ready_out),
        .right_ready_out(n10_right_ready_out),
        .up_ready_out(in_ready),
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

        .left_data_in(n10_data_out),
        .right_data_in(zero_data),
        .up_data_in(zero_data),
        .down_data_in(zero_data),

        .left_valid_in(n10_right_valid_out),
        .right_valid_in(1'b0),
        .up_valid_in(1'b0),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(n21_up_ready_out),

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
        .FILE_NAME(N11_HEX)
    ) n11 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n11),
        .zero_flag(zero_n11),
        .sign_flag(sign_n11),

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
        .down_ready_in(n12_up_ready_out),

        .data_out(n11_data_out),

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
        .FILE_NAME(N21_HEX)
    ) n21 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n21),
        .zero_flag(zero_n21),
        .sign_flag(sign_n21),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(n20_data_out),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(n20_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(n22_up_ready_out),

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
        .FILE_NAME(N12_HEX)
    ) n12 (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_n12),
        .zero_flag(zero_n12),
        .sign_flag(sign_n12),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(n11_data_out),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(n11_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(out_s_ready),

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
        .up_data_in(n21_data_out),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(n21_down_valid_out),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(out_l_ready),

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

endmodule
