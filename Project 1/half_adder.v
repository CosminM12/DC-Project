module half_adder(
    input  A,
    input  B,
    output Sum,
    output Cout
);
    xor g_sum  (Sum,  A, B);
    and g_carry(Cout, A, B);
endmodule
