// control_unit.sv
// اصلاح شده برای پردازنده TIS-100

module control_unit (
    input  logic        clk, rst,
    input  logic [23:0] instr,
    input  logic [10:0] acc,        // signed 11-bit (-999..999)
    input logic [3:0] jro_target, // نیاز به PC فعلی برای JRO
    input  logic        port_ready, // تکمیل هندشیک از port_interface
    output logic        pc_load,
    output logic [3:0]  pc_next,
    output logic        pc_inc,
    output logic        acc_wr,
    output logic        bak_wr,
    output logic        swp_en,
    output logic        port_rd,
    output logic        port_wr,
    output logic [2:0]  port_sel,   
    output logic        stall
);

    // --- Opcode decode ---
    typedef enum logic [3:0] {
        OP_NOP = 4'h0, OP_MOV = 4'h1, OP_ADD = 4'h2, OP_SUB = 4'h3,
        OP_NEG = 4'h4, OP_SAV = 4'h5, OP_SWP = 4'h6, OP_JMP = 4'h7,
        OP_JEZ = 4'h8, OP_JNZ = 4'h9, OP_JGZ = 4'hA, OP_JLZ = 4'hB,
        OP_JRO = 4'hC
    } opcode_t;

    // SrcType / DstType encoding (باید با دیتاپث یکی باشد)
    localparam logic [3:0] T_ACC  = 4'h0, T_NIL  = 4'h1, T_LEFT = 4'h2,
                           T_RIGHT= 4'h3, T_UP   = 4'h4, T_DOWN = 4'h5,
                           T_ANY  = 4'h6, T_LAST = 4'h7, T_IMM  = 4'h8;

    opcode_t     opcode;
    logic [3:0]  dst_type, src_type;
    logic [11:0] src_val;

    assign opcode   = opcode_t'(instr[23:20]);
    assign dst_type = instr[19:16];
    assign src_type = instr[15:12];
    assign src_val  = instr[11:0];

    // --- FSM States ---
    typedef enum logic [2:0] {
        IDLE    = 3'd0,
        EXECUTE = 3'd1,
        RD_WAIT = 3'd2,   // انتظار برای خواندن از پورت
        WR_WAIT = 3'd3    // انتظار برای نوشتن در پورت
    } state_t;

    state_t state, next_state;

    logic src_is_port, dst_is_port;
    assign src_is_port = (src_type >= T_LEFT && src_type <= T_LAST);
    assign dst_is_port = (dst_type >= T_LEFT && dst_type <= T_LAST);

    // --- Branch Logic ---
    logic branch_taken;
    always_comb begin
        case (opcode)
            OP_JMP: branch_taken = 1'b1;
            OP_JEZ: branch_taken = (acc == 11'd0);
            OP_JNZ: branch_taken = (acc != 11'd0);
            OP_JGZ: branch_taken = ($signed(acc) > 0);
            OP_JLZ: branch_taken = ($signed(acc) < 0);
            default: branch_taken = 1'b0;
        endcase
    end

    // --- State Register ---
    always_ff @(posedge clk or posedge rst)
        state <= rst ? IDLE : next_state;

    // --- Next State Logic ---
    always_comb begin
        next_state = state;
        case (state)
            IDLE:    next_state = EXECUTE;
            EXECUTE: begin
                if (opcode == OP_MOV) begin
                    if (src_is_port) next_state = RD_WAIT;
                    else if (dst_is_port) next_state = WR_WAIT;
                    else next_state = IDLE;
                end else if ((opcode == OP_ADD || opcode == OP_SUB) && src_is_port)
                    next_state = RD_WAIT;
                else
                    next_state = IDLE;
            end
            RD_WAIT: begin
                // اگر بعد از خواندن باید در پورت بنویسیم (MOV port, port)
                if (port_ready)
                    next_state = (opcode == OP_MOV && dst_is_port) ? WR_WAIT : IDLE;
                else
                    next_state = RD_WAIT;
            end
            WR_WAIT: next_state = port_ready ? IDLE : WR_WAIT;
            default: next_state = IDLE;
        endcase
    end

    // --- Output Logic ---
    always_comb begin
        pc_load = 1'b0; pc_next = 4'h0; pc_inc = 1'b0;
        acc_wr = 1'b0; bak_wr = 1'b0; swp_en = 1'b1; // SWP is usually pulse
        port_rd = 1'b0; port_wr = 1'b0; port_sel = 3'd0;
        stall = 1'b0;
        swp_en = 1'b0;

        case (state)
            EXECUTE: begin
                case (opcode)
                    OP_MOV: begin
                        if (src_is_port) begin
                            port_rd = 1'b1;
                            port_sel = src_type[2:0];
                        end else if (dst_is_port) begin
                            port_wr = 1'b1;
                            port_sel = dst_type[2:0];
                        end else begin
                            acc_wr = (dst_type == T_ACC);
                            pc_inc = 1'b1;
                        end
                    end
                    OP_ADD, OP_SUB: begin
                        if (src_is_port) begin
                            port_rd = 1'b1;
                            port_sel = src_type[2:0];
                        end else begin
                            acc_wr = 1'b1;
                            pc_inc = 1'b1;
                        end
                    end
                    OP_NEG: begin acc_wr = 1'b1; pc_inc = 1'b1; end
                    OP_SAV: begin bak_wr = 1'b1; pc_inc = 1'b1; end
                    OP_SWP: begin swp_en = 1'b1; pc_inc = 1'b1; end
                    OP_JMP, OP_JEZ, OP_JNZ, OP_JGZ, OP_JLZ: begin
                        if (branch_taken) begin
                            pc_load = 1'b1;
                            pc_next = src_val[3:0];
                        end else pc_inc = 1'b1;
                    end
                    OP_JRO: begin
                        pc_load = 1'b1;
                        
                        pc_next = jro_target;
                    end
                    default: pc_inc = 1'b1; // NOP
                endcase
            end

            RD_WAIT: begin
                stall = 1'b1;
                port_rd = 1'b1;
                port_sel = src_type[2:0];
                if (port_ready) begin
                    if (opcode == OP_MOV && !dst_is_port) begin
                        acc_wr = (dst_type == T_ACC);
                        pc_inc = 1'b1;
                    end else if (opcode == OP_ADD || opcode == OP_SUB) begin
                        acc_wr = 1'b1;
                        pc_inc = 1'b1;
                    end
                end
            end

            WR_WAIT: begin
                stall = 1'b1;
                port_wr = 1'b1;
                port_sel = dst_type[2:0];
                if (port_ready) pc_inc = 1'b1;
            end
        endcase
    end
endmodule
