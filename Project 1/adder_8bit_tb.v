`timescale 1ns/1ps
// Exhaustive testbench for adder_8bit — checks Sum, Cout, and signed overflow over all 65536 input pairs.
module adder_8bit_tb;
    reg  [7:0] A, B;
    wire [7:0] Sum;
    wire       Cout, overflow_V;

    adder_8bit dut(.A(A), .B(B), .Sum(Sum), .Cout(Cout), .overflow_V(overflow_V));

    integer i, j, errors;
    reg [8:0] exp;       // {Cout, Sum}
    reg       expV;

    initial begin
        errors = 0;
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1) begin
                A = i; B = j; #1;
                exp  = A + B;                                  // 9-bit, carry in [8]
                expV = (A[7] == B[7]) && (exp[7] != A[7]);     // signed overflow
                if (Sum !== exp[7:0] || Cout !== exp[8] || overflow_V !== expV) begin
                    errors = errors + 1;
                    if (errors <= 20)
                        $display("FAIL A=%0d B=%0d : Sum=%h(%h) Cout=%b(%b) V=%b(%b)",
                                 A, B, Sum, exp[7:0], Cout, exp[8], overflow_V, expV);
                end
            end
        if (errors == 0) $display("adder_8bit_tb: ALL 65536 VECTORS PASS");
        else             $display("adder_8bit_tb: %0d FAILURES", errors);
        $finish;
    end
endmodule
