module xor8 (input [7:0] A, input [7:0] B, output [7:0] C)

    xor g0(C[0], A[0], B[0]);
    xor g1(C[1], A[1], B[1]);
    xor g2(C[2], A[2], B[2]);
    xor g3(C[3], A[3], B[3]);
    xor g4(C[4], A[4], B[4]);
    xor g5(C[5], A[5], B[5]);
    xor g6(C[6], A[6], B[6]);
    xor g7(C[7], A[7], B[7]);

endmodule