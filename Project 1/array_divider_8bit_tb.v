`timescale 1ns/1ps
// Exhaustive testbench for array_divider_8bit — checks Q = A/B over all 65536 pairs.
// B=0 is tracked separately (hardware returns 0xFF).
module array_divider_8bit_tb;
    reg  [7:0] A, B;
    wire [7:0] Q;

    array_divider_8bit dut(.A(A), .B(B), .Q(Q));

    integer i, j, errors, dz_errors;
    reg [7:0] expQ;

    initial begin
        errors = 0; dz_errors = 0;
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1) begin
                A = i; B = j; #1;
                if (B == 8'h00) begin
                    expQ = 8'hFF;                 // divide-by-zero convention
                    if (Q !== expQ) dz_errors = dz_errors + 1;
                end else begin
                    expQ = A / B;
                    if (Q !== expQ) begin
                        errors = errors + 1;
                        if (errors <= 20)
                            $display("FAIL A=%0d B=%0d : Q=%0d exp=%0d", A, B, Q, expQ);
                    end
                end
            end
        if (errors == 0) $display("array_divider_8bit_tb: ALL 65280 NON-ZERO-DIVISOR VECTORS PASS");
        else             $display("array_divider_8bit_tb: %0d FAILURES (B!=0)", errors);
        $display("array_divider_8bit_tb: divide-by-zero (Q==FF) errors = %0d", dz_errors);
        $finish;
    end
endmodule
