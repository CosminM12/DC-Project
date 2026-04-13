// 8-bit logical left barrel shifter
// Shifts A left by shift_amt[2:0] positions (0 to 7).
// Built from three stages of 2-to-1 mux instances:
//   Stage 0: shift by 1 if shift_amt[0] = 1
//   Stage 1: shift by 2 if shift_amt[1] = 1
//   Stage 2: shift by 4 if shift_amt[2] = 1
// Bits shifted in from the right are always 0 (logical shift).
module barrel_shifter_left(
    input  [7:0] A,
    input  [2:0] shift_amt,
    output [7:0] C
);
    // Intermediate wires after each stage
    wire [7:0] s0;   // after stage 0
    wire [7:0] s1;   // after stage 1

    // -------------------------------------------------------
    // Stage 0: shift by 1 if shift_amt[0]
    // s0[i] = A[i]   when shift_amt[0]=0  (no shift)
    // s0[i] = A[i-1] when shift_amt[0]=1  (shift left 1)
    // s0[0] gets 0 when shifting (nothing to shift in)
    // -------------------------------------------------------
    mux2to1 s0_b0(.A(A[0]), .B(1'b0),  .sel(shift_amt[0]), .out(s0[0]));
    mux2to1 s0_b1(.A(A[1]), .B(A[0]),  .sel(shift_amt[0]), .out(s0[1]));
    mux2to1 s0_b2(.A(A[2]), .B(A[1]),  .sel(shift_amt[0]), .out(s0[2]));
    mux2to1 s0_b3(.A(A[3]), .B(A[2]),  .sel(shift_amt[0]), .out(s0[3]));
    mux2to1 s0_b4(.A(A[4]), .B(A[3]),  .sel(shift_amt[0]), .out(s0[4]));
    mux2to1 s0_b5(.A(A[5]), .B(A[4]),  .sel(shift_amt[0]), .out(s0[5]));
    mux2to1 s0_b6(.A(A[6]), .B(A[5]),  .sel(shift_amt[0]), .out(s0[6]));
    mux2to1 s0_b7(.A(A[7]), .B(A[6]),  .sel(shift_amt[0]), .out(s0[7]));

    // -------------------------------------------------------
    // Stage 1: shift by 2 if shift_amt[1]
    // s1[i] = s0[i]   when shift_amt[1]=0
    // s1[i] = s0[i-2] when shift_amt[1]=1  (bits 0,1 get 0)
    // -------------------------------------------------------
    mux2to1 s1_b0(.A(s0[0]), .B(1'b0),  .sel(shift_amt[1]), .out(s1[0]));
    mux2to1 s1_b1(.A(s0[1]), .B(1'b0),  .sel(shift_amt[1]), .out(s1[1]));
    mux2to1 s1_b2(.A(s0[2]), .B(s0[0]), .sel(shift_amt[1]), .out(s1[2]));
    mux2to1 s1_b3(.A(s0[3]), .B(s0[1]), .sel(shift_amt[1]), .out(s1[3]));
    mux2to1 s1_b4(.A(s0[4]), .B(s0[2]), .sel(shift_amt[1]), .out(s1[4]));
    mux2to1 s1_b5(.A(s0[5]), .B(s0[3]), .sel(shift_amt[1]), .out(s1[5]));
    mux2to1 s1_b6(.A(s0[6]), .B(s0[4]), .sel(shift_amt[1]), .out(s1[6]));
    mux2to1 s1_b7(.A(s0[7]), .B(s0[5]), .sel(shift_amt[1]), .out(s1[7]));

    // -------------------------------------------------------
    // Stage 2: shift by 4 if shift_amt[2]
    // C[i] = s1[i]   when shift_amt[2]=0
    // C[i] = s1[i-4] when shift_amt[2]=1  (bits 0..3 get 0)
    // -------------------------------------------------------
    mux2to1 s2_b0(.A(s1[0]), .B(1'b0),  .sel(shift_amt[2]), .out(C[0]));
    mux2to1 s2_b1(.A(s1[1]), .B(1'b0),  .sel(shift_amt[2]), .out(C[1]));
    mux2to1 s2_b2(.A(s1[2]), .B(1'b0),  .sel(shift_amt[2]), .out(C[2]));
    mux2to1 s2_b3(.A(s1[3]), .B(1'b0),  .sel(shift_amt[2]), .out(C[3]));
    mux2to1 s2_b4(.A(s1[4]), .B(s1[0]), .sel(shift_amt[2]), .out(C[4]));
    mux2to1 s2_b5(.A(s1[5]), .B(s1[1]), .sel(shift_amt[2]), .out(C[5]));
    mux2to1 s2_b6(.A(s1[6]), .B(s1[2]), .sel(shift_amt[2]), .out(C[6]));
    mux2to1 s2_b7(.A(s1[7]), .B(s1[3]), .sel(shift_amt[2]), .out(C[7]));

endmodule
