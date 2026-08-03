`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 2 (double the input)
//=============================================================================
module tb_stage2;

    localparam int NUM_VALUES = 10;
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT = 2ms;

    logic clk = 1'b0;
    logic rst;

    // IN.A side
    logic signed [23:0] in_a_data;
    logic               in_a_valid;
    logic               in_a_ready;

    // OUT side
    logic signed [23:0] out_data;
    logic               out_valid;
    logic               out_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    //=================================================
    // DUT
    //=================================================
    Top_stage2 dut (
        .clk(clk),
        .rst(rst),
        .in_a_data(in_a_data),
        .in_a_valid(in_a_valid),
        .in_a_ready(in_a_ready),
        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready)
    );

    //=================================================
    // Data sets
    //=================================================
    logic signed [23:0] inputs   [0:NUM_VALUES-1];
    logic signed [23:0] expected [0:NUM_VALUES-1];
    logic signed [23:0] captured [0:NUM_VALUES-1];

    int in_sent   = 0;   // handshake counter for IN.A
    int recv_count = 0;  // handshake counter for OUT
    int i;
    int errors = 0;

    //=================================================
    // OUT sink: always ready + capture monitor
    //=================================================
    assign out_ready = 1'b1;

    always @(posedge clk) begin
        if (!rst && out_valid && out_ready) begin
            if (recv_count < NUM_VALUES) begin
                captured[recv_count] = out_data;
                $display("Time=%0t : OUT[%0d] <= %0d", $time, recv_count, out_data);
            end
            recv_count = recv_count + 1;
        end
    end

    //=================================================
    // IN.A transfer monitor (race-free handshake detection)
    //=================================================
    always @(posedge clk) begin
        if (!rst && in_a_valid && in_a_ready)
            in_sent = in_sent + 1;
    end

    //=================================================
    // Stimulus: send values one by one using handshake
    //=================================================
    initial begin
        inputs[0]=66;  inputs[1]=34;  inputs[2]=88;  inputs[3]=91;  inputs[4]=53;
        inputs[5]=96;  inputs[6]=96;  inputs[7]=47;  inputs[8]=68;  inputs[9]=83;

        expected[0]=132; expected[1]=68;  expected[2]=176; expected[3]=182; expected[4]=106;
        expected[5]=192; expected[6]=192; expected[7]=94;  expected[8]=136; expected[9]=166;

        rst = 1'b1;
        in_a_data  = 24'sd0;
        in_a_valid = 1'b0;
        repeat (5) @(posedge clk);
        rst = 1'b0;
        @(negedge clk);

        for (i = 0; i < NUM_VALUES; i++) begin
            // drive on negedge for stability
            in_a_data  = inputs[i];
            in_a_valid = 1'b1;
            // wait until the node consumes it (handshake on a posedge)
            while (in_sent < i+1) @(posedge clk);
            @(negedge clk);
            in_a_valid = 1'b0;
        end
        $display("All %0d input values sent.", NUM_VALUES);
    end

    //=================================================
    // Checker with timeout
    //=================================================
   

    //=================================================
    // Checker with timeout  (FIXED: join_any + disable fork)
    //=================================================
    logic timed_out = 1'b0;

    initial begin
        fork
            begin
                wait (recv_count >= NUM_VALUES);  // موفقیت: هر ۱۰ خروجی رسید
            end
            begin
                #TIMEOUT;                          // شکست: زمان تمام شد
                timed_out = 1'b1;
            end
        join_any          
        disable fork;    

        if (timed_out) begin
            $display("!! ERROR: simulation TIMEOUT. received %0d / %0d",
                     recv_count, NUM_VALUES);
            $finish;
        end

        repeat (5) @(posedge clk);

        $display("==================================================");
        $display("  STAGE 2 RESULT CHECK (OUT = 2 * IN.A)");
        $display("==================================================");
        for (i = 0; i < NUM_VALUES; i++) begin
            if (captured[i] === expected[i])
                $display("  PASS: OUT[%0d] = %0d", i, captured[i]);
            else begin
                $display("  FAIL: OUT[%0d] = %0d  (expected %0d)", i, captured[i], expected[i]);
                errors = errors + 1;
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 2: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 2: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule