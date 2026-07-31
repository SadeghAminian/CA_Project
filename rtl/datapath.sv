// datapath.sv

module datapath (
    input  logic        clk,
    input  logic        rst,

    input  logic        acc_wr,
    input  logic        bak_wr,
    input  logic        swp_en,

    input  logic [3:0]  opcode,
    input  logic [3:0]  dst,
    input  logic [3:0]  src_type,
    input  logic [11:0] src_val,

    input  logic [10:0] port_rd_data,

    output logic [10:0] port_wr_data,

    output logic [10:0] acc_out,
    output logic [3:0]  jro_target,
    input  logic [3:0]  pc_in,
    output logic        branch_taken
);

    localparam logic [3:0] OP_NOP = 4'h0;
    localparam logic [3:0] OP_MOV = 4'h1;
    localparam logic [3:0] OP_ADD = 4'h2;
    localparam logic [3:0] OP_SUB = 4'h3;
    localparam logic [3:0] OP_NEG = 4'h4;
    localparam logic [3:0] OP_SAV = 4'h5;
    localparam logic [3:0] OP_SWP = 4'h6;
    localparam logic [3:0] OP_JMP = 4'h7;
    localparam logic [3:0] OP_JEZ = 4'h8;
    localparam logic [3:0] OP_JNZ = 4'h9;
    localparam logic [3:0] OP_JGZ = 4'hA;
    localparam logic [3:0] OP_JLZ = 4'hB;
    localparam logic [3:0] OP_JRO = 4'hC;

    localparam logic [3:0] T_ACC   = 4'h0;
    localparam logic [3:0] T_NIL   = 4'h1;
    localparam logic [3:0] T_LEFT  = 4'h2;
    localparam logic [3:0] T_RIGHT = 4'h3;
    localparam logic [3:0] T_UP    = 4'h4;
    localparam logic [3:0] T_DOWN  = 4'h5;
    localparam logic [3:0] T_ANY   = 4'h6;
    localparam logic [3:0] T_LAST  = 4'h7;
    localparam logic [3:0] T_IMM   = 4'h8;

    logic signed [10:0] ACC;
    logic signed [10:0] BAK;

    logic signed [10:0] src_data;
    logic signed [11:0] imm12_signed;
    logic signed [11:0] alu_result_raw;
    logic signed [10:0] alu_result_sat;
    logic signed [4:0]  jro_offset;

    assign imm12_signed = $signed(src_val);

    always_comb begin
        case (src_type)
            T_ACC:   src_data = ACC;
            T_NIL:   src_data = 11'sd0;
            T_LEFT,
            T_RIGHT,
            T_UP,
            T_DOWN,
            T_ANY,
            T_LAST:  src_data = $signed(port_rd_data);
            T_IMM: begin
                if (imm12_signed > 12'sd999)
                    src_data = 11'sd999;
                else if (imm12_signed < -12'sd999)
                    src_data = -11'sd999;
                else
                    src_data = imm12_signed[10:0];
            end
            default: src_data = 11'sd0;
        endcase
    end

    always_comb begin
        alu_result_raw = 12'sd0;

        case (opcode)
            OP_ADD: alu_result_raw = $signed({ACC[10], ACC}) + $signed({src_data[10], src_data});
            OP_SUB: alu_result_raw = $signed({ACC[10], ACC}) - $signed({src_data[10], src_data});
            OP_NEG: alu_result_raw = -$signed({ACC[10], ACC});
            default: alu_result_raw = $signed({src_data[10], src_data});
        endcase

        if (alu_result_raw > 12'sd999)
            alu_result_sat = 11'sd999;
        else if (alu_result_raw < -12'sd999)
            alu_result_sat = -11'sd999;
        else
            alu_result_sat = alu_result_raw[10:0];
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ACC <= 11'sd0;
            BAK <= 11'sd0;
        end else begin
            if (swp_en) begin
                ACC <= BAK;
                BAK <= ACC;
            end else begin
                if (bak_wr)
                    BAK <= ACC;

                if (acc_wr) begin
                    case (opcode)
                        OP_MOV: begin
                            if (dst == T_ACC)
                                ACC <= src_data;
                        end

                        OP_ADD,
                        OP_SUB,
                        OP_NEG: begin
                            ACC <= alu_result_sat;
                        end

                        default: begin
                            ACC <= ACC;
                        end
                    endcase
                end
            end
        end
    end

    assign acc_out = ACC;

    always_comb begin
        case (src_type)
            T_ACC:   port_wr_data = ACC;
            T_NIL:   port_wr_data = 11'sd0;
            T_IMM:   port_wr_data = src_data;
            default: port_wr_data = src_data;
        endcase
    end

    always_comb begin
        case (opcode)
            OP_JMP: branch_taken = 1'b1;
            OP_JEZ: branch_taken = (ACC == 11'sd0);
            OP_JNZ: branch_taken = (ACC != 11'sd0);
            OP_JGZ: branch_taken = (ACC > 11'sd0);
            OP_JLZ: branch_taken = (ACC < 11'sd0);
            OP_JRO: branch_taken = 1'b1;
            default: branch_taken = 1'b0;
        endcase
    end

    always_comb begin
        if (src_type == T_IMM)
            jro_offset = src_val[4:0];
        else
            jro_offset = src_data[4:0];

        jro_target = pc_in + jro_offset[3:0];
    end

endmodule
