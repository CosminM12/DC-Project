# ALU testbenches

All testbenches are self-checking. That means each one computes the expected
result by itself, compares it against the design, and prints either PASS or the
number of failures, then calls $finish. So a failure is impossible to miss.

| Testbench | Module tested | What it covers |
|-----------|---------------|----------------|
| ALU_tb.v | whole ALU | all 9 opcodes over all 256x256 inputs, plus Z/N/V flags and invalid opcodes 9..F |
| adder_8bit_tb.v | adder_8bit | all 65536 pairs: Sum, Cout, signed V |
| subtractor_8bit_tb.v | subtractor_8bit | all 65536 pairs: Diff, signed V |
| array_multiplier_8bit_tb.v | array_multiplier_8bit | all 65536 pairs: low 8 bits of A*B |
| array_divider_8bit_tb.v | array_divider_8bit | all 65536 pairs: Q = A/B, and B=0 gives Q=FF |
| barrel_shifter_left_tb.v | barrel_shifter_left | all 256x8 = 2048 (value and shift amount) |
| barrel_shifter_right_tb.v | barrel_shifter_right | all 256x8 = 2048 |
| decoder_4to9_tb.v | decoder_4to9 | all 16 opcodes (one-hot or all zero) |

The main ALU_tb.v already runs every small block (and8, or8, xor8, mux2to1,
full_adder, half_adder and so on) inside the full design over the whole input
space. The per-module testbenches are there to point at a single block if
something ever breaks.

## Running with Icarus Verilog

Install it from https://bleyer.org/icarus/ on Windows, or use
"apt install iverilog" on Linux and "brew install icarus-verilog" on macOS.

From this folder:

```
# Main ALU testbench
iverilog -g2012 -o alu_tb ALU.v and8.v or8.v xor8.v adder_8bit.v subtractor_8bit.v array_multiplier_8bit.v array_divider_8bit.v div_stage_restoring.v barrel_shifter_left.v barrel_shifter_right.v decoder_4to9.v result_mux.v flag_gen.v full_adder.v half_adder.v mux2to1.v ALU_tb.v
vvp alu_tb

# Individual blocks
iverilog -o t adder_8bit.v full_adder.v half_adder.v adder_8bit_tb.v && vvp t
iverilog -o t subtractor_8bit.v full_adder.v half_adder.v subtractor_8bit_tb.v && vvp t
iverilog -o t array_multiplier_8bit.v adder_8bit.v full_adder.v half_adder.v array_multiplier_8bit_tb.v && vvp t
iverilog -o t array_divider_8bit.v div_stage_restoring.v full_adder.v half_adder.v mux2to1.v array_divider_8bit_tb.v && vvp t
iverilog -o t barrel_shifter_left.v mux2to1.v barrel_shifter_left_tb.v && vvp t
iverilog -o t barrel_shifter_right.v mux2to1.v barrel_shifter_right_tb.v && vvp t
iverilog -o t decoder_4to9.v decoder_4to9_tb.v && vvp t
```

The script run_all_tests.ps1 runs all of the above in one go.

## Expected output (main testbench)

```
opcode 0 (AND): PASS  (65536 vectors)
opcode 1 (OR): PASS  (65536 vectors)
opcode 2 (ADD): PASS  (65536 vectors)
opcode 3 (MUL): PASS  (65536 vectors)
opcode 4 (SHL): PASS  (65536 vectors)
opcode 5 (SUB): PASS  (65536 vectors)
opcode 6 (DIV): PASS  (65536 vectors)
opcode 7 (XOR): PASS  (65536 vectors)
opcode 8 (SHR): PASS  (65536 vectors)
invalid opcodes 9..F: PASS  (C=0, Z=1)
--------------------------------------------------
ALU_tb: ALL TESTS PASSED
```

Note on MUL and DIV: the ALU has a single 8-bit result port, so MUL returns the
low 8 bits of A*B and DIV returns the quotient A/B. The reference values in the
testbenches use the same rule.
