// 8-bit ripple-carry adder with signed overflow detection.
module adder_8bit(
    input  [7:0] A,
    input  [7:0] B,
    output [7:0] Sum,
    output       Cout,
    output       overflow_V
);
    wire [8:0] c;   // carry chain: c[0] is the carry-in, c[8] the carry-out

    supply0 gnd;
    buf g_cin(c[0], gnd);   // carry-in tied to 0

    full_adder fa0(.A(A[0]), .B(B[0]), .Cin(c[0]), .Sum(Sum[0]), .Cout(c[1]));
    full_adder fa1(.A(A[1]), .B(B[1]), .Cin(c[1]), .Sum(Sum[1]), .Cout(c[2]));
    full_adder fa2(.A(A[2]), .B(B[2]), .Cin(c[2]), .Sum(Sum[2]), .Cout(c[3]));
    full_adder fa3(.A(A[3]), .B(B[3]), .Cin(c[3]), .Sum(Sum[3]), .Cout(c[4]));
    full_adder fa4(.A(A[4]), .B(B[4]), .Cin(c[4]), .Sum(Sum[4]), .Cout(c[5]));
    full_adder fa5(.A(A[5]), .B(B[5]), .Cin(c[5]), .Sum(Sum[5]), .Cout(c[6]));
    full_adder fa6(.A(A[6]), .B(B[6]), .Cin(c[6]), .Sum(Sum[6]), .Cout(c[7]));
    full_adder fa7(.A(A[7]), .B(B[7]), .Cin(c[7]), .Sum(Sum[7]), .Cout(c[8]));

    buf g_cout(Cout, c[8]);
    xor g_overflow(overflow_V, c[7], c[8]);
endmodule
