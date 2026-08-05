//signal divider solution
module Top_stage19 (
    input  logic        clk,
    input  logic        rst,
    // Input A Stream
    input  logic signed [23:0] in_a_data,
    input  logic               in_a_valid,
    output logic               in_a_ready,
    // Input B Stream
    input  logic signed [23:0] in_b_data,
    input  logic               in_b_valid,
    output logic               in_b_ready,
    // Output Q Stream
    output logic signed [23:0] out_q_data,
    output logic               out_q_valid,
    input  logic               out_q_ready,
    // Output R Stream
    output logic signed [23:0] out_r_data,
    output logic               out_r_valid,
    input  logic               out_r_ready
);

    // ==========================================
    // Shared Data Lines (t12Node: single data_out)
    // ==========================================
    logic signed [23:0] n12_data, n13_data;
    logic signed [23:0] n22_data, n32_data, n33_data;

    // ==========================================
    // Handshake Signals
    // ==========================================
    
    // External IO Ready Outs (FIXED: connected to node's ready_out)
    logic n12_u_ready_out;
    logic n13_u_ready_out;
    
    // External IO Valid/Ready for Outputs
    logic n32_d_valid, n32_d_ready;
    logic n33_d_valid, n33_d_ready;

    // N12.RIGHT <-> N13.LEFT
    logic n12_r_valid, n12_r_ready;
    logic n13_l_valid, n13_l_ready;

    // N12.DOWN <-> N22.UP
    logic n12_d_valid, n12_d_ready;
    logic n22_u_valid, n22_u_ready;

    // N22.DOWN <-> N32.UP
    logic n22_d_valid, n22_d_ready;
    logic n32_u_valid, n32_u_ready;

    // N32.RIGHT <-> N33.LEFT
    logic n32_r_valid, n32_r_ready;
    logic n33_l_valid, n33_l_ready;

    // ==========================================
    // External IO Mapping
    // ==========================================
    assign in_a_ready  = n12_u_ready_out;
    assign in_b_ready  = n13_u_ready_out;
    
    assign out_q_data  = n32_data;
    assign out_q_valid = n32_d_valid;
    assign n32_d_ready = out_q_ready;
    
    assign out_r_data  = n33_data;
    assign out_r_valid = n33_d_valid;
    assign n33_d_ready = out_r_ready;

    // ==========================================
    // N12: T12 Node
    // UP=IN.A, RIGHT<->N13, DOWN<->N22, LEFT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level19/node12.hex") ) u_n12 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n12_data),
        // UP: IN.A (FIXED: ready_in=1, ready_out -> in_a_ready)
        .up_data_in(in_a_data), .up_valid_in(in_a_valid), .up_ready_in(1'b1),
        .up_valid_out(), .up_ready_out(n12_u_ready_out),
        // RIGHT: <-> N13.LEFT
        .right_data_in(n13_data), .right_valid_in(n13_l_valid), .right_ready_in(n13_l_ready),
        .right_valid_out(n12_r_valid), .right_ready_out(n12_r_ready),
        // DOWN: <-> N22.UP
        .down_data_in(n22_data), .down_valid_in(n22_u_valid), .down_ready_in(n22_u_ready),
        .down_valid_out(n12_d_valid), .down_ready_out(n12_d_ready),
        // LEFT: Unused (FIXED: ready_in=0)
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out()
    );

    // ==========================================
    // N13: T12 Node
    // UP=IN.B, LEFT<->N12, RIGHT=free, DOWN=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level19/node13.hex") ) u_n13 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n13_data),
        // UP: IN.B (FIXED: ready_in=1, ready_out -> in_b_ready)
        .up_data_in(in_b_data), .up_valid_in(in_b_valid), .up_ready_in(1'b1),
        .up_valid_out(), .up_ready_out(n13_u_ready_out),
        // LEFT: <-> N12.RIGHT
        .left_data_in(n12_data), .left_valid_in(n12_r_valid), .left_ready_in(n12_r_ready),
        .left_valid_out(n13_l_valid), .left_ready_out(n13_l_ready),
        // RIGHT: Unused (FIXED: ready_in=0)
        .right_data_in(24'sd0), .right_valid_in(1'b0), .right_ready_in(1'b0),
        .right_valid_out(), .right_ready_out(),
        // DOWN: Unused (FIXED: ready_in=0)
        .down_data_in(24'sd0), .down_valid_in(1'b0), .down_ready_in(1'b0),
        .down_valid_out(), .down_ready_out()
    );

    // ==========================================
    // N22: T12 Node
    // UP<->N12, DOWN<->N32, LEFT=free, RIGHT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level19/node22.hex") ) u_n22 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n22_data),
        // UP: <-> N12.DOWN
        .up_data_in(n12_data), .up_valid_in(n12_d_valid), .up_ready_in(n12_d_ready),
        .up_valid_out(n22_u_valid), .up_ready_out(n22_u_ready),
        // DOWN: <-> N32.UP
        .down_data_in(n32_data), .down_valid_in(n32_u_valid), .down_ready_in(n32_u_ready),
        .down_valid_out(n22_d_valid), .down_ready_out(n22_d_ready),
        // LEFT: Unused (FIXED: ready_in=0)
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out(),
        // RIGHT: Unused (FIXED: ready_in=0)
        .right_data_in(24'sd0), .right_valid_in(1'b0), .right_ready_in(1'b0),
        .right_valid_out(), .right_ready_out()
    );

    // ==========================================
    // N32: T12 Node
    // UP<->N22, RIGHT<->N33, DOWN=OUT.Q, LEFT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level19/node32.hex") ) u_n32 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n32_data),
        // UP: <-> N22.DOWN
        .up_data_in(n22_data), .up_valid_in(n22_d_valid), .up_ready_in(n22_d_ready),
        .up_valid_out(n32_u_valid), .up_ready_out(n32_u_ready),
        // RIGHT: <-> N33.LEFT
        .right_data_in(n33_data), .right_valid_in(n33_l_valid), .right_ready_in(n33_l_ready),
        .right_valid_out(n32_r_valid), .right_ready_out(n32_r_ready),
        // DOWN: OUT.Q
        .down_data_in(24'sd0), .down_valid_in(1'b0), .down_ready_in(n32_d_ready),
        .down_valid_out(n32_d_valid), .down_ready_out(),
        // LEFT: Unused (FIXED: ready_in=0)
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out()
    );

    // ==========================================
    // N33: T12 Node
    // LEFT<->N32, DOWN=OUT.R, UP=free, RIGHT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level19/node33.hex") ) u_n33 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n33_data),
        // LEFT: <-> N32.RIGHT
        .left_data_in(n32_data), .left_valid_in(n32_r_valid), .left_ready_in(n32_r_ready),
        .left_valid_out(n33_l_valid), .left_ready_out(n33_l_ready),
        // DOWN: OUT.R
        .down_data_in(24'sd0), .down_valid_in(1'b0), .down_ready_in(n33_d_ready),
        .down_valid_out(n33_d_valid), .down_ready_out(),
        // UP: Unused (FIXED: ready_in=0)
        .up_data_in(24'sd0), .up_valid_in(1'b0), .up_ready_in(1'b0),
        .up_valid_out(), .up_ready_out(),
        // RIGHT: Unused (FIXED: ready_in=0)
        .right_data_in(24'sd0), .right_valid_in(1'b0), .right_ready_in(1'b0),
        .right_valid_out(), .right_ready_out()
    );

endmodule