package tis100_pkg;
    typedef enum logic [3:0] {
        OP_NOP = 4'd0,
        OP_MOV = 4'd1,
        OP_ADD = 4'd2,
        OP_SUB = 4'd3,
        OP_NEG = 4'd4,
        OP_SAV = 4'd5,
        OP_SWP = 4'd6,
        OP_JMP = 4'd7,
        OP_JEZ = 4'd8,
        OP_JNZ = 4'd9,
        OP_JGZ = 4'd10,
        OP_JLZ = 4'd11,
        OP_JRO = 4'd12
    } opcode_t;

    typedef enum logic [2:0] {
        O_NIL   = 3'd0,
        O_ACC   = 3'd1,
        O_LEFT  = 3'd2,
        O_RIGHT = 3'd3,
        O_UP    = 3'd4,
        O_DOWN  = 3'd5,
        O_ANY   = 3'd6,
        O_LAST  = 3'd7
    } operand_t;

    typedef enum logic [1:0] {
        ST_RUN           = 2'd0,
        ST_RD_WAIT       = 2'd1,
        ST_EXEC_AFTER_RD = 2'd2,
        ST_WR_WAIT       = 2'd3
    } cu_state_t;

    function automatic logic is_port_operand(input logic [2:0] op);
        begin
            is_port_operand = (op == O_LEFT)  ||
                              (op == O_RIGHT) ||
                              (op == O_UP)    ||
                              (op == O_DOWN)  ||
                              (op == O_ANY)   ||
                              (op == O_LAST);
        end
    endfunction

    function automatic signed [10:0] sat11(input integer value);
        begin
            if (value > 999)
                sat11 = 11'sd999;
            else if (value < -999)
                sat11 = -11'sd999;
            else
                sat11 = value[10:0];
        end
    endfunction
endpackage
