// Status flag generator.
//   Z = 1 when the result is zero
//   N = 1 when the result is negative (MSB = 1)
//   V = 1 on signed overflow, only for ADD or SUB (gated by en_add / en_sub)
module flag_gen(
    input  [7:0] C,
    input        add_overflow_V,  // overflow from adder_8bit
    input        sub_overflow_V,  // overflow from subtractor_8bit
    input        en_add,          // en[2], high only during ADD
    input        en_sub,          // en[5], high only during SUB
    output       Z,
    output       N,
    output       V
);
    // Z = NOR of all result bits, built as an OR tree plus a final NOT
    wire or01, or23, or45, or67, or0123, or4567, or_all;
    or  g_or01  (or01,   C[0], C[1]);
    or  g_or23  (or23,   C[2], C[3]);
    or  g_or45  (or45,   C[4], C[5]);
    or  g_or67  (or67,   C[6], C[7]);
    or  g_or0123(or0123, or01,   or23);
    or  g_or4567(or4567, or45,   or67);
    or  g_orall (or_all, or0123, or4567);
    not g_Z     (Z,      or_all);

    // N = sign bit of the result
    buf g_N(N, C[7]);

    // V = (adder overflow during ADD) OR (subtractor overflow during SUB)
    wire v_add, v_sub;
    and g_Vadd(v_add, add_overflow_V, en_add);
    and g_Vsub(v_sub, sub_overflow_V, en_sub);
    or  g_V   (V,     v_add,          v_sub);
endmodule
