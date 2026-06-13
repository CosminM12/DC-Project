// 8-bit unsigned restoring array divider, quotient Q = A / B.
// Eight identical stages process the dividend from the MSB down. The running
// remainder starts at 0 and stays below B, so it is carried in 8 bits.
// The final remainder (r0) equals A % B but is not output, since the ALU only
// needs an 8-bit result. If B = 0 every stage sets its quotient bit, so the
// result is Q = 0xFF (a defined but meaningless divide-by-zero value).
module array_divider_8bit(
    input  [7:0] A,   // dividend
    input  [7:0] B,   // divisor
    output [7:0] Q    // quotient
);
    wire [7:0] r7, r6, r5, r4, r3, r2, r1, r0;   // remainder after each stage

    div_stage_restoring ds7(.R_in(8'b0), .a(A[7]), .D(B), .R_out(r7), .Q_bit(Q[7]));
    div_stage_restoring ds6(.R_in(r7),   .a(A[6]), .D(B), .R_out(r6), .Q_bit(Q[6]));
    div_stage_restoring ds5(.R_in(r6),   .a(A[5]), .D(B), .R_out(r5), .Q_bit(Q[5]));
    div_stage_restoring ds4(.R_in(r5),   .a(A[4]), .D(B), .R_out(r4), .Q_bit(Q[4]));
    div_stage_restoring ds3(.R_in(r4),   .a(A[3]), .D(B), .R_out(r3), .Q_bit(Q[3]));
    div_stage_restoring ds2(.R_in(r3),   .a(A[2]), .D(B), .R_out(r2), .Q_bit(Q[2]));
    div_stage_restoring ds1(.R_in(r2),   .a(A[1]), .D(B), .R_out(r1), .Q_bit(Q[1]));
    div_stage_restoring ds0(.R_in(r1),   .a(A[0]), .D(B), .R_out(r0), .Q_bit(Q[0]));
endmodule
