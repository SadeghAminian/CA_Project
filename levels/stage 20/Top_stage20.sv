//Sequence Indexer 
module Top_stage20 (
    input  logic        clk,
    input  logic        rst,
    // Input V Stream
    input  logic signed [23:0] in_v_data,
    input  logic               in_v_valid,
    output logic               in_v_ready,
    // Input X Stream
    input  logic signed [23:0] in_x_data,
    input  logic               in_x_valid,
    output logic               in_x_ready,
    // Output Stream
    output logic signed [23:0] out_data,
    output logic               out_valid,
    input  logic               out_ready
);

    // ==========================================
    // Shared Data Lines (t12Node: single data_out)
    // ==========================================
    logic signed [23:0] n11_data, n13_data;
    logic signed [23:0] n21_data, n22_data, n23_data;
    logic signed [23:0] n33_data;

    // T30 Data Lines (separate per direction)
    logic signed [23:0] n12_data_l;  // N12.LEFT out -> N11.RIGHT in
    logic signed [23:0] n12_data_d;  // N12.DOWN out -> N22.UP in
    logic signed [23:0] n32_data_u;  // N32.UP out   -> N22.DOWN in

    // ==========================================
    // Handshake Signals
    // ==========================================
    logic n11_u_ready_out;
    logic n13_u_ready_out;
    logic n33_d_valid;
    logic n33_d_ready;

    // N11.RIGHT <-> N12.LEFT
    logic n11_r_valid, n11_r_ready;
    logic n12_l_valid, n12_l_ready;

    // N11.DOWN <-> N21.UP
    logic n11_d_valid, n11_d_ready;
    logic n21_u_valid, n21_u_ready;

    // N12.DOWN <-> N22.UP
    logic n12_d_valid, n12_d_ready;
    logic n22_u_valid, n22_u_ready;

    // N13.DOWN <-> N23.UP
    logic n13_d_valid, n13_d_ready;
    logic n23_u_valid, n23_u_ready;

    // N21.RIGHT <-> N22.LEFT
    logic n21_r_valid, n21_r_ready;
    logic n22_l_valid, n22_l_ready;

    // N22.DOWN <-> N32.UP
    logic n22_d_valid, n22_d_ready;
    logic n32_u_valid, n32_u_ready;

    // N22.RIGHT <-> N23.LEFT
    logic n22_r_valid, n22_r_ready;
    logic n23_l_valid, n23_l_ready;

    // N23.DOWN <-> N33.UP
    logic n23_d_valid, n23_d_ready;
    logic n33_u_valid, n33_u_ready;

    // ==========================================
    // External IO Mapping
    // ==========================================
    assign in_v_ready  = n11_u_ready_out;
    assign in_x_ready  = n13_u_ready_out;
    assign out_data    = n33_data;
    assign out_valid   = n33_d_valid;
    assign n33_d_ready = out_ready;

    // ==========================================
    // N11: T12 Node
    // UP=IN.V, DOWN<->N21, RIGHT<->N12, LEFT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level20/node11.hex") ) u_n11 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n11_data),
        // UP: IN.V  (FIXED: ready_in=1, ready_out -> in_v_ready)
        .up_data_in(in_v_data), .up_valid_in(in_v_valid), .up_ready_in(1'b1),
        .up_valid_out(), .up_ready_out(n11_u_ready_out),
        // DOWN: <-> N21.UP
        .down_data_in(n21_data), .down_valid_in(n21_u_valid), .down_ready_in(n21_u_ready),
        .down_valid_out(n11_d_valid), .down_ready_out(n11_d_ready),
        // RIGHT: <-> N12.LEFT
        .right_data_in(n12_data_l), .right_valid_in(n12_l_valid), .right_ready_in(n12_l_ready),
        .right_valid_out(n11_r_valid), .right_ready_out(n11_r_ready),
        // LEFT: Unused
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out()
    );

    // ==========================================
    // N12: T30 Stack Node
    // LEFT<->N11.RIGHT, DOWN<->N22.UP, RIGHT=free, UP=free
    // ==========================================
    t30_node u_n12 (
        .clk(clk), .rst(rst),
        // LEFT: <-> N11.RIGHT
        .data_in_l(n11_data),   .valid_in_l(n11_r_valid), .ready_in_l(n11_r_ready),
        .data_out_l(n12_data_l), .valid_out_l(n12_l_valid), .ready_out_l(n12_l_ready),
        // DOWN: <-> N22.UP  (FIXED: full bidirectional)
        .data_in_d(n22_data),   .valid_in_d(n22_u_valid), .ready_in_d(n22_u_ready),
        .data_out_d(n12_data_d), .valid_out_d(n12_d_valid), .ready_out_d(n12_d_ready),
        // RIGHT: Unused  (FIXED: ready_in=0)
        .data_in_r(24'sd0), .valid_in_r(1'b0), .ready_in_r(1'b0),
        .data_out_r(), .valid_out_r(), .ready_out_r(),
        // UP: Unused  (FIXED: ready_in=0)
        .data_in_u(24'sd0), .valid_in_u(1'b0), .ready_in_u(1'b0),
        .data_out_u(), .valid_out_u(), .ready_out_u()
    );

    // ==========================================
    // N13: T12 Node
    // UP=IN.X, DOWN<->N23.UP, LEFT=free, RIGHT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level20/node13.hex") ) u_n13 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n13_data),
        // UP: IN.X  (FIXED: ready_in=1, ready_out -> in_x_ready)
        .up_data_in(in_x_data), .up_valid_in(in_x_valid), .up_ready_in(1'b1),
        .up_valid_out(), .up_ready_out(n13_u_ready_out),
        // DOWN: <-> N23.UP
        .down_data_in(n23_data), .down_valid_in(n23_u_valid), .down_ready_in(n23_u_ready),
        .down_valid_out(n13_d_valid), .down_ready_out(n13_d_ready),
        // LEFT: Unused
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out(),
        // RIGHT: Unused
        .right_data_in(24'sd0), .right_valid_in(1'b0), .right_ready_in(1'b0),
        .right_valid_out(), .right_ready_out()
    );

    // ==========================================
    // N21: T12 Node
    // UP<->N11.DOWN, RIGHT<->N22.LEFT, LEFT=free, DOWN=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level20/node21.hex") ) u_n21 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n21_data),
        // UP: <-> N11.DOWN  (FIXED: valid_out/ready_out connected)
        .up_data_in(n11_data), .up_valid_in(n11_d_valid), .up_ready_in(n11_d_ready),
        .up_valid_out(n21_u_valid), .up_ready_out(n21_u_ready),
        // RIGHT: <-> N22.LEFT
        .right_data_in(n22_data), .right_valid_in(n22_l_valid), .right_ready_in(n22_l_ready),
        .right_valid_out(n21_r_valid), .right_ready_out(n21_r_ready),
        // LEFT: Unused
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out(),
        // DOWN: Unused
        .down_data_in(24'sd0), .down_valid_in(1'b0), .down_ready_in(1'b0),
        .down_valid_out(), .down_ready_out()
    );

    // ==========================================
    // N22: T12 Node (all 4 ports used)
    // UP<->N12.DOWN, LEFT<->N21.RIGHT, RIGHT<->N23.LEFT, DOWN<->N32.UP
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level20/node22.hex") ) u_n22 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n22_data),
        // UP: <-> N12.DOWN  (FIXED: valid_out/ready_out connected)
        .up_data_in(n12_data_d), .up_valid_in(n12_d_valid), .up_ready_in(n12_d_ready),
        .up_valid_out(n22_u_valid), .up_ready_out(n22_u_ready),
        // LEFT: <-> N21.RIGHT
        .left_data_in(n21_data), .left_valid_in(n21_r_valid), .left_ready_in(n21_r_ready),
        .left_valid_out(n22_l_valid), .left_ready_out(n22_l_ready),
        // RIGHT: <-> N23.LEFT
        .right_data_in(n23_data), .right_valid_in(n23_l_valid), .right_ready_in(n23_l_ready),
        .right_valid_out(n22_r_valid), .right_ready_out(n22_r_ready),
        // DOWN: <-> N32.UP  (FIXED: valid_in/ready_in connected)
        .down_data_in(n32_data_u), .down_valid_in(n32_u_valid), .down_ready_in(n32_u_ready),
        .down_valid_out(n22_d_valid), .down_ready_out(n22_d_ready)
    );

    // ==========================================
    // N23: T12 Node
    // UP<->N13.DOWN, LEFT<->N22.RIGHT, DOWN<->N33.UP, RIGHT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level20/node23.hex") ) u_n23 (
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
    // N32: T30 Stack Node
    // UP<->N22.DOWN, RIGHT=free, LEFT=free, DOWN=free
    // ==========================================
    t30_node u_n32 (
        .clk(clk), .rst(rst),
        // UP: <-> N22.DOWN  (FIXED: valid_out/ready_out connected)
        .data_in_u(n22_data),   .valid_in_u(n22_d_valid), .ready_in_u(n22_d_ready),
        .data_out_u(n32_data_u), .valid_out_u(n32_u_valid), .ready_out_u(n32_u_ready),
        // RIGHT: Unused  (FIXED: ready_in=0)
        .data_in_r(24'sd0), .valid_in_r(1'b0), .ready_in_r(1'b0),
        .data_out_r(), .valid_out_r(), .ready_out_r(),
        // LEFT: Unused  (FIXED: ready_in=0)
        .data_in_l(24'sd0), .valid_in_l(1'b0), .ready_in_l(1'b0),
        .data_out_l(), .valid_out_l(), .ready_out_l(),
        // DOWN: Unused  (FIXED: ready_in=0)
        .data_in_d(24'sd0), .valid_in_d(1'b0), .ready_in_d(1'b0),
        .data_out_d(), .valid_out_d(), .ready_out_d()
    );

    // ==========================================
    // N33: T12 Node
    // UP<->N23.DOWN, DOWN=OUT, LEFT=free, RIGHT=free
    // ==========================================
    t12Node #( .FILE_NAME("C:/Users/TUF/CA Project/hex/level20/node33.hex") ) u_n33 (
        .clk(clk), .rst(rst),
        .acc_out(), .zero_flag(), .sign_flag(),
        .data_out(n33_data),
        // UP: <-> N23.DOWN
        .up_data_in(n23_data), .up_valid_in(n23_d_valid), .up_ready_in(n23_d_ready),
        .up_valid_out(n33_u_valid), .up_ready_out(n33_u_ready),
        // DOWN: -> OUT
        .down_data_in(24'sd0), .down_valid_in(1'b0), .down_ready_in(n33_d_ready),
        .down_valid_out(n33_d_valid), .down_ready_out(),
        // LEFT: Unused
        .left_data_in(24'sd0), .left_valid_in(1'b0), .left_ready_in(1'b0),
        .left_valid_out(), .left_ready_out(),
        // RIGHT: Unused
        .right_data_in(24'sd0), .right_valid_in(1'b0), .right_ready_in(1'b0),
        .right_valid_out(), .right_ready_out()
    );

endmodule