// port_interface.sv
// Handles valid/ready handshake for all 4 physical ports + ANY/LAST resolution
module port_interface (
    input  logic        clk, rst,
    input  logic        port_rd,
    input  logic        port_wr,
    input  logic [2:0]  port_sel,    // 2=LEFT,3=RIGHT,4=UP,5=DOWN,6=ANY,7=LAST
    input  logic [10:0] wr_data,     // ACC value to send
    output logic [10:0] rd_data,     // received value → datapath
    output logic        port_ready,  // handshake done this cycle → control_unit

    // Physical port buses (index: 0=LEFT,1=RIGHT,2=UP,3=DOWN)
    output logic [3:0]  tx_valid,
    output logic [10:0] tx_data [3:0],
    input  logic [3:0]  tx_ready,    // neighbor accepted

    input  logic [3:0]  rx_valid,    // neighbor sending
    input  logic [10:0] rx_data [3:0],
    output logic [3:0]  rx_ready     // we can accept
);

    logic [1:0] last_port;

    // Resolve port_sel → 2-bit index
    logic [1:0] sel_idx;
    always_comb begin
        case (port_sel)
            3'd2:    sel_idx = 2'd0;   // LEFT
            3'd3:    sel_idx = 2'd1;   // RIGHT
            3'd4:    sel_idx = 2'd2;   // UP
            3'd5:    sel_idx = 2'd3;   // DOWN
            3'd7:    sel_idx = last_port;
            default: sel_idx = 2'd0;   // ANY: overridden below
        endcase
    end

    // ANY: priority-encode first available port (lowest index wins)
    logic [1:0] any_idx;
    always_comb begin
        any_idx = 2'd0;
        for (int i = 3; i >= 0; i--)
            if (port_rd ? rx_valid[i[1:0]] : tx_ready[i[1:0]])
                any_idx = i[1:0];
    end

    logic [1:0] active_idx;
    assign active_idx = (port_sel == 3'd6) ? any_idx : sel_idx;

    // Drive handshake signals
    always_comb begin
        tx_valid   = '0;
        rx_ready   = '0;
        rd_data    = '0;
        port_ready = 1'b0;
        for (int i = 0; i < 4; i++) tx_data[i] = wr_data;

        if (port_wr) begin
            tx_valid[active_idx] = 1'b1;
            port_ready           = tx_ready[active_idx];
        end else if (port_rd) begin
            rx_ready[active_idx] = 1'b1;
            port_ready           = rx_valid[active_idx];
            rd_data              = rx_data[active_idx];
        end
    end

    // Track LAST port
    always_ff @(posedge clk or posedge rst)
        if (rst)                              last_port <= 2'd0;
        else if (port_ready && (port_rd || port_wr)) last_port <= active_idx;

endmodule
