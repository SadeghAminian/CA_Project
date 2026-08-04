module t30_controller #(
    parameter DATA_WIDTH = 24
)(
    input  logic valid_in_u, ready_in_u,
    output logic valid_out_u, ready_out_u,

    input  logic valid_in_d, ready_in_d,
    output logic valid_out_d, ready_out_d,

    input  logic valid_in_l, ready_in_l,
    output logic valid_out_l, ready_out_l,

    input  logic valid_in_r, ready_in_r,
    output logic valid_out_r, ready_out_r,

    input  logic is_empty,
    input  logic is_full,
    output logic push_en,
    output logic pop_en,
    
    // Data routing
    input  logic signed [DATA_WIDTH-1:0] data_in_u,
    input  logic signed [DATA_WIDTH-1:0] data_in_d,
    input  logic signed [DATA_WIDTH-1:0] data_in_l,
    input  logic signed [DATA_WIDTH-1:0] data_in_r,
    output logic signed [DATA_WIDTH-1:0] data_to_stack
);

    logic req_pu_u, req_po_u;
    logic req_pu_d, req_po_d;
    logic req_pu_l, req_po_l;
    logic req_pu_r, req_po_r;

    logic gr_pu_u, gr_po_u;
    logic gr_pu_d, gr_po_d;
    logic gr_pu_l, gr_po_l;
    logic gr_pu_r, gr_po_r;

    assign req_pu_u = valid_in_u & ~is_full;
    assign req_po_u = ready_in_u & ~is_empty;
    assign req_pu_d = valid_in_d & ~is_full;
    assign req_po_d = ready_in_d & ~is_empty;
    assign req_pu_l = valid_in_l & ~is_full;
    assign req_po_l = ready_in_l & ~is_empty;
    assign req_pu_r = valid_in_r & ~is_full;
    assign req_po_r = ready_in_r & ~is_empty;

    assign gr_pu_u = req_pu_u;
    assign gr_po_u = req_po_u & ~gr_pu_u;
    
    assign gr_pu_d = req_pu_d & ~gr_pu_u & ~gr_po_u;
    assign gr_po_d = req_po_d & ~gr_pu_u & ~gr_po_u & ~gr_pu_d;
    
    assign gr_pu_l = req_pu_l & ~gr_pu_u & ~gr_po_u & ~gr_pu_d & ~gr_po_d;
    assign gr_po_l = req_po_l & ~gr_pu_u & ~gr_po_u & ~gr_pu_d & ~gr_po_d & ~gr_pu_l;
    
    assign gr_pu_r = req_pu_r & ~gr_pu_u & ~gr_po_u & ~gr_pu_d & ~gr_po_d & ~gr_pu_l & ~gr_po_l;
    assign gr_po_r = req_po_r & ~gr_pu_u & ~gr_po_u & ~gr_pu_d & ~gr_po_d & ~gr_pu_l & ~gr_po_l & ~gr_pu_r;

    assign ready_out_u = gr_pu_u;
    assign valid_out_u = gr_po_u;

    assign ready_out_d = gr_pu_d;
    assign valid_out_d = gr_po_d;

    assign ready_out_l = gr_pu_l;
    assign valid_out_l = gr_po_l;

    assign ready_out_r = gr_pu_r;
    assign valid_out_r = gr_po_r;

    assign push_en = gr_pu_u | gr_pu_d | gr_pu_l | gr_pu_r;
    assign pop_en  = gr_po_u | gr_po_d | gr_po_l | gr_po_r;

    always_comb begin
        data_to_stack = 'sd0;
        if      (gr_pu_u) data_to_stack = data_in_u;
        else if (gr_pu_d) data_to_stack = data_in_d;
        else if (gr_pu_l) data_to_stack = data_in_l;
        else if (gr_pu_r) data_to_stack = data_in_r;
    end

endmodule
