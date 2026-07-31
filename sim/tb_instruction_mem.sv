`timescale 1ns/1ps

module instr_mem_tb;

    localparam DATA_WIDTH = 24;
    localparam ADDR_WIDTH = 4;
    localparam SIZE       = 1 << ADDR_WIDTH;

    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] instr;

    // DUT
    instr_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .FILE_NAME("program.hex")  // Repalce it by your .hex absolute address
    ) dut (
        .addr(addr),
        .instr(instr)
    );

    logic [DATA_WIDTH-1:0] expected [0:SIZE-1];

    initial begin
        for (int i=0; i<SIZE; i++)
            expected[i] = '0;
            
        $readmemh("program.hex", expected);

        $display("------------------------------------------");
        $display(" Instruction Memory Test Started");
        $display("------------------------------------------");
        for (int i = 0; i < 10; i++) begin
            addr = i;
            #1;

            assert (instr === expected[i])
                else $fatal(
                    "Mismatch at address %0d: expected=%06h got=%06h",
                    i, expected[i], instr
                );
        end

        $display("All 10 instructions verified successfully.");
        $finish;
    end

endmodule