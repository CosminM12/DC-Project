`include "defs.svh"

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// 32 KiB, 4-way set-associative cache controller.
//   policy : write-back, write-allocate, true-LRU replacement
//   block  : 8 words x 32 bit = 256 bit
//   sets   : 256   (index = 8 bit)
//   tag    : 10 bit, offset = 3 bit, word address = 21 bit
//
// CPU side : caddress/cdin/rden/wren -> hit/cdout
// MM  side : maddress/mdout/mrden/mwren -> mdin  (block granular, 18-bit addr)
//
// Storage note: the cache state is kept in *flat* 1-D arrays indexed by
//   line = set * NWAYS + way
// rather than 2-D [set][way] arrays. Icarus Verilog cannot read a 2-D unpacked
// array with variable indices inside an always_* block, so the flat form (a
// single variable index, exactly like the direct-mapped reference design) is
// used for portability.
// ---------------------------------------------------------------------------
module cache_controller
  #(
    parameter BLOCK_SIZE    = 256,  // bits per cache block (8 * 32)
    parameter ADDRESS_WIDTH = 21,   // CPU word-address width
    parameter INDEX_WIDTH   = 8,    // 256 sets
    parameter TAG_WIDTH     = 10,
    parameter OFFSET_WIDTH  = 3,    // 8 words per block
    parameter WORD_SIZE     = 32,
    parameter NBLOCKS       = 1024, // total lines (256 sets * 4 ways)
    parameter NWAYS         = 4
    )
   (
    input  logic                                  clock,
    input  logic                                  rst_n,
    input  logic [ADDRESS_WIDTH - 1:0]            caddress,
    input  logic [WORD_SIZE - 1:0]                cdin,
    input  logic [BLOCK_SIZE - 1:0]               mdin,
    input  logic                                  rden,
    input  logic                                  wren,
    output logic                                  hit,
    output logic [WORD_SIZE - 1:0]                cdout,
    output logic [BLOCK_SIZE - 1:0]               mdout,
    output logic [TAG_WIDTH + INDEX_WIDTH - 1:0]  maddress,
    output logic                                  mrden,
    output logic                                  mwren
    );

   // -- derived sizes --------------------------------------------------------
   localparam int NSETS    = NBLOCKS / NWAYS;   // 256
   localparam int NLINES   = NBLOCKS;           // 1024 flat lines
   localparam int WAY_BITS = $clog2(NWAYS);     // 2

   // address field positions:  [ TAG | INDEX | OFFSET ]
   localparam TAG_MSB          = ADDRESS_WIDTH - 1;                 // 20
   localparam TAG_LSB          = INDEX_WIDTH + OFFSET_WIDTH;        // 11
   localparam INDEX_MSB        = INDEX_WIDTH + OFFSET_WIDTH - 1;    // 10
   localparam INDEX_LSB        = OFFSET_WIDTH;                      // 3
   localparam BLOCK_OFFSET_MSB = OFFSET_WIDTH - 1;                  // 2
   localparam BLOCK_OFFSET_LSB = 0;

   // -- FSM ------------------------------------------------------------------
   typedef enum logic [2:0] {
      STATE_IDLE,
      STATE_READ_HIT,
      STATE_READ_MISS,
      STATE_WRITE_HIT,
      STATE_WRITE_MISS,
      STATE_REPLACE,   // write a dirty victim block back to main memory
      STATE_FETCH,     // request the missing block from main memory
      STATE_FILL       // store the fetched block into the chosen way
   } state_t;

   state_t current_state, next_state;

   // -- cache storage : flat, line = set*NWAYS + way -------------------------
   logic                     cache_valid [0:NLINES-1];
   logic                     cache_dirty [0:NLINES-1];
   logic [TAG_WIDTH-1:0]     cache_tag   [0:NLINES-1];
   logic [BLOCK_SIZE-1:0]    cache_mem   [0:NLINES-1];
   logic [WAY_BITS-1:0]      cache_age   [0:NLINES-1]; // 0=MRU .. NWAYS-1=LRU

   // -- latched request ------------------------------------------------------
   logic [ADDRESS_WIDTH-1:0] req_addr;
   logic                     req_read;
   logic                     req_write;
   logic [WORD_SIZE-1:0]     req_wdata;
   logic [WAY_BITS-1:0]      way_sel;   // way used for this transaction

   // -- active request decode (current in IDLE, latched otherwise) ----------
   logic [ADDRESS_WIDTH-1:0] active_addr;
   logic [INDEX_WIDTH-1:0]   active_index;
   logic [TAG_WIDTH-1:0]     active_tag;
   logic [OFFSET_WIDTH-1:0]  active_offset;
   logic [INDEX_WIDTH+WAY_BITS-1:0] set_base;  // first line of the active set

   // -- combinational lookup results ----------------------------------------
   logic [NWAYS-1:0]         way_hit;      // per-way tag match
   logic [NWAYS-1:0]         way_invalid;  // per-way !valid
   logic [NWAYS-1:0]         way_is_lru;   // per-way age == LRU
   logic                     hit_found;
   logic [WAY_BITS-1:0]      hit_way;
   logic [WAY_BITS-1:0]      victim_way;
   logic                     have_invalid;
   logic [WORD_SIZE-1:0]     read_data;

   // -----------------------------------------------------------------------
   // word <-> block helpers (selects done on a value, not on an array read,
   // which keeps Icarus happy)
   // -----------------------------------------------------------------------
   function automatic logic [WORD_SIZE-1:0] block_get_word(
      input logic [BLOCK_SIZE-1:0]   block,
      input logic [OFFSET_WIDTH-1:0] word_offset
   );
      return block[WORD_SIZE * word_offset +: WORD_SIZE];
   endfunction

   function automatic logic [BLOCK_SIZE-1:0] block_set_word(
      input logic [BLOCK_SIZE-1:0]   block,
      input logic [OFFSET_WIDTH-1:0] word_offset,
      input logic [WORD_SIZE-1:0]    word
   );
      logic [BLOCK_SIZE-1:0] result;
      result = block;
      result[WORD_SIZE * word_offset +: WORD_SIZE] = word;
      return result;
   endfunction

   // -----------------------------------------------------------------------
   // address decode
   // -----------------------------------------------------------------------
   assign active_addr   = (current_state == STATE_IDLE) ? caddress : req_addr;
   assign active_index  = active_addr[INDEX_MSB:INDEX_LSB];
   assign active_tag    = active_addr[TAG_MSB:TAG_LSB];
   assign active_offset = active_addr[BLOCK_OFFSET_MSB:BLOCK_OFFSET_LSB];
   assign set_base      = active_index * NWAYS;     // = active_index << WAY_BITS

   // -----------------------------------------------------------------------
   // Per-way comparison vectors.
   // These MUST be continuous assignments: in Icarus an always_* block is not
   // re-evaluated when an array element it read is written elsewhere, so the
   // result of a fill would never reach an always_comb hit test. A continuous
   // assign reading a memory IS re-evaluated on that write.
   // -----------------------------------------------------------------------
   genvar gw;
   generate
      for (gw = 0; gw < NWAYS; gw = gw + 1) begin : g_ways
         assign way_hit[gw]     = cache_valid[set_base + gw] &&
                                  (cache_tag[set_base + gw] == active_tag);
         assign way_invalid[gw] = !cache_valid[set_base + gw];
         assign way_is_lru[gw]  = (cache_age[set_base + gw] == (NWAYS-1));
      end
   endgenerate

   assign hit_found = |way_hit;
   assign hit       = hit_found;
   assign read_data = block_get_word(cache_mem[set_base + way_sel], active_offset);

   // -----------------------------------------------------------------------
   // hit way: priority-encode the (at most one) matching way
   // -----------------------------------------------------------------------
   always_comb begin
      hit_way = '0;
      for (int w = 0; w < NWAYS; w++)
         if (way_hit[w]) hit_way = WAY_BITS'(w);
   end

   // -----------------------------------------------------------------------
   // victim way: a free (invalid) way first, otherwise the LRU way.
   // True LRU: a set's ages are always a permutation of 0..NWAYS-1, so exactly
   // one way has age == NWAYS-1 (the least-recently-used victim).
   // -----------------------------------------------------------------------
   always_comb begin
      have_invalid = 1'b0;
      victim_way   = '0;
      for (int w = 0; w < NWAYS; w++)
         if (!have_invalid && way_invalid[w]) begin
            have_invalid = 1'b1;
            victim_way   = WAY_BITS'(w);
         end
      if (!have_invalid)
         for (int w = 0; w < NWAYS; w++)
            if (way_is_lru[w]) victim_way = WAY_BITS'(w);
   end

   // -----------------------------------------------------------------------
   // next-state / output logic
   // -----------------------------------------------------------------------
   always_comb begin
      next_state = current_state;
      cdout      = '0;
      mdout      = '0;
      maddress   = '0;
      mrden      = 1'b0;
      mwren      = 1'b0;

      case (current_state)
         STATE_IDLE: begin
            if      (rden && hit_found) next_state = STATE_READ_HIT;
            else if (rden)              next_state = STATE_READ_MISS;
            else if (wren && hit_found) next_state = STATE_WRITE_HIT;
            else if (wren)              next_state = STATE_WRITE_MISS;
         end

         STATE_READ_HIT: begin
            cdout      = read_data;
            next_state = STATE_IDLE;
         end

         // dirty victim -> write back first, otherwise fetch straight away
         STATE_READ_MISS: begin
            if (cache_dirty[set_base + way_sel]) next_state = STATE_REPLACE;
            else                                 next_state = STATE_FETCH;
         end

         STATE_WRITE_MISS: begin
            if (cache_dirty[set_base + way_sel]) next_state = STATE_REPLACE;
            else                                 next_state = STATE_FETCH;
         end

         // write back the victim block at its *own* (old) address
         STATE_REPLACE: begin
            mwren      = 1'b1;
            maddress   = {cache_tag[set_base + way_sel], active_index};
            mdout      = cache_mem[set_base + way_sel];
            next_state = STATE_FETCH;
         end

         // fetch the requested block
         STATE_FETCH: begin
            mrden      = 1'b1;
            maddress   = {active_tag, active_index};
            next_state = STATE_FILL;
         end

         // block is captured into the way in the sequential block; route to
         // the matching hit handler so the original access is served
         STATE_FILL: begin
            if      (req_read)  next_state = STATE_READ_HIT;
            else if (req_write) next_state = STATE_WRITE_HIT;
            else                next_state = STATE_IDLE;
         end

         STATE_WRITE_HIT: begin
            next_state = STATE_IDLE;
         end

         default: next_state = STATE_IDLE;
      endcase
   end

   // -----------------------------------------------------------------------
   // simulation-time power-up state (also done synchronously on reset)
   // -----------------------------------------------------------------------
   integer i;

   initial begin
      for (i = 0; i < NLINES; i = i + 1) begin
         cache_valid[i] = 1'b0;
         cache_dirty[i] = 1'b0;
         cache_tag[i]   = '0;
         cache_mem[i]   = '0;
         cache_age[i]   = i % NWAYS;  // each set starts as ages 0,1,2,3
      end
   end

   // -----------------------------------------------------------------------
   // sequential: state, request latch, refill, write, LRU update
   // -----------------------------------------------------------------------
   always_ff @(posedge clock) begin
      if (!rst_n) begin
         current_state <= STATE_IDLE;
         req_read      <= 1'b0;
         req_write     <= 1'b0;
         for (i = 0; i < NLINES; i = i + 1) begin
            cache_valid[i] <= 1'b0;
            cache_dirty[i] <= 1'b0;
            cache_tag[i]   <= '0;
            cache_mem[i]   <= '0;
            cache_age[i]   <= i % NWAYS;
         end
      end else begin
         current_state <= next_state;

         // latch a new request and pick the target way once, in IDLE
         if (current_state == STATE_IDLE && (rden || wren)) begin
            req_addr  <= caddress;
            req_read  <= rden;
            req_write <= wren;
            req_wdata <= cdin;
            way_sel   <= hit_found ? hit_way : victim_way;
         end

         // refill the chosen way from main memory (clean after fill)
         if (current_state == STATE_FILL) begin
            cache_mem[set_base + way_sel]   <= mdin;
            cache_tag[set_base + way_sel]   <= active_tag;
            cache_valid[set_base + way_sel] <= 1'b1;
            cache_dirty[set_base + way_sel] <= 1'b0;
         end

         // commit the stored word on a write hit (plain or post-allocate)
         if (current_state == STATE_WRITE_HIT) begin
            cache_mem[set_base + way_sel] <=
               block_set_word(cache_mem[set_base + way_sel],
                              active_offset, req_wdata);
            cache_dirty[set_base + way_sel] <= 1'b1;
         end

         // LRU bookkeeping: make way_sel the MRU of its set whenever it is
         // actually accessed (read hit, write hit, or fill).
         if (current_state == STATE_READ_HIT  ||
             current_state == STATE_WRITE_HIT ||
             current_state == STATE_FILL) begin
            for (int w = 0; w < NWAYS; w++) begin
               if (cache_age[set_base + w] < cache_age[set_base + way_sel])
                  cache_age[set_base + w] <= cache_age[set_base + w] + 1'b1;
            end
            cache_age[set_base + way_sel] <= '0;
         end
      end
   end

endmodule
