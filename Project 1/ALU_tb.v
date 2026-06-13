`timescale 1ns/1ps
// Exhaustive self-checking testbench for the whole ALU.
// For every valid opcode (0..8) it drives all 256x256 input pairs, computes
// the expected result and Z/N/V flags with its own reference, and compares
// against the DUT. It also sweeps the invalid opcodes (9..F), which give C = 0.
// See TESTBENCHES.md for the compile/run commands.
module ALU_tb;

    localparam [3:0] OP_AND = 4'h0, OP_OR  = 4'h1, OP_ADD = 4'h2,
                     OP_MUL = 4'h3, OP_SHL = 4'h4, OP_SUB = 4'h5,
                     OP_DIV = 4'h6, OP_XOR = 4'h7, OP_SHR = 4'h8;

    reg  [7:0] A, B;
    reg  [3:0] op;
    wire [7:0] C;
    wire       Z, N, V;

    ALU dut(.A(A), .B(B), .operation(op), .C(C), .Z(Z), .N(N), .V(V));

    integer i, j, opc;
    integer total_errors, op_errors;

    reg [7:0]  expC;
    reg        expZ, expN, expV;
    reg [15:0] prod;             // full product for MUL reference
    reg [8*4-1:0] name;          // opcode mnemonic for messages

    // Independent behavioural reference for the current A, B, op.
    task compute_expected;
        begin
            expV = 1'b0;
            case (op)
                OP_AND: expC = A & B;
                OP_OR : expC = A | B;
                OP_XOR: expC = A ^ B;
                OP_ADD: begin
                    expC = A + B;
                    expV = (A[7] == B[7]) && (expC[7] != A[7]);  // signed ovf
                end
                OP_SUB: begin
                    expC = A - B;
                    expV = (A[7] != B[7]) && (expC[7] != A[7]);  // signed ovf
                end
                OP_MUL: begin prod = A * B; expC = prod[7:0]; end // low 8 bits
                OP_DIV: expC = (B == 8'h00) ? 8'hFF : (A / B);
                OP_SHL: expC = A << B[2:0];
                OP_SHR: expC = A >> B[2:0];
                default: expC = 8'h00;                            // invalid op
            endcase
            expZ = (expC == 8'h00);
            expN = expC[7];
        end
    endtask

    task check;
        begin
            #1;
            compute_expected;
            if (C !== expC || Z !== expZ || N !== expN || V !== expV) begin
                total_errors = total_errors + 1;
                op_errors    = op_errors + 1;
                if (total_errors <= 25)
                    $display("  FAIL op=%h A=%0d B=%0d : C=%h(exp %h) Z=%b(%b) N=%b(%b) V=%b(%b)",
                             op, A, B, C, expC, Z, expZ, N, expN, V, expV);
            end
        end
    endtask

    initial begin
        total_errors = 0;

        // ---- exhaustive over the 9 valid opcodes ----
        for (opc = 0; opc <= 8; opc = opc + 1) begin
            op = opc;
            op_errors = 0;
            case (op)
                OP_AND: name = "AND";
                OP_OR : name = "OR";
                OP_ADD: name = "ADD";
                OP_MUL: name = "MUL";
                OP_SHL: name = "SHL";
                OP_SUB: name = "SUB";
                OP_DIV: name = "DIV";
                OP_XOR: name = "XOR";
                OP_SHR: name = "SHR";
                default: name = "?";
            endcase
            for (i = 0; i < 256; i = i + 1)
                for (j = 0; j < 256; j = j + 1) begin
                    A = i; B = j;
                    check;
                end
            if (op_errors == 0)
                $display("opcode %h (%0s): PASS  (65536 vectors)", op, name);
            else
                $display("opcode %h (%0s): FAIL  (%0d errors)", op, name, op_errors);
        end

        // ---- invalid opcodes 9..F: result must be 0 (sampled inputs) ----
        op_errors = 0;
        for (opc = 9; opc <= 15; opc = opc + 1) begin
            op = opc;
            for (i = 0; i < 256; i = i + 17)
                for (j = 0; j < 256; j = j + 17) begin
                    A = i; B = j;
                    check;
                end
        end
        if (op_errors == 0)
            $display("invalid opcodes 9..F: PASS  (C=0, Z=1)");
        else
            $display("invalid opcodes 9..F: FAIL  (%0d errors)", op_errors);

        $display("--------------------------------------------------");
        if (total_errors == 0)
            $display("ALU_tb: ALL TESTS PASSED");
        else
            $display("ALU_tb: %0d TOTAL FAILURES", total_errors);
        $finish;
    end
endmodule
