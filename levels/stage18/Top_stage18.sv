// window filter solution
module Top_stage18 (
    input  logic        clk,
    input  logic        rst,
    // Input Stream
    input  logic signed [23:0] in_data,
    input  logic               in_valid,
    output logic               in_ready,
    // Output 3 Stream
    output logic signed [23:0] out3_data,
    output logic               out3_valid,
    input  logic               out3_ready,
    // Output 5 Stream
    output logic signed [23:0] out5_data,
    output logic               out5_valid,
    input  logic               out5_ready
);

    // ==========================================
    // Shared Data Lines (t12Node: single data_out)
    // ==========================================
    logic signed [23:0] n12_data, n13_data, n22_data, n23_data, n24_data;
    logic signed [23:0] n32_data, n33_data;

    // T30 Stack Data Lines
    logic signed [23:0] n14_data_d, n14_data_l, n14_data_r, n14_data_u;
    logic signed [23:0] n34_data_u, n34_data_l, n34_data_r, n34_data_d;

    // ==========================================
    // Handshake Signals
    // ==========================================
    
    // External IO
    logic n12_u_ready_out;
    logic n32_d_valid, n32_d_ready;
    logic n33_d_valid, n33_d_ready;

    // N12.RIGHT <-> N13.LEFT
    logic n12_r_valid, n12_r_ready;
    logic n13_l_valid, n13_l_ready;

    // N12.DOWN <-> N22.UP
    logic n12_d_valid, n12_d_ready;
    logic n22_u_valid, n22_u_ready;

    // N13.DOWN <-> N23.UP
    logic n13_d_valid, n13_d_ready;
    logic n23_u_valid, n23_u_ready;

    // N13.RIGHT <-> N14.LEFT
    logic n13_r_valid, n13_r_ready;
    logic n14_l_valid, n14_l_ready;

    // N14.DOWN <-> N24.UP
    logic n14_d_valid, n14_d_ready;
    logic n24_u_valid, n24_u_ready;

    // N22.RIGHT <-> N23.LEFT
    logic n22_r_valid, n22_r_ready;
    logic n23_l_valid, n23_l_ready;

    // N22.DOWN <-> N32.UP
    logic n22_d_valid, n22_d_ready;
    logic n32_u_valid, n32_u_ready;

    // N23.DOWN <-> N33.UP
    logic n23_d_valid, n23_d_ready;
    logic n33_u_valid, n33_u_ready;

    // N23.RIGHT <-> N24.LEFT
    logic n23_r_valid, n23_r_ready;
    logic n24_l_valid, n24_l_ready;

    // N24.DOWN <-> N34.UP
    logic n24_d_valid, n24_d_ready;
    logic n34_u_valid, n34_u_ready;

    // N32.RIGHT <-> N33.LEFT
    logic n32_r_valid, n32_r_ready;
    logic n33_l_valid, n33_l_ready;

    // N33.RIGHT <-> N34.LEFT
    logic n33_r_valid, n33_r_ready;
    logic n34_l_valid, n34_l_ready;

    // ==========================================
    // External IO Mapping
    // ==========================================
    assign in_ready   = n12_u_ready_out;
    
    assign out3_data  = n32_data;
    assign out3_valid = n32_d_valid;
    assign n32_d_ready = out3_ready;
    
    assign out5_data  = n33_data;
    assign out5_valid = n33_d_valid;
    assign n33_d_ready = out5_ready;

    // ==========================================
    // N12: T12 Node
    // UP=IN, RIGHT<->N13, DOWN<->N22, LEFT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level18/node12.hex") ) u_n12 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n12_data),
        // UP: IN
        .up_data_in(in_data), .up_valid_in(in_valid), .up_ready_in(1'b1),
        .up_valid_out(), .up_ready_out(n12_u_ready_out),
        // RIGHT: <-> N13
        .right_data_in(n13_data), .right_valid_in(n13_l_valid), .right_ready_in(n13_l_ready),
        .right_valid_out(n12_r_valid), .right_ready_out(n12_r_ready),
        // DOWN: <-> N22
        .down_data_in(n22_data), .down_valid_in(n22_u_valid), .down_ready_in(n22_u_ready),
        .down_valid_out(n12_d_valid), .down_ready_out(n12_d_ready),
        // LEFT: Unused
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out()
    );

    // ==========================================
    // N13: T12 Node
    // LEFT<->N12, RIGHT<->N14, DOWN<->N23, UP=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level18/node13.hex") ) u_n13 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n13_data),
        // LEFT: <-> N12
        .left_data_in(n12_data), .left_valid_in(n12_r_valid), .left_ready_in(n12_r_ready),
        .left_valid_out(n13_l_valid), .left_ready_out(n13_l_ready),
        // RIGHT: <-> N14
        .right_data_in(n14_data_l), .right_valid_in(n14_l_valid), .right_ready_in(n14_l_ready),
        .right_valid_out(n13_r_valid), .right_ready_out(n13_r_ready),
        // DOWN: <-> N23
        .down_data_in(n23_data), .down_valid_in(n23_u_valid), .down_ready_in(n23_u_ready),
        .down_valid_out(n13_d_valid), .down_ready_out(n13_d_ready),
        // UP: Unused
        .up_data_in(24'sd0), .up_valid_in(1'b0), .up_ready_in(1'b0),
        .up_valid_out(), .up_ready_out()
    );

    // ==========================================
    // N14: T30 Stack Node
    // LEFT<->N13, DOWN<->N24, RIGHT=free, UP=free
    // ==========================================
    t30_node #(.STACK_DEPTH(32)) u_n14 (
        .clk(clk), .rst(rst),
        // LEFT: <-> N13
        .data_in_l(n13_data), .valid_in_l(n13_r_valid), .ready_in_l(n13_r_ready),
        .data_out_l(n14_data_l), .valid_out_l(n14_l_valid), .ready_out_l(n14_l_ready),
        // DOWN: <-> N24
        .data_in_d(n24_data), .valid_in_d(n24_u_valid), .ready_in_d(n24_u_ready),
        .data_out_d(n14_data_d), .valid_out_d(n14_d_valid), .ready_out_d(n14_d_ready),
        // RIGHT: Unused
        .data_in_r(24'sd0), .valid_in_r(1'b0), .ready_in_r(1'b0),
        .data_out_r(), .valid_out_r(), .ready_out_r(),
        // UP: Unused
        .data_in_u(24'sd0), .valid_in_u(1'b0), .ready_in_u(1'b0),
        .data_out_u(), .valid_out_u(), .ready_out_u()
    );

    // ==========================================
    // N22: T12 Node
    // UP<->N12, RIGHT<->N23, DOWN<->N32, LEFT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level18/node22.hex") ) u_n22 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n22_data),
        // UP: <-> N12
        .up_data_in(n12_data), .up_valid_in(n12_d_valid), .up_ready_in(n12_d_ready),
        .up_valid_out(n22_u_valid), .up_ready_out(n22_u_ready),
        // RIGHT: <-> N23
        .right_data_in(n23_data), .right_valid_in(n23_l_valid), .right_ready_in(n23_l_ready),
        .right_valid_out(n22_r_valid), .right_ready_out(n22_r_ready),
        // DOWN: <-> N32
        .down_data_in(n32_data), .down_valid_in(n32_u_valid), .down_ready_in(n32_u_ready),
        .down_valid_out(n22_d_valid), .down_ready_out(n22_d_ready),
        // LEFT: Unused
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out()
    );

    // ==========================================
    // N23: T12 Node
    // UP<->N13, LEFT<->N22, RIGHT<->N24, DOWN<->N33
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level18/node23.hex") ) u_n23 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n23_data),
        // UP: <-> N13
        .up_data_in(n13_data), .up_valid_in(n13_d_valid), .up_ready_in(n13_d_ready),
        .up_valid_out(n23_u_valid), .up_ready_out(n23_u_ready),
        // LEFT: <-> N22
        .left_data_in(n22_data), .left_valid_in(n22_r_valid), .left_ready_in(n22_r_ready),
        .left_valid_out(n23_l_valid), .left_ready_out(n23_l_ready),
        // RIGHT: <-> N24
        .right_data_in(n24_data), .right_valid_in(n24_l_valid), .right_ready_in(n24_l_ready),
        .right_valid_out(n23_r_valid), .right_ready_out(n23_r_ready),
        // DOWN: <-> N33
        .down_data_in(n33_data), .down_valid_in(n33_u_valid), .down_ready_in(n33_u_ready),
        .down_valid_out(n23_d_valid), .down_ready_out(n23_d_ready)
    );

    // ==========================================
    // N24: T12 Node
    // UP<->N14, LEFT<->N23, DOWN<->N34, RIGHT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level18/node24.hex") ) u_n24 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n24_data),
        // UP: <-> N14
        .up_data_in(n14_data_d), .up_valid_in(n14_d_valid), .up_ready_in(n14_d_ready),
        .up_valid_out(n24_u_valid), .up_ready_out(n24_u_ready),
        // LEFT: <-> N23
        .left_data_in(n23_data), .left_valid_in(n23_r_valid), .left_ready_in(n23_r_ready),
        .left_valid_out(n24_l_valid), .left_ready_out(n24_l_ready),
        // DOWN: <-> N34
        .down_data_in(n34_data_u), .down_valid_in(n34_u_valid), .down_ready_in(n34_u_ready),
        .down_valid_out(n24_d_valid), .down_ready_out(n24_d_ready),
        // RIGHT: Unused
        .right_data_in(24'sd0), .right_valid_in(1'b0), .right_ready_in(1'b0),
        .right_valid_out(), .right_ready_out()
    );

    // ==========================================
    // N32: T12 Node
    // UP<->N22, RIGHT<->N33, DOWN=OUT.3, LEFT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level18/node32.hex") ) u_n32 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n32_data),
        // UP: <-> N22
        .up_data_in(n22_data), .up_valid_in(n22_d_valid), .up_ready_in(n22_d_ready),
        .up_valid_out(n32_u_valid), .up_ready_out(n32_u_ready),
        // RIGHT: <-> N33
        .right_data_in(n33_data), .right_valid_in(n33_l_valid), .right_ready_in(n33_l_ready),
        .right_valid_out(n32_r_valid), .right_ready_out(n32_r_ready),
        // DOWN: OUT.3
        .down_data_in(24'sd0), .down_valid_in(1'b0), .down_ready_in(n32_d_ready),
        .down_valid_out(n32_d_valid), .down_ready_out(),
        // LEFT: Unused
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out()
    );

    // ==========================================
    // N33: T12 Node
    // UP<->N23, LEFT<->N32, RIGHT<->N34, DOWN=OUT.5
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level18/node33.hex") ) u_n33 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n33_data),
        // UP: <-> N23
        .up_data_in(n23_data), .up_valid_in(n23_d_valid), .up_ready_in(n23_d_ready),
        .up_valid_out(n33_u_valid), .up_ready_out(n33_u_ready),
        // LEFT: <-> N32
        .left_data_in(n32_data), .left_valid_in(n32_r_valid), .left_ready_in(n32_r_ready),
        .left_valid_out(n33_l_valid), .left_ready_out(n33_l_ready),
        // RIGHT: <-> N34
        .right_data_in(n34_data_l), .right_valid_in(n34_l_valid), .right_ready_in(n34_l_ready),
        .right_valid_out(n33_r_valid), .right_ready_out(n33_r_ready),
        // DOWN: OUT.5
        .down_data_in(24'sd0), .down_valid_in(1'b0), .down_ready_in(n33_d_ready),
        .down_valid_out(n33_d_valid), .down_ready_out()
    );

    // ==========================================
    // N34: T30 Stack Node
    // UP<->N24, LEFT<->N33, RIGHT=free, DOWN=free
    // ==========================================
    t30_node #(.STACK_DEPTH(32)) u_n34 (
        .clk(clk), .rst(rst),
        // UP: <-> N24
        .data_in_u(n24_data), .valid_in_u(n24_d_valid), .ready_in_u(n24_d_ready),
        .data_out_u(n34_data_u), .valid_out_u(n34_u_valid), .ready_out_u(n34_u_ready),
        // LEFT: <-> N33
        .data_in_l(n33_data), .valid_in_l(n33_r_valid), .ready_in_l(n33_r_ready),
        .data_out_l(n34_data_l), .valid_out_l(n34_l_valid), .ready_out_l(n34_l_ready),
        // RIGHT: Unused
        .data_in_r(24'sd0), .valid_in_r(1'b0), .ready_in_r(1'b0),
        .data_out_r(), .valid_out_r(), .ready_out_r(),
        // DOWN: Unused
        .data_in_d(24'sd0), .valid_in_d(1'b0), .ready_in_d(1'b0),
        .data_out_d(), .valid_out_d(), .ready_out_d()
    );

endmodule