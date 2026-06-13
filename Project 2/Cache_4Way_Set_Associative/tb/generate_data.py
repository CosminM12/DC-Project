#!/usr/bin/env python3
"""
OPTIONAL main-memory image generator.

By default the simulation does NOT need this file: memory.sv initialises itself
with the same pattern when no FILE parameter is given (see src/memory.sv).
Use this only if you prefer file-based initialisation via $readmemh.

Pattern (matches memory.sv): the word at block `b`, offset `w` holds its own
word address, i.e.  value = b * WORDS_PER_BLOCK + w.  Each line is one block,
written as a single big-endian hex number of BLOCK_SIZE/4 hex digits, so that
$readmemh stores it directly into a 256-bit memory word.

To use it, set the memory FILE parameter, e.g. in the testbench:
    memory #(.FILE("tb/mem_data.txt"), ...) DUT_MEM (...);
"""

WORD_SIZE       = 32
WORDS_PER_BLOCK = 8
BLOCK_SIZE      = WORD_SIZE * WORDS_PER_BLOCK     # 256 bits
HEX_PER_BLOCK   = BLOCK_SIZE // 4                 # 64 hex digits


def block_hex(block_index: int) -> str:
    """One 256-bit block as 64 hex digits, word 7 is the most-significant."""
    value = 0
    for w in range(WORDS_PER_BLOCK):
        word = (block_index * WORDS_PER_BLOCK + w) & 0xFFFFFFFF
        value |= word << (WORD_SIZE * w)
    return format(value, f"0{HEX_PER_BLOCK}x")


def generate_file(num_blocks: int, filename: str = "mem_data.txt") -> None:
    with open(filename, "w") as f:
        for b in range(num_blocks):
            f.write(block_hex(b) + "\n")


if __name__ == "__main__":
    # 4096 blocks is plenty for the supplied testbench (it touches block
    # numbers well below this). Raise it if you extend the tests.
    num_blocks = 4096
    generate_file(num_blocks=num_blocks)
    print(f"Generated {num_blocks} blocks ({HEX_PER_BLOCK} hex digits each) "
          f"in mem_data.txt")
