// 1-bit 2-to-1 multiplexer: out = A when sel = 0, out = B when sel = 1.
module mux2to1(
    input  A,
    input  B,
    input  sel,
    output out
);
    wire sel_n, a0, a1;

    not g_not(sel_n, sel);
    and g_a0 (a0, A, sel_n);
    and g_a1 (a1, B, sel);
    or  g_or (out, a0, a1);
endmodule
