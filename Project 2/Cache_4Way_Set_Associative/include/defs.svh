`ifndef __DEFS_SVH__
 `define __DEFS_SVH__

// ---------------------------------------------------------------------------
// Shared parameters for the 32 KiB, 4-way set-associative, write-back,
// write-allocate, LRU cache.
//
//   Cache      : 32 KiB = 2^15 B  -> 2^13 words -> 2^10 = 1024 lines
//   Ways       : 4                -> 2^8 = 256 sets
//   Block      : 8 words * 32 bit = 256 bits
//   Main mem   : 8 MiB = 2^23 B   -> 2^21 words (word-addressable)
//
//   Word address (21 bit):  | Tag [20:11] | Index [10:3] | Offset [2:0] |
//                           |   10 bit    |    8 bit      |    3 bit     |
//
//   MM block address {tag,index} = 18 bit -> 2^18 blocks = 8 MiB / 32 B.
// ---------------------------------------------------------------------------

`endif // __DEFS_SVH__
