module and8(
    input  [7:0] A,
    input  [7:0] B,
    output [7:0] C
);
    and g0(C[0], A[0], B[0]);
    and g1(C[1], A[1], B[1]);
    and g2(C[2], A[2], B[2]);
    and g3(C[3], A[3], B[3]);
    and g4(C[4], A[4], B[4]);
    and g5(C[5], A[5], B[5]);
    and g6(C[6], A[6], B[6]);
    and g7(C[7], A[7], B[7]);
endmodule
