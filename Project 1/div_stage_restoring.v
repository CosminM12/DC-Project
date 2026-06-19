// Single stage of a restoring array divider.
// Shifts in the next dividend bit at the LSB, subtracts the divisor,
// and uses the carry-out as the quotient bit. If the subtraction
// underflows, the old partial remainder is restored via mux.
module div_stage_restoring(
    input  [7:0] R_in,    // remainder from the previous stage (R_in < D)
    input        a,       // next dividend bit shifted in at the LSB
    input  [7:0] D,       // divisor
    output [7:0] R_out,   // remainder passed to the next stage
    output       Q_bit    // quotient bit produced here
);
    // S = (R_in << 1) | a
    wire [8:0] S;
    buf bs0(S[0], a);
    buf bs1(S[1], R_in[0]);
    buf bs2(S[2], R_in[1]);
    buf bs3(S[3], R_in[2]);
    buf bs4(S[4], R_in[3]);
    buf bs5(S[5], R_in[4]);
    buf bs6(S[6], R_in[5]);
    buf bs7(S[7], R_in[6]);
    buf bs8(S[8], R_in[7]);

    // one's complement of D (the 9th bit of ~D is constant 1, fed in below)
    wire [7:0] nd;
    not n0(nd[0], D[0]);
    not n1(nd[1], D[1]);
    not n2(nd[2], D[2]);
    not n3(nd[3], D[3]);
    not n4(nd[4], D[4]);
    not n5(nd[5], D[5]);
    not n6(nd[6], D[6]);
    not n7(nd[7], D[7]);

    // 9-bit subtract S + (~D) + 1; cy[9] = 1 means S >= D
    wire [9:1] cy;
    wire [8:0] diff;
    full_adder fa0(.A(S[0]), .B(nd[0]), .Cin(1'b1),  .Sum(diff[0]), .Cout(cy[1]));
    full_adder fa1(.A(S[1]), .B(nd[1]), .Cin(cy[1]), .Sum(diff[1]), .Cout(cy[2]));
    full_adder fa2(.A(S[2]), .B(nd[2]), .Cin(cy[2]), .Sum(diff[2]), .Cout(cy[3]));
    full_adder fa3(.A(S[3]), .B(nd[3]), .Cin(cy[3]), .Sum(diff[3]), .Cout(cy[4]));
    full_adder fa4(.A(S[4]), .B(nd[4]), .Cin(cy[4]), .Sum(diff[4]), .Cout(cy[5]));
    full_adder fa5(.A(S[5]), .B(nd[5]), .Cin(cy[5]), .Sum(diff[5]), .Cout(cy[6]));
    full_adder fa6(.A(S[6]), .B(nd[6]), .Cin(cy[6]), .Sum(diff[6]), .Cout(cy[7]));
    full_adder fa7(.A(S[7]), .B(nd[7]), .Cin(cy[7]), .Sum(diff[7]), .Cout(cy[8]));
    full_adder fa8(.A(S[8]), .B(1'b1),  .Cin(cy[8]), .Sum(diff[8]), .Cout(cy[9]));

    buf bq(Q_bit, cy[9]);

    // R_out = Q_bit ? (S - D) : S
    mux2to1 m0(.A(S[0]), .B(diff[0]), .sel(Q_bit), .out(R_out[0]));
    mux2to1 m1(.A(S[1]), .B(diff[1]), .sel(Q_bit), .out(R_out[1]));
    mux2to1 m2(.A(S[2]), .B(diff[2]), .sel(Q_bit), .out(R_out[2]));
    mux2to1 m3(.A(S[3]), .B(diff[3]), .sel(Q_bit), .out(R_out[3]));
    mux2to1 m4(.A(S[4]), .B(diff[4]), .sel(Q_bit), .out(R_out[4]));
    mux2to1 m5(.A(S[5]), .B(diff[5]), .sel(Q_bit), .out(R_out[5]));
    mux2to1 m6(.A(S[6]), .B(diff[6]), .sel(Q_bit), .out(R_out[6]));
    mux2to1 m7(.A(S[7]), .B(diff[7]), .sel(Q_bit), .out(R_out[7]));
endmodule
