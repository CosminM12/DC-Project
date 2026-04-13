// 1-bit 2-to-1 multiplexer
// out = A when sel=0, out = B when sel=1
module mux2to1(
    input  A,
    input  B,
    input  sel,
    output out
);
    wire sel_n, and0_out, and1_out;

    not g_not  (sel_n,    sel);
    and g_and0 (and0_out, A, sel_n);
    and g_and1 (and1_out, B, sel);
    or  g_or   (out, and0_out, and1_out);
endmodule
