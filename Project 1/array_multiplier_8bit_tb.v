`timescale 1ns/1ps
// Exhaustive self-checking testbench for array_multiplier_8bit (low 8 bits of A*B).
module array_multiplier_8bit_tb;
    reg  [7:0] A, B;
    wire [7:0] P;

    array_multiplier_8bit dut(.A(A), .B(B), .P(P));

    integer i, j, errors;
    reg [15:0] prod;

    initial begin
        errors = 0;
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1) begin
                A = i; B = j; #1;
                prod = A * B;                 // full 16-bit product
                if (P !== prod[7:0]) begin    // DUT keeps low 8 bits
                    errors = errors + 1;
                    if (errors <= 20)
                        $display("FAIL A=%0d B=%0d : P=%h exp=%h (full=%0d)",
                                 A, B, P, prod[7:0], prod);
                end
            end
        if (errors == 0) $display("array_multiplier_8bit_tb: ALL 65536 VECTORS PASS (low 8 bits)");
        else             $display("array_multiplier_8bit_tb: %0d FAILURES", errors);
        $finish;
    end
endmodule
