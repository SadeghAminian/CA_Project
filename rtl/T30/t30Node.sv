//T30 stack node optimized
module t30Node #(
    parameter STACK_DEPTH = 16 )
(
    input logic clk, rst, 

    input logic left_valid_in,
    input logic right_valid_in,
    input logic up_valid_in,
    input logic down_valid_in,

    input logic left_ready_in,
    input logic right_ready_in,
    input logic up_ready_in,
    input logic down_ready_in,

    input logic signed [23:0] left_data_in,
    input logic signed [23:0] right_data_in,
    input logic signed [23:0] up_data_in,
    input logic signed [23:0] down_data_in,

    output logic signed [23:0] data_out,

    output logic left_ready_out,
    output logic right_ready_out,
    output logic up_ready_out,
    output logic down_ready_out,

    output logic left_valid_out,
    output logic right_valid_out,
    output logic up_valid_out,
    output logic down_valid_out
);

logic [1:0] WPsel, RPsel;
logic push, pop;
logic signed [23:0] data_in;
logic full, empty;


//=========================
// valid Encoder
//=========================
logic [3:0] wr_req;
assign wr_req = {down_valid_in, up_valid_in, right_valid_in, left_valid_in};
logic wr_req_valid;

always_comb begin
    casez (wr_req)
        4'b???1: WPsel = 2'b00; // LEFT 
        4'b??10: WPsel = 2'b01; //right
        4'b?100: WPsel = 2'b10; //up
        4'b1000: WPsel = 2'b11; //down
        default: WPsel = 2'b00;
    endcase
end
assign wr_req_valid = (down_valid_in | up_valid_in |  right_valid_in |  left_valid_in);

//==========================
// ready out signal decoder
//==========================
always_comb begin
    left_ready_out  = 1'b0;
    right_ready_out = 1'b0;
    up_ready_out    = 1'b0;
    down_ready_out  = 1'b0;
    if (push) begin
        case (WPsel)
        2'b00: left_ready_out  = 1'b1; // LEFT
        2'b01: right_ready_out = 1'b1;//right
        2'b10: up_ready_out    = 1'b1; //up
        2'b11: down_ready_out  = 1'b1;//down
        default: ;
    endcase
    end
end
assign push = (wr_req_valid & (!full) & (!pop));

//==========================
// data in mux
//==========================
always_comb begin
     case (WPsel)
        2'b00: data_in  = left_data_in;
        2'b01: data_in = right_data_in;
        2'b10: data_in    = up_data_in;
        2'b11: data_in  = down_data_in;
        default: data_in = 24'sd0;
    endcase
end

//=========================
// ready Encoder
//=========================
logic [3:0] re_req;
assign re_req = {down_ready_in, up_ready_in, right_ready_in, left_ready_in};
logic re_req_valid;

always_comb begin
    casez (re_req)
        4'b???1: RPsel = 2'b00; // LEFT 
        4'b??10: RPsel = 2'b01; //right
        4'b?100: RPsel = 2'b10; //up
        4'b1000: RPsel = 2'b11; //down
        default: RPsel = 2'b00;
    endcase
end
assign re_req_valid = (down_ready_in | up_ready_in | right_ready_in | left_ready_in);

//==========================
// ready out signal decoder
//==========================
always_comb begin
    left_valid_out  = 1'b0;
    right_valid_out = 1'b0;
    up_valid_out    = 1'b0;
    down_valid_out  = 1'b0;
    if (pop) begin
        case (RPsel)
        2'b00: left_valid_out  = 1'b1; // LEFT
        2'b01: right_valid_out = 1'b1;//right
        2'b10: up_valid_out    = 1'b1; //up
        2'b11: down_valid_out  = 1'b1;//down
        default: ;
    endcase
    end
end
assign pop = (re_req_valid & (!empty));

 stack_mem #(
        .DEPTH(STACK_DEPTH)
    ) u_stack_mem (
        .clk(clk),
        .rst(rst),
        .push_en(push),
        .pop_en(pop),
        .data_in(data_in),
        .data_out(data_out),
        .is_empty(empty),
        .is_full(full)
    );

endmodule