module datapath (
    input  logic        clk, rst,
    
    // --- سیگنال‌های کنترلی جدید از control_unit ---
    input  logic        acc_wr,
    input  logic        bak_wr,
    input  logic        swp_en,
    
    // از control_unit
    input  logic [3:0]  opcode,
    input  logic [3:0]  dst,
    input  logic [3:0]  src_type,
    input  logic [11:0] src_val,
    // از port_interface
    input  logic [10:0] port_rd_data,
    // خروجی به port_interface
    output logic [10:0] port_wr_data,
    // خروجی به control_unit (برای branch و JRO)
    output logic [10:0] acc_out,
    output logic [3:0]  jro_target,   // PC + offset برای JRO
    input  logic [3:0]  pc_in,
    output logic        branch_taken
);

    // ── رجیسترها ──────────────────────────────────────────────
    logic signed [10:0] ACC, BAK;

    // ── sign-extend src_val (12-bit two's complement → 11-bit) ─
    // src_val[11] = نوع src: 0=immediate, 1=port/ACC/NIL
    // طبق ISA: [15:12]=SrcType, [11:0]=SrcVal
    // SrcType: 0=NIL,1=ACC,2=BAK,3=IMM,4=LEFT,5=RIGHT,6=UP,7=DOWN,8=ANY,9=LAST
    logic signed [10:0] src_data;
    always_comb begin
        case (src_type)
            4'd1:    src_data = ACC;
            4'd2:    src_data = BAK;
            4'd3:    src_data = {{1{src_val[10]}}, src_val[10:0]};  // sign-extend 11-bit imm
            4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9:
                     src_data = port_rd_data;
            default: src_data = 11'd0;  // NIL
        endcase
    end

    // ── Opcodes (باید با assembler هماهنگ باشد) ───────────────
    // 0=NOP,1=MOV,2=SWP,3=SAV,4=ADD,5=SUB,6=NEG,
    // 7=JMP,8=JEZ,9=JNZ,10=JGZ,11=JLZ,12=JRO

    // ── ALU + رجیستر ──────────────────────────────────────────
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ACC <= 11'd0;
            BAK <= 11'd0;
        end else begin
            // مدیریت دستور SWP
            if (swp_en) begin
                ACC <= BAK;
                BAK <= ACC;
            end else begin
                // مدیریت دستور SAV
                if (bak_wr) begin
                    BAK <= ACC;
                end
                
                // مدیریت دستوراتی که روی ACC می‌نویسند
                if (acc_wr) begin
                    case (opcode)
                        4'd1: begin  // MOV src, dst
                            if (dst == 4'd1) ACC <= src_data;
                        end
                        4'd4: ACC <= ACC + src_data;               // ADD
                        4'd5: ACC <= ACC - src_data;               // SUB
                        4'd6: ACC <= -ACC;                         // NEG
                        default: ;  // سایر موارد تغییری در ACC ایجاد نمی‌کنند
                    endcase
                end
            end
        end
    end

    // ── خروجی‌های ترکیبی ──────────────────────────────────────
    assign acc_out      = ACC;
    assign port_wr_data = ACC;  // MOV ACC, <port> همیشه ACC را می‌فرستد

    // ── Branch logic (ترکیبی، برای control_unit) ──────────────
    always_comb begin
        branch_taken = 1'b0;
        case (opcode)
            4'd7:  branch_taken = 1'b1;                    // JMP
            4'd8:  branch_taken = (ACC == 11'd0);          // JEZ
            4'd9:  branch_taken = (ACC != 11'd0);          // JNZ
            4'd10: branch_taken = ($signed(ACC) > 0);      // JGZ
            4'd11: branch_taken = ($signed(ACC) < 0);      // JLZ
            4'd12: branch_taken = 1'b1;                    // JRO
            default: branch_taken = 1'b0;
        endcase
    end

    // ── JRO: PC + offset (ترکیبی) ─────────────────────────────
    assign jro_target = pc_in + src_val[3:0];  // offset 4-bit کافی است (PC=4bit)

endmodule