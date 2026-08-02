`timescale 1ns/1ps

module two_node_link_top #(
    parameter string NODE_A_FILE = "node_a.hex",
    parameter string NODE_B_FILE = "node_b.hex"
)(
    input logic clk,
    input logic rst,

    output logic [23:0] acc_a_out,
    output logic [23:0] acc_b_out,

    output logic signed [23:0] a_to_b_data,
    output logic a_to_b_valid,
    output logic a_to_b_ready,

    output logic signed [23:0] b_to_a_data,
    output logic b_to_a_valid,
    output logic b_to_a_ready
);

    logic zero_a;
    logic sign_a;
    logic zero_b;
    logic sign_b;

    logic signed [23:0] node_a_data_out;
    logic signed [23:0] node_b_data_out;

    logic node_a_right_ready_out;
    logic node_a_right_valid_out;
    logic node_b_left_ready_out;
    logic node_b_left_valid_out;

    assign a_to_b_data  = node_a_data_out;
    assign a_to_b_valid = node_a_right_valid_out;
    assign a_to_b_ready = node_b_left_ready_out;

    assign b_to_a_data  = node_b_data_out;
    assign b_to_a_valid = node_b_left_valid_out;
    assign b_to_a_ready = node_a_right_ready_out;

    t12Node #(
        .FILE_NAME(NODE_A_FILE)
    ) node_a (
        .clk(clk),
        .rst(rst),

        .acc_out(acc_a_out),
        .zero_flag(zero_a),
        .sign_flag(sign_a),

        .left_data_in(24'sd0),
        .right_data_in(node_b_data_out),
        .up_data_in(24'sd0),
        .down_data_in(24'sd0),

        .left_valid_in(1'b0),
        .right_valid_in(node_b_left_valid_out),
        .up_valid_in(1'b0),
        .down_valid_in(1'b0),

        .left_ready_in(1'b0),
        .right_ready_in(node_b_left_ready_out),
        .up_ready_in(1'b0),
        .down_ready_in(1'b0),

        .data_out(node_a_data_out),

        .left_ready_out(),
        .right_ready_out(node_a_right_ready_out),
        .up_ready_out(),
        .down_ready_out(),

        .left_valid_out(),
        .right_valid_out(node_a_right_valid_out),
        .up_valid_out(),
        .down_valid_out()
    );

    t12Node #(
        .FILE_NAME(NODE_B_FILE)
    ) node_b (
        .clk(clk),
        .rst(rst),

        .acc_out(acc_b_out),
        .zero_flag(zero_b),
        .sign_flag(sign_b),

        .left_data_in(node_a_data_out),
        .right_data_in(24'sd0),
        .up_data_in(24'sd0),
        .down_data_in(24'sd0),

        .left_valid_in(node_a_right_valid_out),
        .right_valid_in(1'b0),
        .up_valid_in(1'b0),
        .down_valid_in(1'b0),

        .left_ready_in(node_a_right_ready_out),
        .right_ready_in(1'b0),
        .up_ready_in(1'b0),
        .down_ready_in(1'b0),

        .data_out(node_b_data_out),

        .left_ready_out(node_b_left_ready_out),
        .right_ready_out(),
        .up_ready_out(),
        .down_ready_out(),

        .left_valid_out(node_b_left_valid_out),
        .right_valid_out(),
        .up_valid_out(),
        .down_valid_out()
    );

endmodule
