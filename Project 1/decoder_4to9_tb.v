`timescale 1ns/1ps
// Self-checking testbench for decoder_4to9, all 16 opcodes.
// op 0..8 give one-hot en[op] = 1; op 9..15 give en = 0.
module decoder_4to9_tb;
    reg  [3:0] op;
    wire [8:0] en;

    decoder_4to9 dut(.op(op), .en(en));

    integer k, errors;
    reg [8:0] expEn;

    initial begin
        errors = 0;
        for (k = 0; k < 16; k = k + 1) begin
            op = k; #1;
            expEn = 9'b0;
            if (k <= 8) expEn[k] = 1'b1;
            if (en !== expEn) begin
                errors = errors + 1;
                $display("FAIL op=%h : en=%b exp=%b", op, en, expEn);
            end
        end
        if (errors == 0) $display("decoder_4to9_tb: ALL 16 OPCODES PASS");
        else             $display("decoder_4to9_tb: %0d FAILURES", errors);
        $finish;
    end
endmodule
