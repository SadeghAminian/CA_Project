module instr_mem #(
    parameter int PROGRAM_SIZE = 16,
    parameter string INIT_FILE = ""
) (
    input  logic [3:0]  addr,
    output logic [23:0] instr
);
    logic [23:0] mem [0:PROGRAM_SIZE-1];

    initial begin
        integer i;

        assert (PROGRAM_SIZE >= 1)
        else $fatal(1, "PROGRAM_SIZE must be at least 1");

        assert (PROGRAM_SIZE <= 16)
        else $fatal(1, "PROGRAM_SIZE cannot exceed 16 with a 4-bit PC");

        for (i = 0; i < PROGRAM_SIZE; i = i + 1) begin
            mem[i] = 24'd0;
        end

        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    always_comb begin
        if (int'(addr) < PROGRAM_SIZE) begin
            instr = mem[addr];
        end else begin
            instr = 24'd0;
        end
    end
endmodule
