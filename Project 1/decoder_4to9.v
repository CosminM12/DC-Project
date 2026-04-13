// 4-to-9 decoder for ALU operation selection
// Converts a 4-bit opcode into 9 one-hot enable signals.
//
// en[0] = AND  (4'b0000)
// en[1] = OR   (4'b0001)
// en[2] = ADD  (4'b0010)
// en[3] = MUL  (4'b0011)
// en[4] = SHL  (4'b0100)
// en[5] = SUB  (4'b0101)  -- Cosmin
// en[6] = DIV  (4'b0110)  -- Cosmin
// en[7] = XOR  (4'b0111)  -- Cosmin
// en[8] = SHR  (4'b1000)  -- Cosmin
//
// Opcodes 4'b1001..4'b1111 produce en = 9'b0 (C output will be 0).
module decoder_4to9(
    input  [3:0] op,
    output [8:0] en
);
    // Inverted opcode bits
    wire op0n, op1n, op2n, op3n;
    not g_n0(op0n, op[0]);
    not g_n1(op1n, op[1]);
    not g_n2(op2n, op[2]);
    not g_n3(op3n, op[3]);

    // en[k] = AND of the correct combination of true/inverted op bits
    and g_en0(en[0], op3n, op2n, op1n, op0n);  // 0000
    and g_en1(en[1], op3n, op2n, op1n, op[0]); // 0001
    and g_en2(en[2], op3n, op2n, op[1], op0n); // 0010
    and g_en3(en[3], op3n, op2n, op[1], op[0]);// 0011
    and g_en4(en[4], op3n, op[2], op1n, op0n); // 0100
    and g_en5(en[5], op3n, op[2], op1n, op[0]);// 0101
    and g_en6(en[6], op3n, op[2], op[1], op0n);// 0110
    and g_en7(en[7], op3n, op[2], op[1], op[0]);// 0111
    and g_en8(en[8], op[3], op2n,  op1n, op0n);// 1000
endmodule
