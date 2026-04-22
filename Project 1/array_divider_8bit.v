module array_divider_8bit(
    input  [7:0] A, // Dividend
    input  [7:0] B, // Divisor
    output [7:0] Q  // Quotient
);
    wire [7:0] r7, r6, r5, r4, r3, r2, r1, r0;
    wire [7:0] in7, in6, in5, in4, in3, in2, in1, in0;
    wire q7_n, q6_n, q5_n, q4_n, q3_n, q2_n, q1_n;
    
    supply0 gnd;
    supply1 vcc;

    // ------------------------------------------------------------------------
    // Stage 7 (MSB): Remainder starts as 0s, bring in A[7]. Initial Ctrl = 1 (Subtract)
    // ------------------------------------------------------------------------
    buf b7_0(in7[0], A[7]);
    buf b7_1(in7[1], gnd); buf b7_2(in7[2], gnd); buf b7_3(in7[3], gnd);
    buf b7_4(in7[4], gnd); buf b7_5(in7[5], gnd); buf b7_6(in7[6], gnd); buf b7_7(in7[7], gnd);
    
    div_stage_nonrestoring ds7(.R_in(in7), .D(B), .Ctrl(vcc), .R_out(r7), .Q_bit(Q[7]));

    // ------------------------------------------------------------------------
    // Stage 6: Shift left r7, bring in A[6]. Ctrl is ~Q[7]
    // ------------------------------------------------------------------------
    not g_qn7(q7_n, Q[7]);
    buf b6_0(in6[0], A[6]);
    buf b6_1(in6[1], r7[0]); buf b6_2(in6[2], r7[1]); buf b6_3(in6[3], r7[2]);
    buf b6_4(in6[4], r7[3]); buf b6_5(in6[5], r7[4]); buf b6_6(in6[6], r7[5]); buf b6_7(in6[7], r7[6]);
    
    div_stage_nonrestoring ds6(.R_in(in6), .D(B), .Ctrl(q7_n), .R_out(r6), .Q_bit(Q[6]));

    // ------------------------------------------------------------------------
    // Stage 5: Shift left r6, bring in A[5]. Ctrl is ~Q[6]
    // ------------------------------------------------------------------------
    not g_qn6(q6_n, Q[6]);
    buf b5_0(in5[0], A[5]);
    buf b5_1(in5[1], r6[0]); buf b5_2(in5[2], r6[1]); buf b5_3(in5[3], r6[2]);
    buf b5_4(in5[4], r6[3]); buf b5_5(in5[5], r6[4]); buf b5_6(in5[6], r6[5]); buf b5_7(in5[7], r6[6]);
    
    div_stage_nonrestoring ds5(.R_in(in5), .D(B), .Ctrl(q6_n), .R_out(r5), .Q_bit(Q[5]));

    // ------------------------------------------------------------------------
    // Stage 4: Shift left r5, bring in A[4]. Ctrl is ~Q[5]
    // ------------------------------------------------------------------------
    not g_qn5(q5_n, Q[5]);
    buf b4_0(in4[0], A[4]);
    buf b4_1(in4[1], r5[0]); buf b4_2(in4[2], r5[1]); buf b4_3(in4[3], r5[2]);
    buf b4_4(in4[4], r5[3]); buf b4_5(in4[5], r5[4]); buf b4_6(in4[6], r5[5]); buf b4_7(in4[7], r5[6]);
    
    div_stage_nonrestoring ds4(.R_in(in4), .D(B), .Ctrl(q5_n), .R_out(r4), .Q_bit(Q[4]));

    // ------------------------------------------------------------------------
    // Stage 3: Shift left r4, bring in A[3]. Ctrl is ~Q[4]
    // ------------------------------------------------------------------------
    not g_qn4(q4_n, Q[4]);
    buf b3_0(in3[0], A[3]);
    buf b3_1(in3[1], r4[0]); buf b3_2(in3[2], r4[1]); buf b3_3(in3[3], r4[2]);
    buf b3_4(in3[4], r4[3]); buf b3_5(in3[5], r4[4]); buf b3_6(in3[6], r4[5]); buf b3_7(in3[7], r4[6]);
    
    div_stage_nonrestoring ds3(.R_in(in3), .D(B), .Ctrl(q4_n), .R_out(r3), .Q_bit(Q[3]));

    // ------------------------------------------------------------------------
    // Stage 2: Shift left r3, bring in A[2]. Ctrl is ~Q[3]
    // ------------------------------------------------------------------------
    not g_qn3(q3_n, Q[3]);
    buf b2_0(in2[0], A[2]);
    buf b2_1(in2[1], r3[0]); buf b2_2(in2[2], r3[1]); buf b2_3(in2[3], r3[2]);
    buf b2_4(in2[4], r3[3]); buf b2_5(in2[5], r3[4]); buf b2_6(in2[6], r3[5]); buf b2_7(in2[7], r3[6]);
    
    div_stage_nonrestoring ds2(.R_in(in2), .D(B), .Ctrl(q3_n), .R_out(r2), .Q_bit(Q[2]));

    // ------------------------------------------------------------------------
    // Stage 1: Shift left r2, bring in A[1]. Ctrl is ~Q[2]
    // ------------------------------------------------------------------------
    not g_qn2(q2_n, Q[2]);
    buf b1_0(in1[0], A[1]);
    buf b1_1(in1[1], r2[0]); buf b1_2(in1[2], r2[1]); buf b1_3(in1[3], r2[2]);
    buf b1_4(in1[4], r2[3]); buf b1_5(in1[5], r2[4]); buf b1_6(in1[6], r2[5]); buf b1_7(in1[7], r2[6]);
    
    div_stage_nonrestoring ds1(.R_in(in1), .D(B), .Ctrl(q2_n), .R_out(r1), .Q_bit(Q[1]));

    // ------------------------------------------------------------------------
    // Stage 0: Shift left r1, bring in A[0]. Ctrl is ~Q[1]
    // ------------------------------------------------------------------------
    not g_qn1(q1_n, Q[1]);
    buf b0_0(in0[0], A[0]);
    buf b0_1(in0[1], r1[0]); buf b0_2(in0[2], r1[1]); buf b0_3(in0[3], r1[2]);
    buf b0_4(in0[4], r1[3]); buf b0_5(in0[5], r1[4]); buf b0_6(in0[6], r1[5]); buf b0_7(in0[7], r1[6]);
    
    div_stage_nonrestoring ds0(.R_in(in0), .D(B), .Ctrl(q1_n), .R_out(r0), .Q_bit(Q[0]));

endmodule