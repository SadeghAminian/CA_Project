`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 11 (Registered-Sender, Race-Free)
// Zero-terminated sequences: OUT.I=min, OUT.A=max
//=============================================================================
module tb_stage11;

    localparam int  NUM_IN  = 22;   // تعداد ورودی‌ها (شامل صفرهای پایان‌دهنده)
    localparam int  NUM_OUT = 10;   // 5 دنباله × 2 خروجی (min + max)
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT    = 8ms;

    logic clk = 1'b0;
    logic rst;

    logic signed [23:0] in_a_data;
    logic               in_a_valid;
    logic               in_a_ready;
    logic signed [23:0] out_i_data, out_a_data;
    logic               out_i_valid, out_a_valid;
    logic               out_i_ready, out_a_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    Top_stage11 dut (
        .clk(clk), .rst(rst),
        .in_a_data(in_a_data), .in_a_valid(in_a_valid), .in_a_ready(in_a_ready),
        .out_i_data(out_i_data), .out_i_valid(out_i_valid), .out_i_ready(out_i_ready),
        .out_a_data(out_a_data), .out_a_valid(out_a_valid), .out_a_ready(out_a_ready)
    );

    logic signed [23:0] in_a_vals [0:NUM_IN-1];
    logic signed [23:0] exp_i [0:NUM_OUT/2-1];
    logic signed [23:0] exp_a [0:NUM_OUT/2-1];
    logic signed [23:0] cap_i [0:NUM_OUT/2-1];
    logic signed [23:0] cap_a [0:NUM_OUT/2-1];

    integer recv_i, recv_a, i, errors;
    logic timed_out;

    initial begin
        recv_i = 0; recv_a = 0; errors = 0; timed_out = 0;

        // ورودی: 5 دنباله صفر-پایان‌دهنده
        in_a_vals[0]=14;  in_a_vals[1]=73;  in_a_vals[2]=58;  in_a_vals[3]=0;
        in_a_vals[4]=21;  in_a_vals[5]=87;  in_a_vals[6]=11;  in_a_vals[7]=56;  in_a_vals[8]=0;
        in_a_vals[9]=50;  in_a_vals[10]=71; in_a_vals[11]=60; in_a_vals[12]=0;
        in_a_vals[13]=98; in_a_vals[14]=60; in_a_vals[15]=18; in_a_vals[16]=76; in_a_vals[17]=0;
        in_a_vals[18]=20; in_a_vals[19]=28; in_a_vals[20]=98; in_a_vals[21]=0;

        // خروجی‌های مورد انتظار (به ترتیب دنباله‌ها)
        exp_i[0]=14; exp_i[1]=11; exp_i[2]=50; exp_i[3]=18; exp_i[4]=20;
        exp_a[0]=73; exp_a[1]=87; exp_a[2]=71; exp_a[3]=98; exp_a[4]=98;
    end

    // Sink 
    assign out_i_ready = 1'b1;
    assign out_a_ready = 1'b1;

    // OUT.I
    always @(posedge clk) begin
        if (!rst && out_i_valid && out_i_ready) begin
            if (recv_i < NUM_OUT/2) begin
                cap_i[recv_i] = out_i_data;
                $display("Time=%0t : OUT.I[%0d] <= %0d", $time, recv_i, out_i_data);
            end
            recv_i = recv_i + 1;
        end
    end

    // مانیتور دریافت OUT.A
    always @(posedge clk) begin
        if (!rst && out_a_valid && out_a_ready) begin
            if (recv_a < NUM_OUT/2) begin
                cap_a[recv_a] = out_a_data;
                $display("Time=%0t : OUT.A[%0d] <= %0d", $time, recv_a, out_a_data);
            end
            recv_a = recv_a + 1;
        end
    end

    initial begin
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    //=================================================
    // IN.A
    //=================================================
    logic signed [23:0] a_data_q; logic a_valid_q; integer a_idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin a_valid_q <= 0; a_data_q <= 0; a_idx <= 0; end
        else begin
            if (a_valid_q && in_a_ready) begin
                a_valid_q <= 0;
                $display("Time=%0t : IN.A[%0d]=%0d accepted", $time, a_idx, a_data_q);
                a_idx <= a_idx + 1;
            end else if (!a_valid_q && a_idx < NUM_IN) begin
                a_data_q  <= in_a_vals[a_idx];
                a_valid_q <= 1'b1;
            end
        end
    end
    assign in_a_data  = a_data_q;
    assign in_a_valid = a_valid_q;

    //=================================================
    // Checker with Timeout
    //=================================================
    initial begin
        fork
            wait (recv_i >= NUM_OUT/2 && recv_a >= NUM_OUT/2);
            begin #TIMEOUT; timed_out = 1'b1; end
        join_any
        disable fork;

        if (timed_out) begin
            $display("!! ERROR: TIMEOUT. I:%0d / A:%0d of %0d", recv_i, recv_a, NUM_OUT/2);
            $finish;
        end

        repeat (5) @(posedge clk);

        $display("==================================================");
        $display("  STAGE 11 RESULT CHECK (Zero-term: min/max)");
        $display("==================================================");
        for (i = 0; i < NUM_OUT/2; i++) begin
            if (cap_i[i] === exp_i[i] && cap_a[i] === exp_a[i])
                $display("  PASS: Seq[%0d] I=%0d , A=%0d", i, cap_i[i], cap_a[i]);
            else begin
                $display("  FAIL: Seq[%0d] I=%0d (exp %0d) , A=%0d (exp %0d)",
                         i, cap_i[i], exp_i[i], cap_a[i], exp_a[i]);
                errors = errors + 1;
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 11: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 11: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule