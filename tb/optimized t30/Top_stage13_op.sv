module Top_stage13 (
    input  logic        clk,
    input  logic        rst,
    // Input Stream
    input  logic signed [23:0] in_data,
    input  logic               in_valid,
    output logic               in_ready,
    // Output Stream
    output logic signed [23:0] out_data,
    output logic               out_valid,
    input  logic               out_ready
);

    // ==========================================
    // Shared Data Lines (t12Node: single data_out)
    // ==========================================
    logic signed [23:0] n12_data, n22_data, n23_data, n33_data;

    // T30 Data Lines (single data_out per node)
    logic signed [23:0] n13_data, n32_data;

    // ==========================================
    // Handshake Signals
    // ==========================================
    
    // External IO
    logic n12_u_ready_out;
    logic n33_d_valid;
    logic n33_d_ready;

    // N12.RIGHT <-> N13.LEFT
    logic n12_r_valid, n12_r_ready;
    logic n13_l_valid, n13_l_ready;

    // N12.DOWN <-> N22.UP
    logic n12_d_valid, n12_d_ready;
    logic n22_u_valid, n22_u_ready;

    // N13.DOWN <-> N23.UP
    logic n13_d_valid, n13_d_ready;
    logic n23_u_valid, n23_u_ready;

    // N22.RIGHT <-> N23.LEFT
    logic n22_r_valid, n22_r_ready;
    logic n23_l_valid, n23_l_ready;

    // N22.DOWN <-> N32.UP
    logic n22_d_valid, n22_d_ready;
    logic n32_u_valid, n32_u_ready;

    // N23.DOWN <-> N33.UP
    logic n23_d_valid, n23_d_ready;
    logic n33_u_valid, n33_u_ready;

    // N32.RIGHT <-> N33.LEFT
    logic n32_r_valid, n32_r_ready;
    logic n33_l_valid, n33_l_ready;

    // ==========================================
    // External IO Mapping
    // ==========================================
    assign in_ready   = n12_u_ready_out;
    assign out_data   = n33_data;
    assign out_valid  = n33_d_valid;
    assign n33_d_ready = out_ready;

    // ==========================================
    // N12: T12 Node
    // UP=IN, RIGHT<->N13, DOWN<->N22, LEFT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level13_op/node12.hex") ) u_n12 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n12_data),
        // UP: IN
        .up_data_in(in_data), .up_valid_in(in_valid), .up_ready_in(1'b1),
        .up_valid_out(), .up_ready_out(n12_u_ready_out),
        // RIGHT: <-> N13.LEFT
        .right_data_in(n13_data), .right_valid_in(n13_l_valid), .right_ready_in(n13_l_ready),
        .right_valid_out(n12_r_valid), .right_ready_out(n12_r_ready),
        // DOWN: <-> N22.UP
        .down_data_in(n22_data), .down_valid_in(n22_u_valid), .down_ready_in(n22_u_ready),
        .down_valid_out(n12_d_valid), .down_ready_out(n12_d_ready),
        // LEFT: Unused
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out()
    );

    // ==========================================
    // N13: T30 Stack Node (NEW PORT NAMES)
    // LEFT<->N12.RIGHT, DOWN<->N23.UP, RIGHT=free, UP=free
    // ==========================================
    t30Node u_n13 (
        .clk(clk), .rst(rst),
        // LEFT: <-> N12.RIGHT
        .left_data_in(n12_data), .left_valid_in(n12_r_valid), .left_ready_in(n12_r_ready),
        .left_ready_out(n13_l_ready), .left_valid_out(n13_l_valid),
        // DOWN: <-> N23.UP
        .down_data_in(n23_data), .down_valid_in(n23_u_valid), .down_ready_in(n23_u_ready),
        .down_ready_out(n13_d_ready), .down_valid_out(n13_d_valid),
        // RIGHT: Unused (FIXED: ready_in=0)
        .right_data_in(24'sd0), .right_valid_in(1'b0), .right_ready_in(1'b0),
        .right_ready_out(), .right_valid_out(),
        // UP: Unused (FIXED: ready_in=0)
        .up_data_in(24'sd0), .up_valid_in(1'b0), .up_ready_in(1'b0),
        .up_ready_out(), .up_valid_out(),
        // Single data_out
        .data_out(n13_data)
    );

    // ==========================================
    // N22: T12 Node
    // UP<->N12.DOWN, RIGHT<->N23.LEFT, DOWN<->N32.UP, LEFT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level13_op/node22.hex") ) u_n22 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n22_data),
        // UP: <-> N12.DOWN
        .up_data_in(n12_data), .up_valid_in(n12_d_valid), .up_ready_in(n12_d_ready),
        .up_valid_out(n22_u_valid), .up_ready_out(n22_u_ready),
        // RIGHT: <-> N23.LEFT
        .right_data_in(n23_data), .right_valid_in(n23_l_valid), .right_ready_in(n23_l_ready),
        .right_valid_out(n22_r_valid), .right_ready_out(n22_r_ready),
        // DOWN: <-> N32.UP
        .down_data_in(n32_data), .down_valid_in(n32_u_valid), .down_ready_in(n32_u_ready),
        .down_valid_out(n22_d_valid), .down_ready_out(n22_d_ready),
        // LEFT: Unused
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out()
    );

    // ==========================================
    // N23: T12 Node
    // UP<->N13.DOWN, LEFT<->N22.RIGHT, DOWN<->N33.UP, RIGHT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level13_op/node23.hex") ) u_n23 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n23_data),
        // UP: <-> N13.DOWN
        .up_data_in(n13_data), .up_valid_in(n13_d_valid), .up_ready_in(n13_d_ready),
        .up_valid_out(n23_u_valid), .up_ready_out(n23_u_ready),
        // LEFT: <-> N22.RIGHT
        .left_data_in(n22_data), .left_valid_in(n22_r_valid), .left_ready_in(n22_r_ready),
        .left_valid_out(n23_l_valid), .left_ready_out(n23_l_ready),
        // DOWN: <-> N33.UP
        .down_data_in(n33_data), .down_valid_in(n33_u_valid), .down_ready_in(n33_u_ready),
        .down_valid_out(n23_d_valid), .down_ready_out(n23_d_ready),
        // RIGHT: Unused
        .right_data_in(24'sd0), .right_valid_in(1'b0), .right_ready_in(1'b0),
        .right_valid_out(), .right_ready_out()
    );

    // ==========================================
    // N32: T30 Stack Node (NEW PORT NAMES)
    // UP<->N22.DOWN, RIGHT<->N33.LEFT, LEFT=free, DOWN=free
    // ==========================================
    t30Node u_n32 (
        .clk(clk), .rst(rst),
        // UP: <-> N22.DOWN
        .up_data_in(n22_data), .up_valid_in(n22_d_valid), .up_ready_in(n22_d_ready),
        .up_ready_out(n32_u_ready), .up_valid_out(n32_u_valid),
        // RIGHT: <-> N33.LEFT
        .right_data_in(n33_data), .right_valid_in(n33_l_valid), .right_ready_in(n33_l_ready),
        .right_ready_out(n32_r_ready), .right_valid_out(n32_r_valid),
        // LEFT: Unused (FIXED: ready_in=0)
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_ready_out(), .left_valid_out(),
        // DOWN: Unused (FIXED: ready_in=0)
        .down_data_in(24'sd0), .down_valid_in(1'b0), .down_ready_in(1'b0),
        .down_ready_out(), .down_valid_out(),
        // Single data_out
        .data_out(n32_data)
    );

    // ==========================================
    // N33: T12 Node
    // UP<->N23.DOWN, LEFT<->N32.RIGHT, DOWN=OUT, RIGHT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level13_op/node33.hex") ) u_n33 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n33_data),
        // UP: <-> N23.DOWN
        .up_data_in(n23_data), .up_valid_in(n23_d_valid), .up_ready_in(n23_d_ready),
        .up_valid_out(n33_u_valid), .up_ready_out(n33_u_ready),
        // LEFT: <-> N32.RIGHT
        .left_data_in(n32_data), .left_valid_in(n32_r_valid), .left_ready_in(n32_r_ready),
        .left_valid_out(n33_l_valid), .left_ready_out(n33_l_ready),
        // DOWN: OUT
        .down_data_in(24'sd0), .down_valid_in(1'b0), .down_ready_in(n33_d_ready),
        .down_valid_out(n33_d_valid), .down_ready_out(),
        // RIGHT: Unused
        .right_data_in(24'sd0), .right_valid_in(1'b0), .right_ready_in(1'b0),
        .right_valid_out(), .right_ready_out()
    );

endmodule