module tis100_stage9_top #(
    parameter string N10_HEX = "n10.hex",
    parameter string N20_HEX = "n20.hex",
    parameter string N30_HEX = "n30.hex",
    parameter string N40_HEX = "n40.hex",
    parameter string N11_HEX = "n11.hex",
    parameter string N21_HEX = "n21.hex",
    parameter string N31_HEX = "n31.hex",
    parameter string N41_HEX = "n41.hex",
    parameter string N32_HEX = "n32.hex"
) (
    input  logic clk,
    input  logic rst,

    input  logic signed [23:0] in1_data,
    input  logic in1_valid,
    output logic in1_ready,

    input  logic signed [23:0] in2_data,
    input  logic in2_valid,
    output logic in2_ready,

    input  logic signed [23:0] in3_data,
    input  logic in3_valid,
    output logic in3_ready,

    input  logic signed [23:0] in4_data,
    input  logic in4_valid,
    output logic in4_ready,

    output logic signed [23:0] out_data,
    output logic out_valid,
    input  logic out_ready,

    output logic signed [23:0] acc_n10,
    output logic signed [23:0] acc_n20,
    output logic signed [23:0] acc_n30,
    output logic signed [23:0] acc_n40,
    output logic signed [23:0] acc_n11,
    output logic signed [23:0] acc_n21,
    output logic signed [23:0] acc_n31,
    output logic signed [23:0] acc_n41,
    output logic signed [23:0] acc_n32,

    output logic zero_n10,
    output logic zero_n20,
    output logic zero_n30,
    output logic zero_n40,
    output logic zero_n11,
    output logic zero_n21,
    output logic zero_n31,
    output logic zero_n41,
    output logic zero_n32,

    output logic sign_n10,
    output logic sign_n20,
    output logic sign_n30,
    output logic sign_n40,
    output logic sign_n11,
    output logic sign_n21,
    output logic sign_n31,
    output logic sign_n41,
    output logic sign_n32
);

    localparam logic signed [23:0] zero_data = 24'sd0;

    logic signed [23:0] n10_data_out, n20_data_out, n30_data_out, n40_data_out;
    logic signed [23:0] n11_data_out, n21_data_out, n31_data_out, n41_data_out, n32_data_out;

    logic n10_left_ready_out, n10_right_ready_out, n10_up_ready_out, n10_down_ready_out;
    logic n20_left_ready_out, n20_right_ready_out, n20_up_ready_out, n20_down_ready_out;
    logic n30_left_ready_out, n30_right_ready_out, n30_up_ready_out, n30_down_ready_out;
    logic n40_left_ready_out, n40_right_ready_out, n40_up_ready_out, n40_down_ready_out;
    logic n11_left_ready_out, n11_right_ready_out, n11_up_ready_out, n11_down_ready_out;
    logic n21_left_ready_out, n21_right_ready_out, n21_up_ready_out, n21_down_ready_out;
    logic n31_left_ready_out, n31_right_ready_out, n31_up_ready_out, n31_down_ready_out;
    logic n41_left_ready_out, n41_right_ready_out, n41_up_ready_out, n41_down_ready_out;
    logic n32_left_ready_out, n32_right_ready_out, n32_up_ready_out, n32_down_ready_out;

    logic n10_left_valid_out, n10_right_valid_out, n10_up_valid_out, n10_down_valid_out;
    logic n20_left_valid_out, n20_right_valid_out, n20_up_valid_out, n20_down_valid_out;
    logic n30_left_valid_out, n30_right_valid_out, n30_up_valid_out, n30_down_valid_out;
    logic n40_left_valid_out, n40_right_valid_out, n40_up_valid_out, n40_down_valid_out;
    logic n11_left_valid_out, n11_right_valid_out, n11_up_valid_out, n11_down_valid_out;
    logic n21_left_valid_out, n21_right_valid_out, n21_up_valid_out, n21_down_valid_out;
    logic n31_left_valid_out, n31_right_valid_out, n31_up_valid_out, n31_down_valid_out;
    logic n41_left_valid_out, n41_right_valid_out, n41_up_valid_out, n41_down_valid_out;
    logic n32_left_valid_out, n32_right_valid_out, n32_up_valid_out, n32_down_valid_out;

    assign in1_ready = n10_up_ready_out;
    assign in2_ready = n20_up_ready_out;
    assign in3_ready = n30_up_ready_out;
    assign in4_ready = n40_up_ready_out;

    assign out_data  = n32_data_out;
    assign out_valid = n32_down_valid_out;

