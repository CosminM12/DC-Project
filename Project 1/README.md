# 8-bit ALU (Verilog)

This is my Digital Circuits project: an 8-bit Arithmetic Logic Unit written in
Verilog. The whole thing is built in a structural style, which means it is made
only out of basic logic gates (and, or, xor, not, buf) and small building
blocks wired together. There is no behavioural code like "assign C = A + B" in
the design itself, everything is built from gates by hand.

## What it does

The ALU takes two 8-bit operands and a 4-bit operation selector, and produces
an 8-bit result plus three status flags.

Operations:

| Opcode | Name | Description            |
|--------|------|------------------------|
| 0000   | AND  | bitwise A and B        |
| 0001   | OR   | bitwise A or B         |
| 0010   | ADD  | A + B                  |
| 0011   | MUL  | low 8 bits of A * B    |
| 0100   | SHL  | A shifted left by B    |
| 0101   | SUB  | A - B                  |
| 0110   | DIV  | quotient of A / B      |
| 0111   | XOR  | bitwise A xor B        |
| 1000   | SHR  | A shifted right by B   |

Opcodes from 1001 to 1111 are not used. For those the result is 0.

## Inputs and outputs

| Signal      | Width | Direction | Meaning                         |
|-------------|-------|-----------|---------------------------------|
| A           | 8     | input     | first operand                   |
| B           | 8     | input     | second operand                  |
| operation   | 4     | input     | selects the operation           |
| C           | 8     | output    | result                          |
| Z           | 1     | output    | zero flag                       |
| N           | 1     | output    | negative flag                   |
| V           | 1     | output    | signed overflow flag            |

## Status flags

- Z (zero): 1 when the result C is all zeros.
- N (negative): 1 when the most significant bit of C is 1 (the sign bit in
  two's complement).
- V (overflow): 1 when a signed overflow happens. This only makes sense for
  ADD and SUB, so for every other operation V stays 0.

## A few details worth knowing

- The result is only 8 bits, so MUL keeps the low 8 bits of the product and DIV
  returns the quotient (the remainder is computed inside but not sent out).
- The shift amount uses only the low 3 bits of B, so shifts go from 0 to 7.
- Dividing by zero is not a real operation, so the divider just returns 0xFF in
  that case. The spec does not ask for divide-by-zero handling.

## How it is built

The top module is `ALU.v`. It connects all the functional units, a decoder, a
result multiplexer and the flag generator.

Functional units (one per operation):

- `and8.v`, `or8.v`, `xor8.v` : bitwise logic
- `adder_8bit.v` : ripple-carry adder (uses `full_adder.v` and `half_adder.v`)
- `subtractor_8bit.v` : does A + (not B) + 1
- `array_multiplier_8bit.v` : array of and gates plus a chain of adders
- `array_divider_8bit.v` : restoring array divider (uses `div_stage_restoring.v`)
- `barrel_shifter_left.v`, `barrel_shifter_right.v` : 3-stage barrel shifters
  (use `mux2to1.v`)

Control and glue:

- `decoder_4to9.v` : turns the 4-bit opcode into a one-hot enable
- `result_mux.v` : picks the result of the selected operation
- `flag_gen.v` : produces Z, N and V

How a result is chosen: the decoder sets exactly one enable bit. The result mux
ANDs every operation result with its own enable and ORs everything together, so
only the selected result reaches the output and all the others become 0.

## Testbenches

Every part of the design has a self-checking testbench. Self-checking means the
testbench computes the expected answer on its own and compares it to the design,
then prints PASS or the number of failures. The main one, `ALU_tb.v`, tries all
256 x 256 input combinations for every operation and also checks the flags.

The list of testbenches and the exact commands to run them are in
`TESTBENCHES.md`. To run all of them at once with Icarus Verilog:

```
powershell -ExecutionPolicy Bypass -File run_all_tests.ps1
```

All testbenches currently pass.

## Tools

The design was tested with Icarus Verilog (iverilog + vvp). It only uses plain
Verilog, so it should also work in ModelSim or Vivado.
