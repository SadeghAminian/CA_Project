module stack_mem #(
    parameter DATA_WIDTH = 24,
    parameter DEPTH = 15
)(
    input  logic clk,
    input  logic rst,

    input  logic push_en,
    input  logic pop_en,

    input  logic signed [DATA_WIDTH-1:0] data_in,
    output logic signed [DATA_WIDTH-1:0] data_out,

    output logic is_empty,
    output logic is_full
);

    logic signed [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [$clog2(DEPTH+1)-1:0] sp;

    assign is_empty = (sp == 0);
    assign is_full  = (sp == DEPTH);
    assign data_out = is_empty ? 'sd0 : mem[sp - 1];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sp <= '0;
        end else begin
            if (push_en && !is_full) begin
                mem[sp] <= data_in;
                sp <= sp + 1'b1;
            end else if (pop_en && !is_empty) begin
                sp <= sp - 1'b1;
            end
        end
    end

endmodule
