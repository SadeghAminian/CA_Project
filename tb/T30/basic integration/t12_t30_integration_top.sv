`timescale 1ns/1ps

module t12_t30_integration_top #(
    parameter string PUSH_HEX = "t12_t30_push.hex",
    parameter string POP_HEX  = "t12_t30_pop.hex",
    parameter int STACK_DEPTH = 15,
    parameter int DATA_WIDTH  = 24
)(
    input  logic clk,
    input  logic rst,
    input  logic rst_pop_node,

    input  logic signed [DATA_WIDTH-1:0] in_data,
    input  logic                         in_valid,
    output logic                         in_ready,

    output logic signed [DATA_WIDTH-1:0] out_data,
    output logic                         out_valid,
    input  logic                         out_ready
);

    logic signed [DATA_WIDTH-1:0] zero_data;
    assign zero_data = '0;

    logic [23:0] acc_push;
    logic [23:0] acc_pop;
    logic zero_push;
    logic sign_push;
    logic zero_pop;
    logic sign_pop;

    logic signed [DATA_WIDTH-1:0] push_data_out;
    logic signed [DATA_WIDTH-1:0] pop_data_out;

    logic push_left_ready_out;
    logic push_right_ready_out;
    logic push_up_ready_out;
    logic push_down_ready_out;

    logic push_left_valid_out;
    logic push_right_valid_out;
    logic push_up_valid_out;
    logic push_down_valid_out;

    logic pop_left_ready_out;
    logic pop_right_ready_out;
    logic pop_up_ready_out;
    logic pop_down_ready_out;

    logic pop_left_valid_out;
    logic pop_right_valid_out;
    logic pop_up_valid_out;
    logic pop_down_valid_out;

    logic stack_valid_out_u;
    logic stack_ready_out_u;
    logic signed [DATA_WIDTH-1:0] stack_data_out_u;

    logic stack_valid_out_d;
    logic stack_ready_out_d;
    logic signed [DATA_WIDTH-1:0] stack_data_out_d;

    logic stack_valid_out_l;
    logic stack_ready_out_l;
    logic signed [DATA_WIDTH-1:0] stack_data_out_l;

    logic stack_valid_out_r;
    logic stack_ready_out_r;
    logic signed [DATA_WIDTH-1:0] stack_data_out_r;

    t12Node #(
        .FILE_NAME(PUSH_HEX)
    ) push_node (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_push),
        .zero_flag(zero_push),
        .sign_flag(sign_push),

        .left_data_in(zero_data),
        .right_data_in(zero_data),
        .up_data_in(in_data),
        .down_data_in(zero_data),

        .left_valid_in(1'b0),
        .right_valid_in(1'b0),
        .up_valid_in(in_valid),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(stack_ready_out_l),
        .up_ready_in(1'b0),
        .down_ready_in(1'b0),

        .data_out(push_data_out),

        .left_ready_out(push_left_ready_out),
        .right_ready_out(push_right_ready_out),
        .up_ready_out(in_ready),
        .down_ready_out(push_down_ready_out),

        .left_valid_out(push_left_valid_out),
        .right_valid_out(push_right_valid_out),
        .up_valid_out(push_up_valid_out),
        .down_valid_out(push_down_valid_out)
    );

    t30_node #(
        .DATA_WIDTH(DATA_WIDTH),
        .STACK_DEPTH(STACK_DEPTH)
    ) stack_node (
        .clk(clk),
        .rst(rst),

        .valid_in_u(1'b0),
        .ready_in_u(1'b0),
        .data_in_u(zero_data),
        .valid_out_u(stack_valid_out_u),
        .ready_out_u(stack_ready_out_u),
        .data_out_u(stack_data_out_u),

        .valid_in_d(1'b0),
        .ready_in_d(1'b0),
        .data_in_d(zero_data),
        .valid_out_d(stack_valid_out_d),
        .ready_out_d(stack_ready_out_d),
        .data_out_d(stack_data_out_d),

        .valid_in_l(push_right_valid_out),
        .ready_in_l(1'b0),
        .data_in_l(push_data_out),
        .valid_out_l(stack_valid_out_l),
        .ready_out_l(stack_ready_out_l),
        .data_out_l(stack_data_out_l),

        .valid_in_r(1'b0),
        .ready_in_r(rst_pop_node ? 1'b0 : pop_left_ready_out),
        .data_in_r(zero_data),
        .valid_out_r(stack_valid_out_r),
        .ready_out_r(stack_ready_out_r),
        .data_out_r(stack_data_out_r)
    );

    t12Node #(
        .FILE_NAME(POP_HEX)
    ) pop_node (
        .clk(clk),
        .rst(rst | rst_pop_node),
        .acc_out(acc_pop),
        .zero_flag(zero_pop),
        .sign_flag(sign_pop),

        .left_data_in(stack_data_out_r),
        .right_data_in(zero_data),
        .up_data_in(zero_data),
        .down_data_in(zero_data),

        .left_valid_in(stack_valid_out_r),
        .right_valid_in(1'b0),
        .up_valid_in(1'b0),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(out_ready),

        .data_out(pop_data_out),

        .left_ready_out(pop_left_ready_out),
        .right_ready_out(pop_right_ready_out),
        .up_ready_out(pop_up_ready_out),
        .down_ready_out(pop_down_ready_out),

        .left_valid_out(pop_left_valid_out),
        .right_valid_out(pop_right_valid_out),
        .up_valid_out(pop_up_valid_out),
        .down_valid_out(pop_down_valid_out)
    );

    assign out_data  = pop_data_out;
    assign out_valid = pop_down_valid_out;

endmodule
