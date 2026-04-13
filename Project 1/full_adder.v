module full_adder(
    input  A,
    input  B,
    input  Cin,
    output Sum,
    output Cout
);
    wire s1, c1, c2;

    half_adder ha0(.A(A),  .B(B),   .Sum(s1),  .Cout(c1));
    half_adder ha1(.A(s1), .B(Cin), .Sum(Sum), .Cout(c2));
    or g_cout(Cout, c1, c2);
endmodule
