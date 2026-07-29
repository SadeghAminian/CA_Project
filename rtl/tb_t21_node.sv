`timescale 1ns/1ps
module tb_t21_node;
    logic clk = 0, rst = 1;
    logic [10:0] port_in[0:3];
    logic        port_in_valid[0:3];
    logic        port_in_ready[0:3];
    logic [10:0] port_out[0:3];
    logic        port_out_valid[0:3];
    logic        port_out_ready[0:3];

    always #5 clk = ~clk;

    t21_node dut (.*);

    // درایور ساده برای پورت LEFT (index 0) به عنوان ورودی
    task send_port(input int idx, input logic [10:0] val);
        port_in[idx] = val;
        port_in_valid[idx] = 1;
        wait(port_in_ready[idx]);
        @(posedge clk);
        port_in_valid[idx] = 0;
    endtask

    task recv_port(input int idx, output logic [10:0] val);
        port_out_ready[idx] = 1;
        wait(port_out_valid[idx]);
        val = port_out[idx];
        @(posedge clk);
        port_out_ready[idx] = 0;
    endtask

    initial begin
        // init
        logic [10:0] result;

        foreach(port_in[i])        port_in[i] = 0;
        foreach(port_in_valid[i])  port_in_valid[i] = 0;
        foreach(port_out_ready[i]) port_out_ready[i] = 0;
    
        @(posedge clk); rst = 0;
    
        send_port(0, 11'd42);
        recv_port(1, result);
        $display("Result = %0d (expected 47)", result);
    
        #20 $finish;
    end
endmodule
