`timescale 1ns/1ps

module RegisterFile_tb;

    logic clk;
    logic rst;

    logic [23:0] acc_out;

    logic [23:0] data_in;
    logic        write_en;
    logic [3:0]  write_addr;

    logic swap;
    logic sav;

    //====================================
    // DUT
    //====================================

    RegisterFile dut (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_out),
        .data_in(data_in),
        .write_en(write_en),
        .write_addr(write_addr),
        .swap(swap),
        .sav(sav)
    );

    //====================================
    // Clock Generation
    //====================================

    initial clk = 0;
    always #5 clk = ~clk;

    //====================================
    // Test
    //====================================

    initial begin

        //----------------------------------
        // Initial Values
        //----------------------------------

        rst        = 1;
        write_en   = 0;
        write_addr = 0;
        data_in    = 0;
        swap       = 0;
        sav        = 0;

        #12;
        rst = 0;

        //----------------------------------
        // Test 1 : Reset
        //----------------------------------

        if (acc_out !== 24'h0)
            $fatal(1, "Reset failed!");

        //----------------------------------
        // Test 2 : Write ACC
        //----------------------------------

        @(negedge clk);
        write_en   = 1;
        write_addr = 4'h0;
        data_in    = 24'h123456;

        @(posedge clk);
        #1;

        if (acc_out !== 24'h123456)
            $fatal(1, "ACC write failed!");

        //----------------------------------
        // Test 3 : Invalid Address
        //----------------------------------

        @(negedge clk);
        write_addr = 4'h5;
        data_in    = 24'hABCDEF;

        @(posedge clk);
        #1;

        if (acc_out !== 24'h123456)
            $fatal(1, "Invalid address modified ACC!");

        //----------------------------------
        // Test 4 : SAV
        //----------------------------------

        @(negedge clk);
        write_en = 0;
        sav      = 1;

        @(posedge clk);
        #1;

        sav = 0;

        //----------------------------------
        // Test 5 : Change ACC
        //----------------------------------

        @(negedge clk);
        write_en   = 1;
        write_addr = 0;
        data_in    = 24'h654321;

        @(posedge clk);
        #1;

        if (acc_out !== 24'h654321)
            $fatal(1, "Second ACC write failed!");

        //----------------------------------
        // Test 6 : SWAP
        //----------------------------------

        @(negedge clk);
        write_en = 0;
        swap     = 1;

        @(posedge clk);
        #1;

        swap = 0;

        if (acc_out !== 24'h123456)
            $fatal(1, "SWAP failed!");

        //----------------------------------
        // Test 7 : Priority (SWAP > WRITE)
        //----------------------------------

        @(negedge clk);
        swap       = 1;
        write_en   = 1;
        write_addr = 0;
        data_in    = 24'hFFFFFF;

        @(posedge clk);
        #1;

        swap     = 0;
        write_en = 0;

        // چون SWAP اولویت دارد، ACC نباید FFFFFF شود.

        if (acc_out === 24'hFFFFFF)
            $fatal(1, "Priority error!");

        //----------------------------------
        // Finish
        //----------------------------------

        $display("-------------------------------------");
        $display("All RegisterFile tests PASSED.");
        $display("-------------------------------------");

        $finish;

    end

endmodule