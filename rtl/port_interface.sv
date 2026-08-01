module port_interface (
    input  logic        clk,
    input  logic        rst,

    input  logic        port_rd,
    input  logic        port_wr,
    input  logic [2:0]  port_sel,
    output logic        port_ready,

    output logic signed [10:0] rd_data,
    input  logic signed [10:0] wr_data,

    input  logic        left_rx_valid,
    input  logic signed [10:0] left_rx_data,
    output logic        left_rx_ready,
    output logic        left_tx_valid,
    output logic signed [10:0] left_tx_data,
    input  logic        left_tx_ready,

    input  logic        right_rx_valid,
    input  logic signed [10:0] right_rx_data,
    output logic        right_rx_ready,
    output logic        right_tx_valid,
    output logic signed [10:0] right_tx_data,
    input  logic        right_tx_ready,

    input  logic        up_rx_valid,
    input  logic signed [10:0] up_rx_data,
    output logic        up_rx_ready,
    output logic        up_tx_valid,
    output logic signed [10:0] up_tx_data,
    input  logic        up_tx_ready,

    input  logic        down_rx_valid,
    input  logic signed [10:0] down_rx_data,
    output logic        down_rx_ready,
    output logic        down_tx_valid,
    output logic signed [10:0] down_tx_data,
    input  logic        down_tx_ready
);
    import tis100_pkg::*;

    logic [2:0] last_port;
    logic       last_valid;

    logic [2:0] any_wr_probe_sel;
    logic [2:0] any_rd_probe_sel;

    logic [2:0] any_rd_sel;
    logic       any_rd_valid;

    logic [2:0] effective_sel;
    logic       nil_like_access;

    logic       transfer_done;
    logic       any_transfer_done;

    function automatic logic [2:0] next_dir(input logic [2:0] dir);
        begin
            unique case (dir)
                O_LEFT: begin
                    next_dir = O_RIGHT;
                end

                O_RIGHT: begin
                    next_dir = O_UP;
                end

                O_UP: begin
                    next_dir = O_DOWN;
                end

                O_DOWN: begin
                    next_dir = O_LEFT;
                end

                default: begin
                    next_dir = O_LEFT;
                end
            endcase
        end
    endfunction

    function automatic logic rx_valid_for(input logic [2:0] dir);
        begin
            unique case (dir)
                O_LEFT: begin
                    rx_valid_for = left_rx_valid;
                end

                O_RIGHT: begin
                    rx_valid_for = right_rx_valid;
                end

                O_UP: begin
                    rx_valid_for = up_rx_valid;
                end

                O_DOWN: begin
                    rx_valid_for = down_rx_valid;
                end

                default: begin
                    rx_valid_for = 1'b0;
                end
            endcase
        end
    endfunction

    always_comb begin
        any_rd_sel   = O_NIL;
        any_rd_valid = 1'b0;

        if (rx_valid_for(any_rd_probe_sel)) begin
            any_rd_sel   = any_rd_probe_sel;
            any_rd_valid = 1'b1;
        end else if (rx_valid_for(next_dir(any_rd_probe_sel))) begin
            any_rd_sel   = next_dir(any_rd_probe_sel);
            any_rd_valid = 1'b1;
        end else if (rx_valid_for(next_dir(next_dir(any_rd_probe_sel)))) begin
            any_rd_sel   = next_dir(next_dir(any_rd_probe_sel));
            any_rd_valid = 1'b1;
        end else if (rx_valid_for(next_dir(next_dir(next_dir(any_rd_probe_sel))))) begin
            any_rd_sel   = next_dir(next_dir(next_dir(any_rd_probe_sel)));
            any_rd_valid = 1'b1;
        end
    end

    always_comb begin
        if (port_sel == O_ANY) begin
            if (port_rd) begin
                effective_sel = any_rd_valid ? any_rd_sel : O_NIL;
            end else if (port_wr) begin
                effective_sel = any_wr_probe_sel;
            end else begin
                effective_sel = O_NIL;
            end
        end else if (port_sel == O_LAST) begin
            effective_sel = last_valid ? last_port : O_NIL;
        end else begin
            effective_sel = port_sel;
        end
    end

    assign nil_like_access = (port_sel == O_NIL) ||
                             (port_sel == O_LAST && !last_valid);

    always_comb begin
        port_ready = 1'b0;
        rd_data    = 11'sd0;

        left_rx_ready  = 1'b0;
        right_rx_ready = 1'b0;
        up_rx_ready    = 1'b0;
        down_rx_ready  = 1'b0;

        left_tx_valid  = 1'b0;
        right_tx_valid = 1'b0;
        up_tx_valid    = 1'b0;
        down_tx_valid  = 1'b0;

        left_tx_data  = wr_data;
        right_tx_data = wr_data;
        up_tx_data    = wr_data;
        down_tx_data  = wr_data;

        if (port_rd) begin
            if (nil_like_access) begin
                port_ready = 1'b1;
                rd_data    = 11'sd0;
            end else begin
                unique case (effective_sel)
                    O_LEFT: begin
                        port_ready    = left_rx_valid;
                        rd_data       = left_rx_data;
                        left_rx_ready = left_rx_valid;
                    end

                    O_RIGHT: begin
                        port_ready     = right_rx_valid;
                        rd_data        = right_rx_data;
                        right_rx_ready = right_rx_valid;
                    end

                    O_UP: begin
                        port_ready  = up_rx_valid;
                        rd_data     = up_rx_data;
                        up_rx_ready = up_rx_valid;
                    end

                    O_DOWN: begin
                        port_ready    = down_rx_valid;
                        rd_data       = down_rx_data;
                        down_rx_ready = down_rx_valid;
                    end

                    default: begin
                        port_ready = 1'b0;
                        rd_data    = 11'sd0;
                    end
                endcase
            end
        end else if (port_wr) begin
            if (nil_like_access) begin
                port_ready = 1'b1;
            end else begin
                unique case (effective_sel)
                    O_LEFT: begin
                        port_ready    = left_tx_ready;
                        left_tx_valid = 1'b1;
                    end

                    O_RIGHT: begin
                        port_ready     = right_tx_ready;
                        right_tx_valid = 1'b1;
                    end

                    O_UP: begin
                        port_ready  = up_tx_ready;
                        up_tx_valid = 1'b1;
                    end

                    O_DOWN: begin
                        port_ready    = down_tx_ready;
                        down_tx_valid = 1'b1;
                    end

                    default: begin
                        port_ready = 1'b0;
                    end
                endcase
            end
        end
    end

    assign transfer_done = (port_rd || port_wr) && port_ready;

    assign any_transfer_done = transfer_done &&
                               (port_sel == O_ANY) &&
                               (effective_sel != O_NIL);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            last_port        <= O_NIL;
            last_valid       <= 1'b0;
            any_wr_probe_sel <= O_LEFT;
            any_rd_probe_sel <= O_LEFT;
        end else begin
            if (any_transfer_done) begin
                last_port  <= effective_sel;
                last_valid <= 1'b1;

                if (port_rd) begin
                    any_rd_probe_sel <= next_dir(effective_sel);
                end
            end

            if (port_wr && port_sel == O_ANY && !port_ready) begin
                any_wr_probe_sel <= next_dir(any_wr_probe_sel);
            end else if (port_wr && port_sel == O_ANY && port_ready) begin
                any_wr_probe_sel <= next_dir(effective_sel);
            end
        end
    end
endmodule
