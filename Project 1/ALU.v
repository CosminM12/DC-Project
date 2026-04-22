// 8-bit Structural ALU — top-level module
//
// Operations (4-bit opcode):
//   0000 = AND        (Robi)
//   0001 = OR         (Robi)
//   0010 = ADD        (Robi)
//   0011 = MUL        (Robi)  — lower 8 bits of A*B
//   0100 = SHL        (Robi)  — A shifted left by B[2:0]
//   0101 = SUB        (Cosmin — placeholder: outputs 0)
//   0110 = DIV        (Cosmin — placeholder: outputs 0)
//   0111 = XOR        (Cosmin — placeholder: outputs 0)
//   1000 = SHR        (Cosmin — placeholder: outputs 0)
//
// Status flags:
//   Z — zero:     C == 8'b0
//   N — negative: C[7] (MSB / sign bit)
//   V — overflow: signed overflow from ADD; 0 for all other ops
module ALU(
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] operation,
    output [7:0] C,
    output       Z,
    output       N,
    output       V
);
    // -------------------------------------------------------
    // Functional unit result wires
    // -------------------------------------------------------
    wire [7:0] res_and, res_or, res_xor, res_add, res_sub, res_mul, res_shl, res_shr;
    wire       adder_cout;
    wire       adder_V;
    wire       sub_V;

    // -------------------------------------------------------
    // Decoder enable signals (one-hot, indexed 0..8)
    // -------------------------------------------------------
    wire [8:0] en;

    // -------------------------------------------------------
    // Instantiate functional units
    // -------------------------------------------------------
    and8                  u_and (.A(A), .B(B), .C(res_and));

    or8                   u_or (.A(A), .B(B), .C(res_or));

    xor8                  u_xor (.A(A), .B(B), .C(res_xor));

    adder_8bit            u_add(.A(A), .B(B),
                                .Sum(res_add),
                                .Cout(adder_cout),
                                .overflow_V(adder_V));

    subtractor_8bit        u_sub(.A(A), .B(B), .Diff(res_sub),
                                 .overflow(sub_V));

    array_multiplier_8bit u_mul(.A(A), .B(B), .P(res_mul));

    barrel_shifter_left   u_shl(.A(A), .shift_amt(B[2:0]), .C(res_shl));

    barrel_shifter_right  u_shr(.A(A), .shift_amt(B[2:0]), .C(res_shr));

    // -------------------------------------------------------
    // Operation decoder
    // -------------------------------------------------------
    decoder_4to9          u_dec(.op(operation), .en(en));

    // -------------------------------------------------------
    // Result mux — select active operation output
    // Cosmin's operations are wired to 8'b0 until implemented
    // -------------------------------------------------------
    result_mux            u_mux(
        .res_and(res_and),
        .res_or (res_or),
        .res_add(res_add),
        .res_mul(res_mul),
        .res_shl(res_shl),
        .res_sub(res_sub),
        .res_div(8'b0),     // Cosmin: replace with actual result
        .res_xor(res_xor),
        .res_shr(res_shr),
        .en(en),
        .C(C)
    );

    // -------------------------------------------------------
    // Flag generation
    // -------------------------------------------------------
    flag_gen              u_flags(
        .C(C),
        .add_overflow_V(adder_V),
        .en_add(en[2]),
        .Z(Z),
        .N(N),
        .V(V)
    );

endmodule
