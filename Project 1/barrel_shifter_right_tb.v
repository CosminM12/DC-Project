`timescale 1ns/1ps
// Exhaustive self-checking testbench for barrel_shifter_right (C = A >> amt).
module barrel_shifter_right_tb;
    reg  [7:0] A;
    reg  [2:0] amt;
    wire [7:0] C;

    barrel_shifter_right dut(.A(A), .shift_amt(amt), .C(C));

    integer i, s, errors;
    reg [7:0] expC;

    initial begin
        errors = 0;
        for (i = 0; i < 256; i = i + 1)
            for (s = 0; s < 8; s = s + 1) begin
                A = i; amt = s; #1;
                expC = A >> amt;            // logical right shift
                if (C !== expC) begin
                    errors = errors + 1;
                    if (errors <= 20)
                        $display("FAIL A=%b amt=%0d : C=%b exp=%b", A, amt, C, expC);
                end
            end
        if (errors == 0) $display("barrel_shifter_right_tb: ALL 2048 VECTORS PASS");
        else             $display("barrel_shifter_right_tb: %0d FAILURES", errors);
        $finish;
    end
endmodule
