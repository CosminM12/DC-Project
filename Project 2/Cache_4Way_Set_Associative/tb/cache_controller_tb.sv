`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Self-checking testbench for the 4-way set-associative cache.
//
// Main memory is initialised so that a read of word address A returns A
// (see memory.sv), which lets every read be checked against its own address.
//
// Coverage:
//   A. cold read misses + read hits + 4-way associativity (4 tags, 1 set)
//   B. true-LRU victim selection on a full set
//   C. write-allocate (write miss) + write-hit data
//   D. write-back of a dirty victim, verified by re-reading from memory
//   E. plain write hit on a resident clean line
// ---------------------------------------------------------------------------
module cache_controller_tb;

   localparam BLOCK_SIZE     = 256;
   localparam ADDRESS_WIDTH  = 21;
   localparam INDEX_WIDTH    = 8;
   localparam TAG_WIDTH      = 10;
   localparam OFFSET_WIDTH   = 3;
   localparam WORD_SIZE      = 32;
   localparam NBLOCKS        = 1024;
   localparam NWAYS          = 4;

   localparam MADDR_WIDTH    = TAG_WIDTH + INDEX_WIDTH; // 18

   // clock: 200 ns period (100 high / 100 low)
   localparam int CLK_PERIOD_NS = 200;

   logic clock;
   logic rst_n;

   logic [ADDRESS_WIDTH - 1:0] caddress;
   logic [WORD_SIZE - 1:0]     cdin;
   logic [BLOCK_SIZE - 1:0]    mdin;
   logic                       rden;
   logic                       wren;
   logic                       hit;
   logic [WORD_SIZE - 1:0]     cdout;
   logic [BLOCK_SIZE - 1:0]    mdout;
   logic [MADDR_WIDTH - 1:0]   maddress;
   logic                       mrden;
   logic                       mwren;

   integer total  = 0;
   integer passed = 0;

   // ----------------------------------------------------------------------
   // DUT + main memory
   // ----------------------------------------------------------------------
   cache_controller #(
      .BLOCK_SIZE(BLOCK_SIZE),
      .ADDRESS_WIDTH(ADDRESS_WIDTH),
      .INDEX_WIDTH(INDEX_WIDTH),
      .TAG_WIDTH(TAG_WIDTH),
      .OFFSET_WIDTH(OFFSET_WIDTH),
      .WORD_SIZE(WORD_SIZE),
      .NBLOCKS(NBLOCKS),
      .NWAYS(NWAYS)
   ) DUT_CACHE (
      .clock(clock),
      .rst_n(rst_n),
      .caddress(caddress),
      .cdin(cdin),
      .mdin(mdin),
      .rden(rden),
      .wren(wren),
      .hit(hit),
      .cdout(cdout),
      .mdout(mdout),
      .maddress(maddress),
      .mrden(mrden),
      .mwren(mwren)
   );

   memory #(
      .ADDRESS_WIDTH(MADDR_WIDTH),
      .BLOCK_SIZE(BLOCK_SIZE),
      .WORD_SIZE(WORD_SIZE),
      .WORDS_PER_BLOCK(BLOCK_SIZE/WORD_SIZE)
   ) DUT_MEM (
      .clock(clock),
      .din(mdout),
      .address(maddress),
      .rden(mrden),
      .wren(mwren),
      .dout(mdin)
   );

   // ----------------------------------------------------------------------
   // clock
   // ----------------------------------------------------------------------
   always begin
      clock = 1'b1;
      #(CLK_PERIOD_NS / 2);
      clock = 1'b0;
      #(CLK_PERIOD_NS / 2);
   end

   // ----------------------------------------------------------------------
   // helper: build a word address from tag / set / offset
   // ----------------------------------------------------------------------
   function automatic logic [ADDRESS_WIDTH-1:0] addr_of(
      input integer tag, input integer set, input integer off);
      return (tag << (INDEX_WIDTH + OFFSET_WIDTH)) |
             (set << OFFSET_WIDTH) | off;
   endfunction

   // ----------------------------------------------------------------------
   // bus tasks (one-cycle request, self-timed completion)
   // ----------------------------------------------------------------------
   task automatic cache_read(input  logic [ADDRESS_WIDTH-1:0] addr,
                             output logic [WORD_SIZE-1:0]      data,
                             output logic                      was_hit);
      integer guard;
      logic   done;
      begin
         @(negedge clock);
         caddress = addr; cdin = '0; rden = 1'b1; wren = 1'b0;
         #1 was_hit = hit;                 // sampled while still in IDLE
         @(posedge clock);                 // request captured, leaves IDLE
         #1 rden = 1'b0;                   // deassert AFTER the sampling edge
         done = 1'b0; guard = 0; data = 'x;
         while (!done && guard < 32) begin
            @(negedge clock);
            if (hit === 1'b1) begin        // READ_HIT cycle, cdout valid
               data = cdout;
               done = 1'b1;
            end
            guard = guard + 1;
         end
         if (!done) $display("[FAIL] read timeout @ addr=%05h", addr);
         @(negedge clock);                 // drain back to IDLE
      end
   endtask

   task automatic cache_write(input  logic [ADDRESS_WIDTH-1:0] addr,
                              input  logic [WORD_SIZE-1:0]      data,
                              output logic                      was_hit);
      integer guard;
      logic   done;
      begin
         @(negedge clock);
         caddress = addr; cdin = data; rden = 1'b0; wren = 1'b1;
         #1 was_hit = hit;
         @(posedge clock);
         #1 wren = 1'b0;                   // deassert AFTER the sampling edge
         done = 1'b0; guard = 0;
         while (!done && guard < 32) begin
            @(negedge clock);
            if (hit === 1'b1) done = 1'b1; // WRITE_HIT cycle reached
            guard = guard + 1;
         end
         if (!done) $display("[FAIL] write timeout @ addr=%05h", addr);
         @(negedge clock);                 // drain back to IDLE
      end
   endtask

   // ----------------------------------------------------------------------
   // checks
   // ----------------------------------------------------------------------
   task automatic check_eq(input string name,
                           input logic [WORD_SIZE-1:0] got,
                           input logic [WORD_SIZE-1:0] exp);
      begin
         total = total + 1;
         if (got === exp) begin
            passed = passed + 1;
            $display("[PASS] %-44s = %08h", name, got);
         end else begin
            $display("[FAIL] %-44s = %08h (expected %08h)", name, got, exp);
         end
      end
   endtask

   task automatic check_flag(input string name,
                             input logic got, input logic exp);
      begin
         total = total + 1;
         if (got === exp) begin
            passed = passed + 1;
            $display("[PASS] %-44s = %b", name, got);
         end else begin
            $display("[FAIL] %-44s = %b (expected %b)", name, got, exp);
         end
      end
   endtask

   // ----------------------------------------------------------------------
   // stimulus
   // ----------------------------------------------------------------------
   logic [WORD_SIZE-1:0] d;
   logic                 h;

   localparam logic [WORD_SIZE-1:0] V_WB = 32'hDEAD_0000; // written then evicted
   localparam logic [WORD_SIZE-1:0] V_WH = 32'h1111_2222; // plain write hit

   initial begin
      $dumpfile("cache_controller_tb.vcd");
      $dumpvars(0, cache_controller_tb);

      caddress = '0; cdin = '0; rden = 1'b0; wren = 1'b0; rst_n = 1'b0;
      repeat (2) @(posedge clock);
      rst_n = 1'b1;
      @(posedge clock);

      $display("================================================================");
      $display(" A. cold misses, read hits, 4-way associativity (set 0)");
      $display("================================================================");
      // four distinct tags, same set 0 -> four cold misses into four ways
      cache_read(addr_of(0,0,0), d, h);
         check_flag("tag0 set0 : first access is a miss", h, 1'b0);
         check_eq  ("tag0 set0 : data == address",        d, addr_of(0,0,0));
      cache_read(addr_of(1,0,0), d, h);
         check_flag("tag1 set0 : miss", h, 1'b0);
         check_eq  ("tag1 set0 : data", d, addr_of(1,0,0));
      cache_read(addr_of(2,0,0), d, h);
         check_flag("tag2 set0 : miss", h, 1'b0);
         check_eq  ("tag2 set0 : data", d, addr_of(2,0,0));
      cache_read(addr_of(3,0,0), d, h);
         check_flag("tag3 set0 : miss", h, 1'b0);
         check_eq  ("tag3 set0 : data", d, addr_of(3,0,0));

      // all four still resident -> hits (a direct-mapped cache could not do this)
      cache_read(addr_of(0,0,1), d, h); // different word in tag0's block
         check_flag("tag0 set0 off1 : hit (associativity)", h, 1'b1);
         check_eq  ("tag0 set0 off1 : data",                d, addr_of(0,0,1));
      cache_read(addr_of(3,0,7), d, h);
         check_flag("tag3 set0 off7 : hit", h, 1'b1);
         check_eq  ("tag3 set0 off7 : data", d, addr_of(3,0,7));

      $display("================================================================");
      $display(" B. true-LRU replacement (set 0)");
      $display("================================================================");
      // touch tag0 -> LRU order becomes {tag1,tag2,tag3,tag0}, LRU = tag1
      cache_read(addr_of(0,0,0), d, h);
         check_flag("touch tag0 : hit", h, 1'b1);
      // new tag4 -> must evict the LRU = tag1 (NOT tag0/2/3)
      cache_read(addr_of(4,0,0), d, h);
         check_flag("tag4 set0 : miss", h, 1'b0);
         check_eq  ("tag4 set0 : data", d, addr_of(4,0,0));
      // survivors are still hits ...
      cache_read(addr_of(0,0,0), d, h);
         check_flag("tag0 survived eviction : hit", h, 1'b1);
      cache_read(addr_of(2,0,0), d, h);
         check_flag("tag2 survived eviction : hit", h, 1'b1);
      cache_read(addr_of(3,0,0), d, h);
         check_flag("tag3 survived eviction : hit", h, 1'b1);
      // ... and the LRU victim is gone
      cache_read(addr_of(1,0,0), d, h);
         check_flag("tag1 was the LRU victim : miss", h, 1'b0);

      $display("================================================================");
      $display(" C. write-allocate / write miss (set 1)");
      $display("================================================================");
      // write to an empty set -> write miss -> allocate (fetch) -> write word
      cache_write(addr_of(0,1,2), V_WB, h);
         check_flag("write tag0 set1 : write miss (allocate)", h, 1'b0);
      cache_read(addr_of(0,1,2), d, h);
         check_flag("read-back written word : hit", h, 1'b1);
         check_eq  ("read-back written word : value", d, V_WB);
      cache_read(addr_of(0,1,0), d, h);
         check_eq  ("same block, untouched word : original", d, addr_of(0,1,0));

      $display("================================================================");
      $display(" D. write-back of a dirty victim (set 1)");
      $display("================================================================");
      // fill the other three ways of set 1, then bring a 5th tag to evict the
      // dirty tag0 block. The write-back must land in main memory.
      cache_read(addr_of(1,1,0), d, h); check_flag("tag1 set1 : miss", h, 1'b0);
      cache_read(addr_of(2,1,0), d, h); check_flag("tag2 set1 : miss", h, 1'b0);
      cache_read(addr_of(3,1,0), d, h); check_flag("tag3 set1 : miss", h, 1'b0);
      // dirty tag0 is now LRU -> evicted (with write-back) by tag4
      cache_read(addr_of(4,1,0), d, h); check_flag("tag4 set1 : miss (evicts dirty tag0)", h, 1'b0);
      // tag0 is no longer cached; re-reading it refetches from memory, which
      // must now hold the written-back value.
      cache_read(addr_of(0,1,2), d, h);
         check_flag("re-read evicted tag0 : miss", h, 1'b0);
         check_eq  ("write-back persisted to memory", d, V_WB);
      cache_read(addr_of(0,1,0), d, h);
         check_eq  ("other words of block kept original", d, addr_of(0,1,0));

      $display("================================================================");
      $display(" E. plain write hit on a resident clean line (set 2)");
      $display("================================================================");
      cache_read (addr_of(7,2,4), d, h);
         check_flag("prime tag7 set2 : miss", h, 1'b0);
      cache_write(addr_of(7,2,4), V_WH, h);
         check_flag("write resident line : write hit", h, 1'b1);
      cache_read (addr_of(7,2,4), d, h);
         check_flag("read-back : hit", h, 1'b1);
         check_eq  ("read-back : value", d, V_WH);

      $display("================================================================");
      $display(" SUMMARY: %0d / %0d checks passed", passed, total);
      if (passed == total) $display(" RESULT : ALL TESTS PASSED");
      else                 $display(" RESULT : %0d FAILURE(S)", total - passed);
      $display("================================================================");

      repeat (2) @(posedge clock);
      $finish;
   end

endmodule
