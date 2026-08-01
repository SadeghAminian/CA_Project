module control_unit (
    input  logic        clk,
    input  logic        rst,

    input  logic [23:0] instr,

    input  logic        port_ready,

    output logic        exec_en,
    output logic        latch_port_data,

    output logic        port_rd,
    output logic        port_wr,
    output logic [2:0]  port_sel
);
    import tis100_pkg::*;

    cu_state_t state;
    cu_state_t next_state;

    logic [3:0] opcode;
    logic       src_is_imm;
    logic [2:0] src_sel;
    logic [2:0] dst_sel;

    logic reads_src;
    logic writes_dst;
    logic src_port_read_needed;
    logic dst_port_write_needed;

    assign opcode     = instr[23:20];
    assign src_is_imm = instr[19];
    assign src_sel    = instr[18:16];
    assign dst_sel    = instr[15:13];

    always_comb begin
        unique case (opcode)
            OP_MOV,
            OP_ADD,
            OP_SUB,
            OP_JRO: begin
                reads_src = 1'b1;
            end

            default: begin
                reads_src = 1'b0;
            end
        endcase
    end

    always_comb begin
        unique case (opcode)
            OP_MOV: begin
                writes_dst = 1'b1;
            end

            default: begin
                writes_dst = 1'b0;
            end
        endcase
    end

    assign src_port_read_needed = reads_src &&
                                  !src_is_imm &&
                                  is_port_operand(src_sel) &&
                                  src_sel != O_ACC;

    assign dst_port_write_needed = writes_dst &&
                                   is_port_operand(dst_sel) &&
                                   dst_sel != O_ACC;

    always_comb begin
        exec_en         = 1'b0;
        latch_port_data = 1'b0;
        port_rd         = 1'b0;
        port_wr         = 1'b0;
        port_sel        = O_NIL;
        next_state      = state;

        unique case (state)
            ST_RUN: begin
                if (src_port_read_needed) begin
                    port_rd  = 1'b1;
                    port_sel = src_sel;

                    if (port_ready) begin
                        latch_port_data = 1'b1;

                        if (dst_port_write_needed) begin
                            next_state = ST_WR_WAIT;
                        end else begin
                            next_state = ST_EXEC_AFTER_RD;
                        end
                    end else begin
                        next_state = ST_RD_WAIT;
                    end
                end else if (dst_port_write_needed) begin
                    port_wr  = 1'b1;
                    port_sel = dst_sel;

                    if (port_ready) begin
                        exec_en    = 1'b1;
                        next_state = ST_RUN;
                    end else begin
                        next_state = ST_WR_WAIT;
                    end
                end else begin
                    exec_en    = 1'b1;
                    next_state = ST_RUN;
                end
            end

            ST_RD_WAIT: begin
                port_rd  = 1'b1;
                port_sel = src_sel;

                if (port_ready) begin
                    latch_port_data = 1'b1;

                    if (dst_port_write_needed) begin
                        next_state = ST_WR_WAIT;
                    end else begin
                        next_state = ST_EXEC_AFTER_RD;
                    end
                end else begin
                    next_state = ST_RD_WAIT;
                end
            end

            ST_EXEC_AFTER_RD: begin
                exec_en    = 1'b1;
                next_state = ST_RUN;
            end

            ST_WR_WAIT: begin
                port_wr  = 1'b1;
                port_sel = dst_sel;

                if (port_ready) begin
                    exec_en    = 1'b1;
                    next_state = ST_RUN;
                end else begin
                    next_state = ST_WR_WAIT;
                end
            end

            default: begin
                next_state = ST_RUN;
            end
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= ST_RUN;
        end else begin
            state <= next_state;
        end
    end
endmodule
