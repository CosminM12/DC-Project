module or8(
    input  [7:0] A,
    input  [7:0] B,
    output [7:0] C
);
    or g0(C[0], A[0], B[0]);
    or g1(C[1], A[1], B[1]);
    or g2(C[2], A[2], B[2]);
    or g3(C[3], A[3], B[3]);
    or g4(C[4], A[4], B[4]);
    or g5(C[5], A[5], B[5]);
    or g6(C[6], A[6], B[6]);
    or g7(C[7], A[7], B[7]);
endmodule
