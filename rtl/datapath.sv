module datapath #(
    parameter integer PROGRAM_SIZE = 16
) (
    input  logic        clk,
    input  logic        rst,

    input  logic [23:0] instr,

    input  logic        exec_en,
    input  logic        latch_port_data,

    input  logic signed [10:0] port_rd_data,
    output logic signed [10:0] port_wr_data,

    output logic [3:0]  pc,
    output logic signed [10:0] acc_out
);
    import tis100_pkg::*;

    logic signed [10:0] acc;
    logic signed [10:0] bak;
    logic signed [10:0] port_rd_reg;

    logic [3:0] opcode;
    logic       src_is_imm;
    logic [2:0] src_sel;
    logic [2:0] dst_sel;
    logic signed [10:0] imm;

    integer max_pc;
    integer temp_int;

    assign opcode     = instr[23:20];
    assign src_is_imm = instr[19];
    assign src_sel    = instr[18:16];
    assign dst_sel    = instr[15:13];
    assign imm        = instr[10:0];

    assign acc_out = acc;

    function automatic signed [10:0] operand_value(input logic [2:0] sel);
        begin
            case (sel)
                O_ACC:   operand_value = acc;
                O_NIL:   operand_value = 11'sd0;
                O_LEFT:  operand_value = port_rd_reg;
                O_RIGHT: operand_value = port_rd_reg;
                O_UP:    operand_value = port_rd_reg;
                O_DOWN:  operand_value = port_rd_reg;
                O_ANY:   operand_value = port_rd_reg;
                O_LAST:  operand_value = port_rd_reg;
                default: operand_value = 11'sd0;
            endcase
        end
    endfunction

    function automatic signed [10:0] src_value;
        begin
            if (src_is_imm)
                src_value = imm;
            else
                src_value = operand_value(src_sel);
        end
    endfunction

    function automatic [3:0] clamp_pc_abs(input integer value);
        integer local_max;
        begin
            local_max = PROGRAM_SIZE - 1;
            if (local_max > 15)
                local_max = 15;
            if (local_max < 0)
                local_max = 0;

            if (value < 0)
                clamp_pc_abs = 4'd0;
            else if (value > local_max)
                clamp_pc_abs = local_max[3:0];
            else
                clamp_pc_abs = value[3:0];
        end
    endfunction

    function automatic [3:0] next_pc;
        integer local_max;
        begin
            local_max = PROGRAM_SIZE - 1;
            if (local_max > 15)
                local_max = 15;
            if (local_max < 0)
                local_max = 0;

            if (pc >= local_max[3:0])
                next_pc = 4'd0;
            else
                next_pc = pc + 4'd1;
        end
    endfunction

    assign port_wr_data = src_value;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            acc         <= 11'sd0;
            bak         <= 11'sd0;
            port_rd_reg <= 11'sd0;
            pc          <= 4'd0;
        end else begin
            if (latch_port_data)
                port_rd_reg <= port_rd_data;

            if (exec_en) begin
                case (opcode)
                    OP_NOP: begin
                        pc <= next_pc;
                    end

                    OP_MOV: begin
                        if (dst_sel == O_ACC)
                            acc <= src_value;
                        pc <= next_pc;
                    end

                    OP_ADD: begin
                        acc <= sat11(acc + src_value);
                        pc  <= next_pc;
                    end

                    OP_SUB: begin
                        acc <= sat11(acc - src_value);
                        pc  <= next_pc;
                    end

                    OP_NEG: begin
                        acc <= sat11(-acc);
                        pc  <= next_pc;
                    end

                    OP_SAV: begin
                        bak <= acc;
                        pc  <= next_pc;
                    end

                    OP_SWP: begin
                        acc <= bak;
                        bak <= acc;
                        pc  <= next_pc;
                    end

                    OP_JMP: begin
                        pc <= clamp_pc_abs(imm);
                    end

                    OP_JEZ: begin
                        if (acc == 0)
                            pc <= clamp_pc_abs(imm);
                        else
                            pc <= next_pc;
                    end

                    OP_JNZ: begin
                        if (acc != 0)
                            pc <= clamp_pc_abs(imm);
                        else
                            pc <= next_pc;
                    end

                    OP_JGZ: begin
                        if (acc > 0)
                            pc <= clamp_pc_abs(imm);
                        else
                            pc <= next_pc;
                    end

                    OP_JLZ: begin
                        if (acc < 0)
                            pc <= clamp_pc_abs(imm);
                        else
                            pc <= next_pc;
                    end

                    OP_JRO: begin
                        temp_int = pc + src_value;
                        pc <= clamp_pc_abs(temp_int);
                    end

                    default: begin
                        pc <= next_pc;
                    end
                endcase
            end
        end
    end
endmodule