`define T12_NODE(INST, HEX, ACC, ZERO, SIGN, LDI, RDI, UDI, DDI, LVI, RVI, UVI, DVI, LRI, RRI, URI, DRI) \
    t12Node #( \
        .FILE_NAME(HEX) \
    ) INST ( \
        .clk(clk), \
        .rst(rst), \
        .acc_out(ACC), \
        .zero_flag(ZERO), \
        .sign_flag(SIGN), \
        .left_data_in(LDI), \
        .right_data_in(RDI), \
        .up_data_in(UDI), \
        .down_data_in(DDI), \
        .left_valid_in(LVI), \
        .right_valid_in(RVI), \
        .up_valid_in(UVI), \
        .down_valid_in(DVI), \
        .left_ready_in(LRI), \
        .right_ready_in(RRI), \
        .up_ready_in(URI), \
        .down_ready_in(DRI), \
        .data_out(INST``_data_out), \
        .left_ready_out(INST``_left_ready_out), \
        .right_ready_out(INST``_right_ready_out), \
        .up_ready_out(INST``_up_ready_out), \
        .down_ready_out(INST``_down_ready_out), \
        .left_valid_out(INST``_left_valid_out), \
        .right_valid_out(INST``_right_valid_out), \
        .up_valid_out(INST``_up_valid_out), \
        .down_valid_out(INST``_down_valid_out) \
    );

    `T12_NODE(n10, N10_HEX, acc_n10, zero_n10, sign_n10,
        zero_data, zero_data, in1_data, zero_data,
        1'b0, 1'b0, in1_valid, 1'b0,
        1'b0, 1'b0, 1'b0, n11_up_ready_out)

    `T12_NODE(n20, N20_HEX, acc_n20, zero_n20, sign_n20,
        zero_data, zero_data, in2_data, zero_data,
        1'b0, 1'b0, in2_valid, 1'b0,
        1'b0, 1'b0, 1'b0, n21_up_ready_out)

    `T12_NODE(n30, N30_HEX, acc_n30, zero_n30, sign_n30,
        zero_data, zero_data, in3_data, zero_data,
        1'b0, 1'b0, in3_valid, 1'b0,
        1'b0, 1'b0, 1'b0, n31_up_ready_out)

    `T12_NODE(n40, N40_HEX, acc_n40, zero_n40, sign_n40,
        zero_data, zero_data, in4_data, zero_data,
        1'b0, 1'b0, in4_valid, 1'b0,
        1'b0, 1'b0, 1'b0, n41_up_ready_out)

    `T12_NODE(n11, N11_HEX, acc_n11, zero_n11, sign_n11,
        zero_data, zero_data, n10_data_out, zero_data,
        1'b0, 1'b0, n10_down_valid_out, 1'b0,
        1'b0, n21_left_ready_out, 1'b0, 1'b0)

    `T12_NODE(n21, N21_HEX, acc_n21, zero_n21, sign_n21,
        n11_data_out, zero_data, n20_data_out, zero_data,
        n11_right_valid_out, 1'b0, n20_down_valid_out, 1'b0,
        1'b0, n31_left_ready_out, 1'b0, 1'b0)

    `T12_NODE(n31, N31_HEX, acc_n31, zero_n31, sign_n31,
        n21_data_out, n41_data_out, n30_data_out, zero_data,
        n21_right_valid_out, n41_left_valid_out, n30_down_valid_out, 1'b0,
        1'b0, 1'b0, 1'b0, n32_up_ready_out)

    `T12_NODE(n41, N41_HEX, acc_n41, zero_n41, sign_n41,
        zero_data, zero_data, n40_data_out, zero_data,
        1'b0, 1'b0, n40_down_valid_out, 1'b0,
        n31_right_ready_out, 1'b0, 1'b0, 1'b0)

    `T12_NODE(n32, N32_HEX, acc_n32, zero_n32, sign_n32,
        zero_data, zero_data, n31_data_out, zero_data,
        1'b0, 1'b0, n31_down_valid_out, 1'b0,
        1'b0, 1'b0, 1'b0, out_ready)

`undef T12_NODE

endmodule
