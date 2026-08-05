`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 13 (Reverse Sequence)
//=============================================================================
module tb_stage13;

    localparam int  NUM_VALUES = 11;
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT    = 4ms;

    logic clk = 1'b0;
    logic rst;

    // Input Stream
    logic signed [23:0] in_data;
    logic               in_valid;
    logic               in_ready;

    // Output Stream
    logic signed [23:0] out_data;
    logic               out_valid;
    logic               out_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    Top_stage13 dut (
        .clk(clk), .rst(rst),
        .in_data(in_data), .in_valid(in_valid), .in_ready(in_ready),
        .out_data(out_data), .out_valid(out_valid), .out_ready(out_ready)
    );

    logic signed [23:0] in_vals  [0:NUM_VALUES-1];
    logic signed [23:0] expected [0:NUM_VALUES-1];
    logic signed [23:0] captured [0:NUM_VALUES-1];

    integer recv_count, i, errors;
    logic timed_out;

    initial begin
        recv_count = 0; errors = 0; timed_out = 0;

        // Two zero-terminated sequences
        in_vals  = '{22, 84, 98, 43, 96, 0, 14, 71, 16, 42, 0};
        expected = '{96, 43, 98, 84, 22, 0, 42, 16, 71, 14, 0};
    end

    assign out_ready = 1'b1;

    // Monitor output
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
    // IN Driver (Registered Handshake)
    //=================================================
    logic signed [23:0] data_q; logic valid_q; integer idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin valid_q <= 0; data_q <= 0; idx <= 0; end
        else begin
            if (valid_q && in_ready) begin
                valid_q <= 0;
                $display("Time=%0t : IN[%0d]=%0d accepted", $time, idx, data_q);
                idx <= idx + 1;
            end else if (!valid_q && idx < NUM_VALUES) begin
                data_q  <= in_vals[idx];
                valid_q <= 1'b1;
            end
        end
    end
    assign in_data  = data_q;
    assign in_valid = valid_q;

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
        $display("  STAGE 13 RESULT CHECK (Reverse Sequence)");
        $display("==================================================");
        for (i = 0; i < NUM_VALUES; i++) begin
            if (captured[i] === expected[i])
                $display("  PASS: [%0d] OUT=%0d (IN=%0d)", i, captured[i], in_vals[i]);
            else begin
                $display("  FAIL: [%0d] OUT=%0d (expected %0d) (IN=%0d)",
                         i, captured[i], expected[i], in_vals[i]);
                errors = errors + 1;
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 13: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 13: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule