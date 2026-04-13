// 8-bit ripple-carry adder
// overflow_V = carry_into_bit7 XOR carry_out_of_bit7 (signed overflow flag)
module adder_8bit(
    input  [7:0] A,
    input  [7:0] B,
    output [7:0] Sum,
    output       Cout,
    output       overflow_V
);
    // Carry chain: c[0] = 0 (carry-in), c[1..7] = internal, c[8] = carry-out
    wire [8:0] c;

    // Tie carry-in to logic 0 using a supply0 net
    supply0 gnd;
    buf g_cin(c[0], gnd);

    full_adder fa0(.A(A[0]), .B(B[0]), .Cin(c[0]), .Sum(Sum[0]), .Cout(c[1]));
    full_adder fa1(.A(A[1]), .B(B[1]), .Cin(c[1]), .Sum(Sum[1]), .Cout(c[2]));
    full_adder fa2(.A(A[2]), .B(B[2]), .Cin(c[2]), .Sum(Sum[2]), .Cout(c[3]));
    full_adder fa3(.A(A[3]), .B(B[3]), .Cin(c[3]), .Sum(Sum[3]), .Cout(c[4]));
    full_adder fa4(.A(A[4]), .B(B[4]), .Cin(c[4]), .Sum(Sum[4]), .Cout(c[5]));
    full_adder fa5(.A(A[5]), .B(B[5]), .Cin(c[5]), .Sum(Sum[5]), .Cout(c[6]));
    full_adder fa6(.A(A[6]), .B(B[6]), .Cin(c[6]), .Sum(Sum[6]), .Cout(c[7]));
    full_adder fa7(.A(A[7]), .B(B[7]), .Cin(c[7]), .Sum(Sum[7]), .Cout(c[8]));

    // Route carry-out to output port
    buf g_cout(Cout, c[8]);

    // Signed overflow: V = carry_into_sign_bit XOR carry_out_of_sign_bit
    xor g_overflow(overflow_V, c[7], c[8]);
endmodule
