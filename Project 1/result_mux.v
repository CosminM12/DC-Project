// Result multiplexer
// Gates each operation's 8-bit result with its one-hot enable,
// then ORs all gated buses together to produce the final output C.
//
// Since exactly one enable is high at a time, the OR simply selects
// the active result. Cosmin's operations (res_sub, res_div, res_xor,
// res_shr) are wired to 8'b0 from ALU.v until he implements them.
module result_mux(
    input  [7:0] res_and,
    input  [7:0] res_or,
    input  [7:0] res_add,
    input  [7:0] res_mul,
    input  [7:0] res_shl,
    input  [7:0] res_sub,   // Cosmin — driven 8'b0 for now
    input  [7:0] res_div,   // Cosmin — driven 8'b0 for now
    input  [7:0] res_xor,   // Cosmin — driven 8'b0 for now
    input  [7:0] res_shr,   // Cosmin — driven 8'b0 for now
    input  [8:0] en,        // one-hot enables from decoder_4to9
    output [7:0] C
);
    // -------------------------------------------------------
    // Gated result buses: each bit of each result is ANDed
    // with the corresponding enable signal (scalar AND vector).
    // -------------------------------------------------------
    wire [7:0] g_and_w, g_or_w,  g_add_w, g_mul_w, g_shl_w;
    wire [7:0] g_sub_w, g_div_w, g_xor_w, g_shr_w;

    // AND result gating (en[0])
    and g_and_0(g_and_w[0], res_and[0], en[0]);
    and g_and_1(g_and_w[1], res_and[1], en[0]);
    and g_and_2(g_and_w[2], res_and[2], en[0]);
    and g_and_3(g_and_w[3], res_and[3], en[0]);
    and g_and_4(g_and_w[4], res_and[4], en[0]);
    and g_and_5(g_and_w[5], res_and[5], en[0]);
    and g_and_6(g_and_w[6], res_and[6], en[0]);
    and g_and_7(g_and_w[7], res_and[7], en[0]);

    // OR result gating (en[1])
    and g_or_0(g_or_w[0], res_or[0], en[1]);
    and g_or_1(g_or_w[1], res_or[1], en[1]);
    and g_or_2(g_or_w[2], res_or[2], en[1]);
    and g_or_3(g_or_w[3], res_or[3], en[1]);
    and g_or_4(g_or_w[4], res_or[4], en[1]);
    and g_or_5(g_or_w[5], res_or[5], en[1]);
    and g_or_6(g_or_w[6], res_or[6], en[1]);
    and g_or_7(g_or_w[7], res_or[7], en[1]);

    // ADD result gating (en[2])
    and g_add_0(g_add_w[0], res_add[0], en[2]);
    and g_add_1(g_add_w[1], res_add[1], en[2]);
    and g_add_2(g_add_w[2], res_add[2], en[2]);
    and g_add_3(g_add_w[3], res_add[3], en[2]);
    and g_add_4(g_add_w[4], res_add[4], en[2]);
    and g_add_5(g_add_w[5], res_add[5], en[2]);
    and g_add_6(g_add_w[6], res_add[6], en[2]);
    and g_add_7(g_add_w[7], res_add[7], en[2]);

    // MUL result gating (en[3])
    and g_mul_0(g_mul_w[0], res_mul[0], en[3]);
    and g_mul_1(g_mul_w[1], res_mul[1], en[3]);
    and g_mul_2(g_mul_w[2], res_mul[2], en[3]);
    and g_mul_3(g_mul_w[3], res_mul[3], en[3]);
    and g_mul_4(g_mul_w[4], res_mul[4], en[3]);
    and g_mul_5(g_mul_w[5], res_mul[5], en[3]);
    and g_mul_6(g_mul_w[6], res_mul[6], en[3]);
    and g_mul_7(g_mul_w[7], res_mul[7], en[3]);

    // SHL result gating (en[4])
    and g_shl_0(g_shl_w[0], res_shl[0], en[4]);
    and g_shl_1(g_shl_w[1], res_shl[1], en[4]);
    and g_shl_2(g_shl_w[2], res_shl[2], en[4]);
    and g_shl_3(g_shl_w[3], res_shl[3], en[4]);
    and g_shl_4(g_shl_w[4], res_shl[4], en[4]);
    and g_shl_5(g_shl_w[5], res_shl[5], en[4]);
    and g_shl_6(g_shl_w[6], res_shl[6], en[4]);
    and g_shl_7(g_shl_w[7], res_shl[7], en[4]);

    // SUB result gating (en[5])
    and g_sub_0(g_sub_w[0], res_sub[0], en[5]);
    and g_sub_1(g_sub_w[1], res_sub[1], en[5]);
    and g_sub_2(g_sub_w[2], res_sub[2], en[5]);
    and g_sub_3(g_sub_w[3], res_sub[3], en[5]);
    and g_sub_4(g_sub_w[4], res_sub[4], en[5]);
    and g_sub_5(g_sub_w[5], res_sub[5], en[5]);
    and g_sub_6(g_sub_w[6], res_sub[6], en[5]);
    and g_sub_7(g_sub_w[7], res_sub[7], en[5]);

    // DIV result gating (en[6])
    and g_div_0(g_div_w[0], res_div[0], en[6]);
    and g_div_1(g_div_w[1], res_div[1], en[6]);
    and g_div_2(g_div_w[2], res_div[2], en[6]);
    and g_div_3(g_div_w[3], res_div[3], en[6]);
    and g_div_4(g_div_w[4], res_div[4], en[6]);
    and g_div_5(g_div_w[5], res_div[5], en[6]);
    and g_div_6(g_div_w[6], res_div[6], en[6]);
    and g_div_7(g_div_w[7], res_div[7], en[6]);

    // XOR result gating (en[7])
    and g_xor_0(g_xor_w[0], res_xor[0], en[7]);
    and g_xor_1(g_xor_w[1], res_xor[1], en[7]);
    and g_xor_2(g_xor_w[2], res_xor[2], en[7]);
    and g_xor_3(g_xor_w[3], res_xor[3], en[7]);
    and g_xor_4(g_xor_w[4], res_xor[4], en[7]);
    and g_xor_5(g_xor_w[5], res_xor[5], en[7]);
    and g_xor_6(g_xor_w[6], res_xor[6], en[7]);
    and g_xor_7(g_xor_w[7], res_xor[7], en[7]);

    // SHR result gating (en[8])
    and g_shr_0(g_shr_w[0], res_shr[0], en[8]);
    and g_shr_1(g_shr_w[1], res_shr[1], en[8]);
    and g_shr_2(g_shr_w[2], res_shr[2], en[8]);
    and g_shr_3(g_shr_w[3], res_shr[3], en[8]);
    and g_shr_4(g_shr_w[4], res_shr[4], en[8]);
    and g_shr_5(g_shr_w[5], res_shr[5], en[8]);
    and g_shr_6(g_shr_w[6], res_shr[6], en[8]);
    and g_shr_7(g_shr_w[7], res_shr[7], en[8]);

    // -------------------------------------------------------
    // OR tree: combine all 9 gated results per bit
    // Depth-4 balanced tree of 2-input OR gates
    // Structure: ((and|or)|(add|mul)) | (((shl|sub)|(div|xor))|shr)
    // -------------------------------------------------------

    // Bit 0
    wire t01_0, t23_0, t45_0, t67_0, t0123_0, t4567_0, t01234567_0;
    or g_t01_0      (t01_0,       g_and_w[0], g_or_w[0]);
    or g_t23_0      (t23_0,       g_add_w[0], g_mul_w[0]);
    or g_t45_0      (t45_0,       g_shl_w[0], g_sub_w[0]);
    or g_t67_0      (t67_0,       g_div_w[0], g_xor_w[0]);
    or g_t0123_0    (t0123_0,     t01_0,      t23_0);
    or g_t4567_0    (t4567_0,     t45_0,      t67_0);
    or g_t01234567_0(t01234567_0, t0123_0,    t4567_0);
    or g_C0         (C[0],        t01234567_0, g_shr_w[0]);

    // Bit 1
    wire t01_1, t23_1, t45_1, t67_1, t0123_1, t4567_1, t01234567_1;
    or g_t01_1      (t01_1,       g_and_w[1], g_or_w[1]);
    or g_t23_1      (t23_1,       g_add_w[1], g_mul_w[1]);
    or g_t45_1      (t45_1,       g_shl_w[1], g_sub_w[1]);
    or g_t67_1      (t67_1,       g_div_w[1], g_xor_w[1]);
    or g_t0123_1    (t0123_1,     t01_1,      t23_1);
    or g_t4567_1    (t4567_1,     t45_1,      t67_1);
    or g_t01234567_1(t01234567_1, t0123_1,    t4567_1);
    or g_C1         (C[1],        t01234567_1, g_shr_w[1]);

    // Bit 2
    wire t01_2, t23_2, t45_2, t67_2, t0123_2, t4567_2, t01234567_2;
    or g_t01_2      (t01_2,       g_and_w[2], g_or_w[2]);
    or g_t23_2      (t23_2,       g_add_w[2], g_mul_w[2]);
    or g_t45_2      (t45_2,       g_shl_w[2], g_sub_w[2]);
    or g_t67_2      (t67_2,       g_div_w[2], g_xor_w[2]);
    or g_t0123_2    (t0123_2,     t01_2,      t23_2);
    or g_t4567_2    (t4567_2,     t45_2,      t67_2);
    or g_t01234567_2(t01234567_2, t0123_2,    t4567_2);
    or g_C2         (C[2],        t01234567_2, g_shr_w[2]);

    // Bit 3
    wire t01_3, t23_3, t45_3, t67_3, t0123_3, t4567_3, t01234567_3;
    or g_t01_3      (t01_3,       g_and_w[3], g_or_w[3]);
    or g_t23_3      (t23_3,       g_add_w[3], g_mul_w[3]);
    or g_t45_3      (t45_3,       g_shl_w[3], g_sub_w[3]);
    or g_t67_3      (t67_3,       g_div_w[3], g_xor_w[3]);
    or g_t0123_3    (t0123_3,     t01_3,      t23_3);
    or g_t4567_3    (t4567_3,     t45_3,      t67_3);
    or g_t01234567_3(t01234567_3, t0123_3,    t4567_3);
    or g_C3         (C[3],        t01234567_3, g_shr_w[3]);

    // Bit 4
    wire t01_4, t23_4, t45_4, t67_4, t0123_4, t4567_4, t01234567_4;
    or g_t01_4      (t01_4,       g_and_w[4], g_or_w[4]);
    or g_t23_4      (t23_4,       g_add_w[4], g_mul_w[4]);
    or g_t45_4      (t45_4,       g_shl_w[4], g_sub_w[4]);
    or g_t67_4      (t67_4,       g_div_w[4], g_xor_w[4]);
    or g_t0123_4    (t0123_4,     t01_4,      t23_4);
    or g_t4567_4    (t4567_4,     t45_4,      t67_4);
    or g_t01234567_4(t01234567_4, t0123_4,    t4567_4);
    or g_C4         (C[4],        t01234567_4, g_shr_w[4]);

    // Bit 5
    wire t01_5, t23_5, t45_5, t67_5, t0123_5, t4567_5, t01234567_5;
    or g_t01_5      (t01_5,       g_and_w[5], g_or_w[5]);
    or g_t23_5      (t23_5,       g_add_w[5], g_mul_w[5]);
    or g_t45_5      (t45_5,       g_shl_w[5], g_sub_w[5]);
    or g_t67_5      (t67_5,       g_div_w[5], g_xor_w[5]);
    or g_t0123_5    (t0123_5,     t01_5,      t23_5);
    or g_t4567_5    (t4567_5,     t45_5,      t67_5);
    or g_t01234567_5(t01234567_5, t0123_5,    t4567_5);
    or g_C5         (C[5],        t01234567_5, g_shr_w[5]);

    // Bit 6
    wire t01_6, t23_6, t45_6, t67_6, t0123_6, t4567_6, t01234567_6;
    or g_t01_6      (t01_6,       g_and_w[6], g_or_w[6]);
    or g_t23_6      (t23_6,       g_add_w[6], g_mul_w[6]);
    or g_t45_6      (t45_6,       g_shl_w[6], g_sub_w[6]);
    or g_t67_6      (t67_6,       g_div_w[6], g_xor_w[6]);
    or g_t0123_6    (t0123_6,     t01_6,      t23_6);
    or g_t4567_6    (t4567_6,     t45_6,      t67_6);
    or g_t01234567_6(t01234567_6, t0123_6,    t4567_6);
    or g_C6         (C[6],        t01234567_6, g_shr_w[6]);

    // Bit 7
    wire t01_7, t23_7, t45_7, t67_7, t0123_7, t4567_7, t01234567_7;
    or g_t01_7      (t01_7,       g_and_w[7], g_or_w[7]);
    or g_t23_7      (t23_7,       g_add_w[7], g_mul_w[7]);
    or g_t45_7      (t45_7,       g_shl_w[7], g_sub_w[7]);
    or g_t67_7      (t67_7,       g_div_w[7], g_xor_w[7]);
    or g_t0123_7    (t0123_7,     t01_7,      t23_7);
    or g_t4567_7    (t4567_7,     t45_7,      t67_7);
    or g_t01234567_7(t01234567_7, t0123_7,    t4567_7);
    or g_C7         (C[7],        t01234567_7, g_shr_w[7]);

endmodule
