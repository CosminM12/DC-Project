// 8x8 array multiplier, keeps the low 8 bits of A*B.
// Partial product pp_i_j = A[j] and B[i] has weight 2^(i+j); only the
// products with i+j <= 7 reach the low 8 bits. Each row is packed into an
// 8-bit vector (zero-padded by its weight) and the rows are summed by a
// chain of 8-bit adders, with the carry-out of each adder discarded.
module array_multiplier_8bit(
    input  [7:0] A,
    input  [7:0] B,
    output [7:0] P
);
    supply0 gnd;   // constant 0 used for zero-padding

    // partial products pp_i_j = A[j] and B[i]
    wire pp_0_0, pp_0_1, pp_0_2, pp_0_3, pp_0_4, pp_0_5, pp_0_6, pp_0_7;
    wire pp_1_0, pp_1_1, pp_1_2, pp_1_3, pp_1_4, pp_1_5, pp_1_6;
    wire pp_2_0, pp_2_1, pp_2_2, pp_2_3, pp_2_4, pp_2_5;
    wire pp_3_0, pp_3_1, pp_3_2, pp_3_3, pp_3_4;
    wire pp_4_0, pp_4_1, pp_4_2, pp_4_3;
    wire pp_5_0, pp_5_1, pp_5_2;
    wire pp_6_0, pp_6_1;
    wire pp_7_0;

    and g_00(pp_0_0, A[0], B[0]);
    and g_01(pp_0_1, A[1], B[0]);
    and g_02(pp_0_2, A[2], B[0]);
    and g_03(pp_0_3, A[3], B[0]);
    and g_04(pp_0_4, A[4], B[0]);
    and g_05(pp_0_5, A[5], B[0]);
    and g_06(pp_0_6, A[6], B[0]);
    and g_07(pp_0_7, A[7], B[0]);

    and g_10(pp_1_0, A[0], B[1]);
    and g_11(pp_1_1, A[1], B[1]);
    and g_12(pp_1_2, A[2], B[1]);
    and g_13(pp_1_3, A[3], B[1]);
    and g_14(pp_1_4, A[4], B[1]);
    and g_15(pp_1_5, A[5], B[1]);
    and g_16(pp_1_6, A[6], B[1]);

    and g_20(pp_2_0, A[0], B[2]);
    and g_21(pp_2_1, A[1], B[2]);
    and g_22(pp_2_2, A[2], B[2]);
    and g_23(pp_2_3, A[3], B[2]);
    and g_24(pp_2_4, A[4], B[2]);
    and g_25(pp_2_5, A[5], B[2]);

    and g_30(pp_3_0, A[0], B[3]);
    and g_31(pp_3_1, A[1], B[3]);
    and g_32(pp_3_2, A[2], B[3]);
    and g_33(pp_3_3, A[3], B[3]);
    and g_34(pp_3_4, A[4], B[3]);

    and g_40(pp_4_0, A[0], B[4]);
    and g_41(pp_4_1, A[1], B[4]);
    and g_42(pp_4_2, A[2], B[4]);
    and g_43(pp_4_3, A[3], B[4]);

    and g_50(pp_5_0, A[0], B[5]);
    and g_51(pp_5_1, A[1], B[5]);
    and g_52(pp_5_2, A[2], B[5]);

    and g_60(pp_6_0, A[0], B[6]);
    and g_61(pp_6_1, A[1], B[6]);

    and g_70(pp_7_0, A[0], B[7]);

    // each row is shifted left by its index (low bits filled with 0)
    wire [7:0] row0_vec, row1_vec, row2_vec, row3_vec;
    wire [7:0] row4_vec, row5_vec, row6_vec, row7_vec;

    buf b_r0_0(row0_vec[0], pp_0_0);
    buf b_r0_1(row0_vec[1], pp_0_1);
    buf b_r0_2(row0_vec[2], pp_0_2);
    buf b_r0_3(row0_vec[3], pp_0_3);
    buf b_r0_4(row0_vec[4], pp_0_4);
    buf b_r0_5(row0_vec[5], pp_0_5);
    buf b_r0_6(row0_vec[6], pp_0_6);
    buf b_r0_7(row0_vec[7], pp_0_7);

    buf b_r1_0(row1_vec[0], gnd);
    buf b_r1_1(row1_vec[1], pp_1_0);
    buf b_r1_2(row1_vec[2], pp_1_1);
    buf b_r1_3(row1_vec[3], pp_1_2);
    buf b_r1_4(row1_vec[4], pp_1_3);
    buf b_r1_5(row1_vec[5], pp_1_4);
    buf b_r1_6(row1_vec[6], pp_1_5);
    buf b_r1_7(row1_vec[7], pp_1_6);

    buf b_r2_0(row2_vec[0], gnd);
    buf b_r2_1(row2_vec[1], gnd);
    buf b_r2_2(row2_vec[2], pp_2_0);
    buf b_r2_3(row2_vec[3], pp_2_1);
    buf b_r2_4(row2_vec[4], pp_2_2);
    buf b_r2_5(row2_vec[5], pp_2_3);
    buf b_r2_6(row2_vec[6], pp_2_4);
    buf b_r2_7(row2_vec[7], pp_2_5);

    buf b_r3_0(row3_vec[0], gnd);
    buf b_r3_1(row3_vec[1], gnd);
    buf b_r3_2(row3_vec[2], gnd);
    buf b_r3_3(row3_vec[3], pp_3_0);
    buf b_r3_4(row3_vec[4], pp_3_1);
    buf b_r3_5(row3_vec[5], pp_3_2);
    buf b_r3_6(row3_vec[6], pp_3_3);
    buf b_r3_7(row3_vec[7], pp_3_4);

    buf b_r4_0(row4_vec[0], gnd);
    buf b_r4_1(row4_vec[1], gnd);
    buf b_r4_2(row4_vec[2], gnd);
    buf b_r4_3(row4_vec[3], gnd);
    buf b_r4_4(row4_vec[4], pp_4_0);
    buf b_r4_5(row4_vec[5], pp_4_1);
    buf b_r4_6(row4_vec[6], pp_4_2);
    buf b_r4_7(row4_vec[7], pp_4_3);

    buf b_r5_0(row5_vec[0], gnd);
    buf b_r5_1(row5_vec[1], gnd);
    buf b_r5_2(row5_vec[2], gnd);
    buf b_r5_3(row5_vec[3], gnd);
    buf b_r5_4(row5_vec[4], gnd);
    buf b_r5_5(row5_vec[5], pp_5_0);
    buf b_r5_6(row5_vec[6], pp_5_1);
    buf b_r5_7(row5_vec[7], pp_5_2);

    buf b_r6_0(row6_vec[0], gnd);
    buf b_r6_1(row6_vec[1], gnd);
    buf b_r6_2(row6_vec[2], gnd);
    buf b_r6_3(row6_vec[3], gnd);
    buf b_r6_4(row6_vec[4], gnd);
    buf b_r6_5(row6_vec[5], gnd);
    buf b_r6_6(row6_vec[6], pp_6_0);
    buf b_r6_7(row6_vec[7], pp_6_1);

    buf b_r7_0(row7_vec[0], gnd);
    buf b_r7_1(row7_vec[1], gnd);
    buf b_r7_2(row7_vec[2], gnd);
    buf b_r7_3(row7_vec[3], gnd);
    buf b_r7_4(row7_vec[4], gnd);
    buf b_r7_5(row7_vec[5], gnd);
    buf b_r7_6(row7_vec[6], gnd);
    buf b_r7_7(row7_vec[7], pp_7_0);

    // add the rows together; carry-out and overflow of each stage are unused
    wire [7:0] acc0, acc1, acc2, acc3, acc4, acc5;
    wire cout0, cout1, cout2, cout3, cout4, cout5, cout6;
    wire ov0,   ov1,   ov2,   ov3,   ov4,   ov5,   ov6;

    adder_8bit add0(.A(row0_vec), .B(row1_vec), .Sum(acc0), .Cout(cout0), .overflow_V(ov0));
    adder_8bit add1(.A(acc0),     .B(row2_vec), .Sum(acc1), .Cout(cout1), .overflow_V(ov1));
    adder_8bit add2(.A(acc1),     .B(row3_vec), .Sum(acc2), .Cout(cout2), .overflow_V(ov2));
    adder_8bit add3(.A(acc2),     .B(row4_vec), .Sum(acc3), .Cout(cout3), .overflow_V(ov3));
    adder_8bit add4(.A(acc3),     .B(row5_vec), .Sum(acc4), .Cout(cout4), .overflow_V(ov4));
    adder_8bit add5(.A(acc4),     .B(row6_vec), .Sum(acc5), .Cout(cout5), .overflow_V(ov5));
    adder_8bit add6(.A(acc5),     .B(row7_vec), .Sum(P),    .Cout(cout6), .overflow_V(ov6));
endmodule
