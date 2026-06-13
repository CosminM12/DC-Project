`timescale 1ns/1ps
// Exhaustive self-checking testbench for subtractor_8bit (Diff, signed V).
module subtractor_8bit_tb;
    reg  [7:0] A, B;
    wire [7:0] Diff;
    wire       overflow;

    subtractor_8bit dut(.A(A), .B(B), .Diff(Diff), .overflow(overflow));

    integer i, j, errors;
    reg [7:0] expD;
    reg       expV;

    initial begin
        errors = 0;
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1) begin
                A = i; B = j; #1;
                expD = A - B;
                expV = (A[7] != B[7]) && (expD[7] != A[7]);    // signed sub overflow
                if (Diff !== expD || overflow !== expV) begin
                    errors = errors + 1;
                    if (errors <= 20)
                        $display("FAIL A=%0d B=%0d : Diff=%h(%h) V=%b(%b)",
                                 A, B, Diff, expD, overflow, expV);
                end
            end
        if (errors == 0) $display("subtractor_8bit_tb: ALL 65536 VECTORS PASS");
        else             $display("subtractor_8bit_tb: %0d FAILURES", errors);
        $finish;
    end
endmodule
