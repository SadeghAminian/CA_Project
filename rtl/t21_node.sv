module t21_node (
    input  logic clk, rst,
    // پورت‌های خارجی (LEFT/RIGHT/UP/DOWN)
    input  logic [10:0] port_in  [0:3],
    input  logic        port_in_valid [0:3],
    output logic        port_in_ready [0:3],
    output logic [10:0] port_out [0:3],
    output logic        port_out_valid [0:3],
    input  logic        port_out_ready [0:3]
);

    // --- سیگنال‌های داخلی ---
    logic [3:0]  pc;
    logic [23:0] instr;

    // استخراج فیلدهای دستورالعمل به صورت ترکیبی
    logic [3:0]  opcode;
    logic [3:0]  dst, src_type;
    logic [11:0] src_val;

    assign opcode   = instr[23:20];
    assign dst      = instr[19:16];
    assign src_type = instr[15:12];
    assign src_val  = instr[11:0];

    logic [10:0] acc_out, port_rd_data, port_wr_data;
    logic [3:0]  jro_target;
    logic        branch_taken;

    // سیگنال‌های کنترلی
    logic        port_ready, port_rd, port_wr;
    logic [2:0]  port_sel;
    logic        pc_load, pc_inc, stall;
    logic [3:0]  pc_next;
    logic        acc_wr, bak_wr, swp_en; 

    // --- رفع مشکل آرایه‌های Packed و Unpacked ---
    logic [3:0] rx_valid, rx_ready, tx_valid, tx_ready;
    always_comb begin
        for (int i=0; i<4; i++) begin
            rx_valid[i]      = port_in_valid[i];
            port_in_ready[i] = rx_ready[i];
            port_out_valid[i]= tx_valid[i];
            tx_ready[i]      = port_out_ready[i];
        end
    end

    // --- رجیستر شمارنده برنامه (PC) ---
    // این بخش در کد شما جا افتاده بود!
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 4'd0;
        else if (pc_load)
            pc <= pc_next;
        else if (pc_inc)
            pc <= pc + 1'b1;
    end

    // --- نگاشت ماژول‌ها ---
    instr_mem u_mem (
        .addr(pc),
        .instr(instr)
    );

    control_unit u_ctrl (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .acc(acc_out),
        .port_ready(port_ready),
        .pc_load(pc_load),
        .pc_next(pc_next),
        .pc_inc(pc_inc),
        .acc_wr(acc_wr),
        .bak_wr(bak_wr),
        .swp_en(swp_en),
        .port_rd(port_rd),
        .port_wr(port_wr),
        .port_sel(port_sel),
        .stall(stall)
    );

    datapath u_dp (
        .clk(clk),
        .rst(rst),
        .acc_wr(acc_wr),     // اضافه شد
        .bak_wr(bak_wr),     // اضافه شد
        .swp_en(swp_en),     // اضافه شد
        .opcode(opcode),
        .dst(dst),
        .src_type(src_type),
        .src_val(src_val),
        .port_rd_data(port_rd_data),
        .port_wr_data(port_wr_data),
        .acc_out(acc_out),
        .jro_target(jro_target),
        .pc_in(pc),
        .branch_taken(branch_taken)
    );

    port_interface u_pi (
        .clk(clk),
        .rst(rst),
        .port_rd(port_rd),
        .port_wr(port_wr),
        .port_sel(port_sel),
        .wr_data(port_wr_data),
        .rd_data(port_rd_data),
        .port_ready(port_ready),
        .tx_valid(tx_valid),
        .tx_data(port_out),
        .tx_ready(tx_ready),
        .rx_valid(rx_valid),
        .rx_data(port_in),
        .rx_ready(rx_ready)
    );

endmodule