module inst_mem #(
    parameter DATA_WIDTH = 24,
    parameter ADDR_WIDTH = 8,
    parameter SIZE = 256,
    parameter string FILE_NAME = "default.hex"
)(
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] instr
);

    logic [DATA_WIDTH-1:0] mem [0:SIZE-1];

    initial begin
        for (int i = 0; i < SIZE; i++) begin
            mem[i] = {DATA_WIDTH{1'b0}};
        end
        $readmemh(FILE_NAME, mem);
    end

    assign instr = mem[addr];

endmodule