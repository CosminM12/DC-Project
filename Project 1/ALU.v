// Top-level 8-bit ALU.
// Inputs : two 8-bit operands A and B, a 4-bit operation selector.
// Outputs: 8-bit result C and the status flags Z (zero), N (negative),
//          V (signed overflow).
//
// operation encoding:
//   0 AND   1 OR   2 ADD   3 MUL   4 SHL
//   5 SUB   6 DIV  7 XOR   8 SHR
// MUL returns the low 8 bits of A*B, DIV returns the quotient A/B.
module ALU(
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] operation,
    output [7:0] C,
    output       Z,
    output       N,
    output       V
);
    // result coming out of each functional unit
    wire [7:0] res_and, res_or, res_xor;
    wire [7:0] res_add, res_sub, res_mul, res_div;
    wire [7:0] res_shl, res_shr;

    wire adder_cout, adder_V, sub_V;

    // one-hot enable, one bit per operation
    wire [8:0] en;

    // functional units
    and8                  u_and(.A(A), .B(B), .C(res_and));
    or8                   u_or (.A(A), .B(B), .C(res_or));
    xor8                  u_xor(.A(A), .B(B), .C(res_xor));
    adder_8bit            u_add(.A(A), .B(B), .Sum(res_add), .Cout(adder_cout), .overflow_V(adder_V));
    subtractor_8bit       u_sub(.A(A), .B(B), .Diff(res_sub), .overflow(sub_V));
    array_multiplier_8bit u_mul(.A(A), .B(B), .P(res_mul));
    array_divider_8bit    u_div(.A(A), .B(B), .Q(res_div));
    barrel_shifter_left   u_shl(.A(A), .shift_amt(B[2:0]), .C(res_shl));
    barrel_shifter_right  u_shr(.A(A), .shift_amt(B[2:0]), .C(res_shr));

    // turn the opcode into the one-hot enable
    decoder_4to9          u_dec(.op(operation), .en(en));

    // select the result of the active operation
    result_mux            u_mux(
        .res_and(res_and), .res_or(res_or), .res_add(res_add),
        .res_mul(res_mul), .res_shl(res_shl), .res_sub(res_sub),
        .res_div(res_div), .res_xor(res_xor), .res_shr(res_shr),
        .en(en), .C(C)
    );

    // status flags (V is only valid for ADD and SUB)
    flag_gen              u_flags(
        .C(C),
        .add_overflow_V(adder_V),
        .sub_overflow_V(sub_V),
        .en_add(en[2]),
        .en_sub(en[5]),
        .Z(Z), .N(N), .V(V)
    );
endmodule
