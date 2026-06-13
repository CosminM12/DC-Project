// 4-to-9 operation decoder.
// Turns the 4-bit opcode into a one-hot enable: en[k] = 1 for opcode k.
//   en[0] AND  en[1] OR   en[2] ADD  en[3] MUL  en[4] SHL
//   en[5] SUB  en[6] DIV  en[7] XOR  en[8] SHR
// Opcodes 9 to 15 leave en = 0, so the ALU result is 0.
module decoder_4to9(
    input  [3:0] op,
    output [8:0] en
);
    wire op0n, op1n, op2n, op3n;
    not g_n0(op0n, op[0]);
    not g_n1(op1n, op[1]);
    not g_n2(op2n, op[2]);
    not g_n3(op3n, op[3]);

    and g_en0(en[0], op3n, op2n, op1n, op0n);  // 0000
    and g_en1(en[1], op3n, op2n, op1n, op[0]); // 0001
    and g_en2(en[2], op3n, op2n, op[1], op0n); // 0010
    and g_en3(en[3], op3n, op2n, op[1], op[0]);// 0011
    and g_en4(en[4], op3n, op[2], op1n, op0n); // 0100
    and g_en5(en[5], op3n, op[2], op1n, op[0]);// 0101
    and g_en6(en[6], op3n, op[2], op[1], op0n);// 0110
    and g_en7(en[7], op3n, op[2], op[1], op[0]);// 0111
    and g_en8(en[8], op[3], op2n, op1n, op0n); // 1000
endmodule
