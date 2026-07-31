module t21_node (
    input  logic        clk,
    input  logic        rst,

    input  logic [10:0] port_in        [0:3],
    input  logic        port_in_valid  [0:3],
    output logic        port_in_ready  [0:3],

    output logic [10:0] port_out       [0:3],
    output logic        port_out_valid [0:3],
    input  logic        port_out_ready [0:3]
);

    logic [3:0]  pc;
    logic [23:0] instr;

    logic [3:0]  opcode;
    logic [3:0]  dst;
    logic [3:0]  src_type;
    logic [11:0] src_val;

    logic [10:0] acc_out;
    logic [10:0] port_rd_data;
    logic [10:0] port_wr_data;
    logic [10:0] port_write_value;
    logic [10:0] port_read_buffer;

    logic [3:0] jro_target;
    logic       branch_taken;

    logic       port_ready;
    logic       port_rd;
    logic       port_wr;
    logic [2:0] port_sel;

    logic       pc_load;
    logic       pc_inc;
    logic [3:0] pc_next;
    logic       stall;

    logic       acc_wr;
    logic       bak_wr;
    logic       swp_en;

    logic [3:0] rx_valid;
    logic [3:0] rx_ready;
    logic [3:0] tx_valid;
    logic [3:0] tx_ready;

    logic [10:0] rx_data [0:3];
    logic [10:0] tx_data [0:3];

    logic src_is_port;

    assign opcode   = instr[23:20];
    assign dst      = instr[19:16];
    assign src_type = instr[15:12];
    assign src_val  = instr[11:0];

    assign src_is_port =
        (src_type >= 4'h2) &&
        (src_type <= 4'h7);

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : g_port_connections
            assign rx_valid[i]       = port_in_valid[i];
            assign port_in_ready[i]  = rx_ready[i];
            assign rx_data[i]        = port_in[i];

            assign port_out_valid[i] = tx_valid[i];
            assign tx_ready[i]       = port_out_ready[i];
            assign port_out[i]       = tx_data[i];
        end
    endgenerate

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 4'd0;
        else if (pc_load)
            pc <= pc_next;
        else if (pc_inc)
            pc <= pc + 4'd1;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            port_read_buffer <= 11'd0;
        else if (port_rd && port_ready)
            port_read_buffer <= port_rd_data;
    end

    always_comb begin
        if (src_is_port)
            port_write_value = port_read_buffer;
        else
            port_write_value = port_wr_data;
    end

    instr_mem u_mem (
        .addr  (pc),
        .instr (instr)
    );

    control_unit u_ctrl (
        .clk         (clk),
        .rst         (rst),
        .instr       (instr),
        .acc         (acc_out),
        .jro_target  (jro_target),
        .port_ready  (port_ready),

        .pc_load     (pc_load),
        .pc_next     (pc_next),
        .pc_inc      (pc_inc),

        .acc_wr      (acc_wr),
        .bak_wr      (bak_wr),
        .swp_en      (swp_en),

        .port_rd     (port_rd),
        .port_wr     (port_wr),
        .port_sel    (port_sel),
        .stall       (stall)
    );

    datapath u_dp (
        .clk          (clk),
        .rst          (rst),

        .acc_wr       (acc_wr),
        .bak_wr       (bak_wr),
        .swp_en       (swp_en),

        .opcode       (opcode),
        .dst          (dst),
        .src_type     (src_type),
        .src_val      (src_val),

        .port_rd_data (port_rd_data),
        .port_wr_data (port_wr_data),

        .acc_out      (acc_out),
        .jro_target   (jro_target),
        .pc_in        (pc),
        .branch_taken (branch_taken)
    );

    port_interface u_pi (
        .clk        (clk),
        .rst        (rst),

        .port_rd    (port_rd),
        .port_wr    (port_wr),
        .port_sel   (port_sel),

        .wr_data    (port_write_value),
        .rd_data    (port_rd_data),
        .port_ready (port_ready),

        .tx_valid   (tx_valid),
        .tx_data    (tx_data),
        .tx_ready   (tx_ready),

        .rx_valid   (rx_valid),
        .rx_data    (rx_data),
        .rx_ready   (rx_ready)
    );

endmodule
