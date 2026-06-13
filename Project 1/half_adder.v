// Half adder: Sum = A xor B, Cout = A and B.
module half_adder(
    input  A,
    input  B,
    output Sum,
    output Cout
);
    xor g_sum  (Sum,  A, B);
    and g_carry(Cout, A, B);
endmodule
