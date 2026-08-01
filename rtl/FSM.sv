module FSM (
    input logic clk, rst,

    input logic [11:0] instr,

    // input  logic port_src_valid, // داده در پورت مبدأ آماده خواندن است
    // input  logic port_dst_ready, // پورت مقصد آماده دریافت داده است
    
    // DataPath signals 
    output logic PCUpdate,
    output logic Branch,
    output logic PCSrc[1:0], 
    output logic IRWrite,
    output logic RegWrite,
    output logic sav_en,
    output logic swap_en,
    output logic [1:0]  ALUOp,          // PASS, ADD, SUB, NEG
    output logic [3:0] srcType

    // output logic en_src_ready,
    // output logic en_dst_valid
);
  
    localparam logic [3:0] NOP = 4'h0;
    localparam logic [3:0] MOV = 4'h1;
    localparam logic [3:0] SWP = 4'h2;
    localparam logic [3:0] SAV = 4'h3;
    localparam logic [3:0] ADD = 4'h4;
    localparam logic [3:0] SUB = 4'h5;
    localparam logic [3:0] NEG = 4'h6;

    localparam logic [3:0] ACC = 4'h0;
    localparam logic [3:0] NIL = 4'h1;
    localparam logic [3:0] IMM = 4'h8;

  typedef enum logic [2:0] {
        ST_FETCH     = 3'b000,
        ST_DECODE    = 3'b001,
        ST_WAIT_READ = 3'b010,
        ST_EXECUTE   = 3'b011,
        ST_WAIT_WRITE= 3'b100,
        ST_BRANCH    = 3'b101
    } state_t;

    state_t state, next_state;

    logic [3:0] opcode;
    logic [3:0] dst;
    logic [3:0] src_type;

    assign opcode   = instr[11:8];
    assign dst      = instr[7:4];
    assign src_type = instr[3:0];

    // internal Flags
    logic is_src_port;
    logic is_dst_port;
    logic is_branch;
    logic branch_src;
    logic branch_is_jro;

    always_comb begin
        is_src_port = (src_type >= 4'h2 && src_type <= 4'h7);
        is_dst_port = (dst >= 4'h2 && dst <= 4'h7);
        is_branch = (opcode >= 4'h7 && opcode <= 4'hC);
        branch_src = (src_type == 4'h8); // check if src is imm else is ACC
        branch_is_jro = (opcode == 4'hC);
    end

    // ==========================================
    //              State Transition
    // ==========================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= ST_FETCH;
        end else begin
            state <= next_state;
        end
    end

    // ==========================================
    //              Calculate next state
    // ==========================================
    always_comb begin
        next_state = state;
        
        case (state)
            ST_FETCH: begin
                next_state = ST_DECODE;
            end

            ST_DECODE: begin
                if(is_src_port) begin
                    next_state = ST_WAIT_READ;
                end
                else if(is_branch) begin
                    next_state = ST_BRANCH;
                end else begin
                    next_state = ST_EXECUTE;
                end
            end

            // ST_WAIT_READ: begin
            //     if(port_src_valid) begin
            //         if(is_dst_port) begin
            //             next_state = ST_WAIT_WRITE;
            //         end else begin
            //             next_state = ST_EXECUTE;
            //         end
            //     end
            // end
            
            ST_EXECUTE: begin
                next_state = ST_FETCH;
            end

            ST_BRANCH: begin
                next_state = ST_FETCH;
            end

            // ST_WAIT_WRITE:
            default: next_state = ST_FETCH;
        endcase
    end


    // ==========================================
    //              Output logic
    // ==========================================
    always_comb begin
        PCUpdate        = 1'b0;
        IRWrite        = 1'b0;
        PCSrc          = 2'b00; // پیش‌فرض: PC + 1
        RegWrite       = 1'b0;
        sav_en         = 1'b0;
        swap_en        = 1'b0;
        ALUOp          = 2'b00; // PASS
        Branch = 1'b0;
        // port_src_ready = 1'b0;
        // port_dst_valid = 1'b0;

        case (src_type)
            ACC: begin
                srcType = 4'b00;
            end
            NIL: begin
                srcType = 4'b01;
            end
            IMM: begin
                srcType = 4'b10;
            end
            default: srcType = 4'b11;
        endcase

        case (state)
            ST_FETCH: begin
                IRWrite = 1'b1;
                PCUpdate = 1'b1;
                PCSrc = 2'b00; // pc + 1 defualt
            end
            
            ST_DECODE: begin
                // nothing
            end

            ST_EXECUTE: begin
                case (opcode)
                    NOP: begin
                        // nothing
                    end

                    MOV: begin
                        ALUOp = 2'b00;
                        RegWrite = (dst == NIL || dst == ACC);
                    end

                    SWP: begin
                        swap_en = 1'b1;
                    end

                    SAV: begin
                        sav_en = 1'b1;
                    end

                    ADD: begin
                        ALUOp = 2'b01;
                        RegWrite = 1'b1; // بررسی کن در اسمبلر برای دستورات جمع و تفریق مقصد درست تعریف شده!
                    end

                    SUB: begin
                        ALUOp = 2'b10;
                        RegWrite = 1'b1;
                    end

                    NEG: begin
                        ALUOp = 2'b11;
                        RegWrite = 1'b1;
                    end

                    default: begin
                    end
                endcase
            end

            // ST_WAIT_READ:
            // ST_WAIT_WRITE= 3'b100,
            ST_BRANCH: begin
                Branch = 1'b1;
                PCSrc = {branch_is_jro,branch_src};
            end

            default: ;
        endcase
    end
    
endmodule