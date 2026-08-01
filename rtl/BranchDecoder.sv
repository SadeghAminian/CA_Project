module BranchDecoder (
    input  logic [3:0] opCode,
    input  logic Z,  // Zero Flag
    input  logic S,  // Sign Flag
    output logic branchTaken
);

    always_comb begin
        branchTaken = 1'b0;
        
        case (opCode)
            4'h7: begin // JMP
                branchTaken = 1'b1;
            end
            4'h8: begin // JEZ
                branchTaken = Z;
            end
            4'h9: begin // JNZ
                branchTaken = !Z;
            end
            4'hA: begin // JGZ
                branchTaken = (!Z & !S);
            end
            4'hB: begin // JLZ
                branchTaken = (!Z & S);
            end
            4'hC: begin // JRO
                branchTaken = 1'b1; 
            end
            default: begin
                branchTaken = 1'b0;
            end
        endcase
    end

endmodule