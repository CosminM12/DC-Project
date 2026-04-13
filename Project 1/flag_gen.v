// Status flag generator
//
// Z (Zero)     : 1 if the result C is all zeros
// N (Negative) : 1 if the MSB of C is 1 (2's complement sign bit)
// V (Overflow) : 1 if a signed overflow occurred in ADD;
//                0 for all other operations (gated by en_add)
module flag_gen(
    input  [7:0] C,
    input        add_overflow_V,  // overflow signal from adder_8bit
    input        en_add,          // en[2] from decoder — high only during ADD
    output       Z,
    output       N,
    output       V
);
    // -------------------------------------------------------
    // Z: NOR of all bits of C
    // Implemented as a balanced tree of OR gates + final NOT
    // -------------------------------------------------------
    wire or01, or23, or45, or67, or0123, or4567, or_all;

    or  g_or01  (or01,   C[0], C[1]);
    or  g_or23  (or23,   C[2], C[3]);
    or  g_or45  (or45,   C[4], C[5]);
    or  g_or67  (or67,   C[6], C[7]);
    or  g_or0123(or0123, or01,   or23);
    or  g_or4567(or4567, or45,   or67);
    or  g_orall (or_all, or0123, or4567);
    not g_Z     (Z,      or_all);

    // -------------------------------------------------------
    // N: sign bit (MSB) of result
    // -------------------------------------------------------
    buf g_N(N, C[7]);

    // -------------------------------------------------------
    // V: overflow is only meaningful for ADD
    //    Gate the adder's overflow signal with en_add
    // -------------------------------------------------------
    and g_V(V, add_overflow_V, en_add);
endmodule
