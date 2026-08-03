`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 8 (Registered-Sender, Race-Free)
//=============================================================================
module tb_stage8;

    localparam int  NUM_VALUES = 10;
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT    = 4ms;

    logic clk = 1'b0;
    logic rst;

    logic signed [23:0] in_a_data;
    logic               in_a_valid;
    logic               in_a_ready;
    logic signed [23:0] out_data;
    logic               out_valid;
    logic               out_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    Top_stage8 dut (
        .clk(clk), .rst(rst),
        .in_a_data(in_a_data), .in_a_valid(in_a_valid), .in_a_ready(in_a_ready),
        .out_data(out_data), .out_valid(out_valid), .out_ready(out_ready)
    );

    logic signed [23:0] in_a_vals [0:NUM_VALUES-1];
    logic signed [23:0] expected  [0:NUM_VALUES-1];
    logic signed [23:0] captured  [0:NUM_VALUES-1];

    integer recv_count, i, errors;
    logic timed_out;

    initial begin
        recv_count = 0; errors = 0; timed_out = 0;

        in_a_vals[0]=0;  in_a_vals[1]=32; in_a_vals[2]=30; in_a_vals[3]=27; in_a_vals[4]=24;
        in_a_vals[5]=28; in_a_vals[6]=37; in_a_vals[7]=33; in_a_vals[8]=24; in_a_vals[9]=13;

        expected[0]=0; expected[1]=1; expected[2]=0; expected[3]=0; expected[4]=0;
        expected[5]=0; expected[6]=0; expected[7]=0; expected[8]=0; expected[9]=1;
    end

    assign out_ready = 1'b1;

    // Monitot output
    always @(posedge clk) begin
        if (!rst && out_valid && out_ready) begin
            if (recv_count < NUM_VALUES) begin
                captured[recv_count] = out_data;
                $display("Time=%0t : OUT[%0d] <= %0d", $time, recv_count, out_data);
            end
            recv_count = recv_count + 1;
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
            end else if (!a_valid_q && a_idx < NUM_VALUES) begin
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
            wait (recv_count >= NUM_VALUES);
            begin #TIMEOUT; timed_out = 1'b1; end
        join_any
        disable fork;

        if (timed_out) begin
            $display("!! ERROR: TIMEOUT. received %0d / %0d", recv_count, NUM_VALUES);
            $finish;
        end

        repeat (5) @(posedge clk);

        $display("==================================================");
        $display("  STAGE 8 RESULT CHECK (|delta| >= 10)");
        $display("==================================================");
        for (i = 0; i < NUM_VALUES; i++) begin
            if (captured[i] === expected[i])
                $display("  PASS: [%0d] OUT=%0d (IN=%0d)", i, captured[i], in_a_vals[i]);
            else begin
                $display("  FAIL: [%0d] OUT=%0d (expected %0d) (IN=%0d)",
                         i, captured[i], expected[i], in_a_vals[i]);
                errors = errors + 1;
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 8: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 8: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule