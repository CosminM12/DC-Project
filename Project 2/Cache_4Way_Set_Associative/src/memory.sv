`include "defs.svh"

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Block-granular main memory model (8 MiB).
//   depth   : 2^ADDRESS_WIDTH blocks  (ADDRESS_WIDTH = tag+index = 18)
//   width   : BLOCK_SIZE bits per block (256)
//
// Initialisation:
//   * if FILE is given  -> $readmemh(FILE)
//   * otherwise         -> each word is set to its own word address, i.e.
//        mem[block][word] = block * WORDS_PER_BLOCK + word
//     so a CPU read of word address A returns A. This makes the testbench
//     self-checking without shipping a multi-megabyte hex file.
//
// 1-cycle synchronous read and write (matches the cache FSM's FETCH/REPLACE).
// ---------------------------------------------------------------------------
module memory
  #(parameter ADDRESS_WIDTH   = 18,
    parameter BLOCK_SIZE      = 256,
    parameter WORD_SIZE       = 32,
    parameter WORDS_PER_BLOCK = 8,
    parameter FILE            = ""
    )
   (
    input  logic                       clock,
    input  logic [BLOCK_SIZE-1:0]      din,
    input  logic [ADDRESS_WIDTH-1:0]   address,
    input  logic                       rden,
    input  logic                       wren,
    output logic [BLOCK_SIZE-1:0]      dout
    );

   localparam int DEPTH = 2 ** ADDRESS_WIDTH;

   reg [BLOCK_SIZE-1:0] mem [0:DEPTH-1];

   integer i, w;

   initial begin
      if (FILE != "")
         $readmemh(FILE, mem);
      else
         for (i = 0; i < DEPTH; i = i + 1)
            for (w = 0; w < WORDS_PER_BLOCK; w = w + 1)
               mem[i][WORD_SIZE*w +: WORD_SIZE] = i*WORDS_PER_BLOCK + w;
   end

   always_ff @(posedge clock)
     if (wren)
       mem[address] <= din;

   always_ff @(posedge clock)
     if (rden)
       dout <= mem[address];

endmodule // memory
