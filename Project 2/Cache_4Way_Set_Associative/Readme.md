# 4-Way Set-Associative Cache

Design and simulation of a **32 KiB, 4-way set-associative** cache with
**8-word blocks** and **32-bit words**. Main memory is **8 MiB**, the addressable
unit is the **word**. The cache is **write-back**, **write-allocate**, with an
**LRU** replacement policy.

## Project structure

```
Cache_4Way_Set_Associative/
│
├── src/                  # RTL: cache_controller.sv, memory.sv
├── tb/                   # Testbench + optional memory-image generator
├── include/              # defs.svh (shared parameter notes / include guard)
├── docs/                 # DESIGN.md (FSM + LRU details)
├── sim/                  # logs + VCD  (created by make, git-ignored)
├── build/                # vvp images  (created by make, git-ignored)
└── Makefile
```

## Requirements

Design and simulate a 32 KiB 4-way set associative cache, with 8-words block and
32 bit words. Main Memory size is 8 MiB, the addressable unit is the word. The
cache is write-back, write-allocate with an LRU replacement policy.

## Parameters

### Cache

$32\ \text{KiB} = 2^5 \times 2^{10}\ \text{B}$. With $32\ \text{bit} = 4\ \text{B} = 2^2\ \text{B}$
per word, the cache holds $\frac{2^5 \times 2^{10}}{2^2} = 2^{13}$ words.
With 8 words per block ($2^3$), there are $\frac{2^{13}}{2^3} = 2^{10} = 1024$
lines. Being **4-way** set associative, the number of **sets** is
$\frac{1024}{4} = 2^8 = 256$.

| Field        | Bits | Reason                |
|--------------|------|-----------------------|
| Tag          | 10   | $21 - 8 - 3$          |
| Index (set)  | 8    | $256 = 2^8$ sets      |
| Block offset | 3    | $8 = 2^3$ words/block |

### Main Memory

Main memory is $8\ \text{MiB} = 2^3 \times 2^{20}\ \text{B} = 2^{23}\ \text{B}$.
Since the addressable unit is the word ($4\ \text{B}$), there are
$\frac{2^{23}}{2^2} = 2^{21}$ words, so the **word address is 21 bits** and the
tag is $21 - 8 - 3 = 10$ bits.

The address issued from the cache controller to main memory is on
$10 + 8 = 18$ bits (tag + index), addressing $2^{18}$ blocks
($= 8\ \text{MiB} / 32\ \text{B}$).

### Address layout

| Tag (20:11) | Index (12... 10:3) | Block Offset (2:0) |
|-------------|--------------------|--------------------|
| 10 bits     | 8 bits             | 3 bits             |

```
 bit:  20                 11 10              3 2          0
       +--------------------+------------------+------------+
       |        TAG         |      INDEX       |   OFFSET   |
       |      10 bits       |     8 bits       |   3 bits   |
       +--------------------+------------------+------------+
```

## Cache controller parameters

```systemverilog
parameter BLOCK_SIZE    = 256;  // bits (8 words * 4 B * 8 bits)
parameter ADDRESS_WIDTH = 21;   // word address (3 + 8 + 10)
parameter INDEX_WIDTH   = 8;    // 256 sets
parameter TAG_WIDTH     = 10;
parameter OFFSET_WIDTH  = 3;
parameter WORD_SIZE     = 32;
parameter NBLOCKS       = 1024; // total lines (256 sets * 4 ways)
parameter NWAYS         = 4;
```

## Interface

CPU side and main-memory side ports (same naming as the direct-mapped example):

| Port       | Dir | Width | Meaning                                   |
|------------|-----|-------|-------------------------------------------|
| `caddress` | in  | 21    | CPU word address                          |
| `cdin`     | in  | 32    | CPU write data                            |
| `rden`/`wren` | in | 1   | CPU read / write request                  |
| `hit`      | out | 1     | tag match in the addressed set            |
| `cdout`    | out | 32    | CPU read data (valid in `READ_HIT`)       |
| `maddress` | out | 18    | block address to main memory `{tag,index}`|
| `mdout`    | out | 256   | block written back to memory              |
| `mrden`/`mwren` | out | 1 | memory read / write strobe                |
| `mdin`     | in  | 256   | block fetched from memory                 |

See [docs/DESIGN.md](docs/DESIGN.md) for the FSM, the LRU scheme, and the
hit / miss / write-back data flow.

## Build & simulate

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/) (`iverilog` +
`vvp`). Verified with **Icarus Verilog v12**.

### With make (Git Bash / MSYS2 / WSL on Windows)

```bash
make            # compile src/ + tb/ and run the testbench
make clean      # remove build/ and sim/
make waves      # open sim/cache_controller_tb.vcd in GTKWave
```

### Without make (direct commands)

```bash
iverilog -Wall -g2012 -Iinclude -o build/sim.out -s cache_controller_tb \
         src/cache_controller.sv src/memory.sv tb/cache_controller_tb.sv
vvp build/sim.out
```

> Note (Windows iverilog v12): place `-o <file>` **before** the source files.
> This build rejects `-o` placed after the source list. The Makefile already
> does this. Paths with spaces are fine.

The testbench is **self-checking**. Main memory is initialised so that a read of
word address `A` returns `A` (handled in `memory.sv`, no data file needed), which
lets every read be checked against its own address. Expected tail of the run:

```
 SUMMARY: 34 / 34 checks passed
 RESULT : ALL TESTS PASSED
```

### What the testbench proves

| Group | Checks |
|-------|--------|
| A | cold read misses, read hits, and 4 distinct tags coexisting in one set (associativity) |
| B | true-LRU: the least-recently-used way is the one evicted (survivors stay, victim is gone) |
| C | write-allocate on a write miss, then the written word reads back |
| D | a dirty victim is written back to memory (verified by re-reading after eviction) |
| E | a plain write hit on a resident clean line marks it dirty and updates the word |

> Optional: `tb/generate_data.py` produces a `$readmemh` image with the same
> pattern if you prefer file-based memory init; it is not required for `make`.
