module t30_node #(
    parameter DATA_WIDTH = 24,
    parameter STACK_DEPTH = 15
)(
    input  logic clk,
    input  logic rst,

    input  logic valid_in_u,
    input  logic ready_in_u,
    input  logic signed [DATA_WIDTH-1:0] data_in_u,
    output logic valid_out_u,
    output logic ready_out_u,
    output logic signed [DATA_WIDTH-1:0] data_out_u,

    input  logic valid_in_d,
    input  logic ready_in_d,
    input  logic signed [DATA_WIDTH-1:0] data_in_d,
    output logic valid_out_d,
    output logic ready_out_d,
    output logic signed [DATA_WIDTH-1:0] data_out_d,

    input  logic valid_in_l,
    input  logic ready_in_l,
    input  logic signed [DATA_WIDTH-1:0] data_in_l,
    output logic valid_out_l,
    output logic ready_out_l,
    output logic signed [DATA_WIDTH-1:0] data_out_l,

    input  logic valid_in_r,
    input  logic ready_in_r,
    input  logic signed [DATA_WIDTH-1:0] data_in_r,
    output logic valid_out_r,
    output logic ready_out_r,
    output logic signed [DATA_WIDTH-1:0] data_out_r
);

    logic is_empty;
    logic is_full;
    logic push_en;
    logic pop_en;
    logic signed [DATA_WIDTH-1:0] data_to_stack;
    logic signed [DATA_WIDTH-1:0] data_from_stack;

    assign data_out_u = data_from_stack;
    assign data_out_d = data_from_stack;
    assign data_out_l = data_from_stack;
    assign data_out_r = data_from_stack;

    stack_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(STACK_DEPTH)
    ) u_stack_mem (
        .clk(clk),
        .rst(rst),
        .push_en(push_en),
        .pop_en(pop_en),
        .data_in(data_to_stack),
        .data_out(data_from_stack),
        .is_empty(is_empty),
        .is_full(is_full)
    );

    t30_controller #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_controller (
        .valid_in_u(valid_in_u),
        .ready_in_u(ready_in_u),
        .valid_out_u(valid_out_u),
        .ready_out_u(ready_out_u),

        .valid_in_d(valid_in_d),
        .ready_in_d(ready_in_d),
        .valid_out_d(valid_out_d),
        .ready_out_d(ready_out_d),

        .valid_in_l(valid_in_l),
        .ready_in_l(ready_in_l),
        .valid_out_l(valid_out_l),
        .ready_out_l(ready_out_l),

        .valid_in_r(valid_in_r),
        .ready_in_r(ready_in_r),
        .valid_out_r(valid_out_r),
        .ready_out_r(ready_out_r),

        .is_empty(is_empty),
        .is_full(is_full),
        .push_en(push_en),
        .pop_en(pop_en),

        .data_in_u(data_in_u),
        .data_in_d(data_in_d),
        .data_in_l(data_in_l),
        .data_in_r(data_in_r),
        .data_to_stack(data_to_stack)
    );

endmodule
