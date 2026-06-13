IVERILOG := iverilog
VVP      := vvp

# Flags
IVERILOG_FLAGS := -Wall -g2012 -Iinclude
VVP_FLAGS      := -l sim/vvp.log

# Directories
BUILD_DIR := build
VCD_DIR   := sim
SRC_DIR   := src
TB_DIR    := tb

# All RTL sources (testbenches excluded)
VERILOG_SOURCES := $(wildcard $(SRC_DIR)/*.sv)

# Testbenches to build and run (names must match the top module name)
TESTBENCHES := cache_controller_tb

# Default: compile and run all testbenches
.PHONY: all
all: prepare $(TESTBENCHES)

# Output directories
prepare:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(VCD_DIR)

# Compile a testbench (plus all RTL sources) into a vvp image.
# NOTE: -o must come BEFORE the source files; the Windows iverilog v12 build
# rejects "-o" placed after the source list ("-o: No such file or directory").
$(BUILD_DIR)/%.out: $(TB_DIR)/%.sv $(VERILOG_SOURCES)
	@echo "Compiling $< (and sources) -> $@"
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ -s $(*F) $(VERILOG_SOURCES) $<

# Run a compiled testbench, capture log, move the VCD into sim/
run_%: $(BUILD_DIR)/%.out
	@echo "Running $(*F)"
	$(VVP) $< $(VVP_FLAGS) | tee $(VCD_DIR)/$*.log
	if [ -f $*.vcd ]; then mv $*.vcd $(VCD_DIR)/; fi

# Pattern rule for running testbenches by name
$(TESTBENCHES): %: run_%

# Open the waveform of the cache testbench
.PHONY: waves
waves: $(VCD_DIR)/cache_controller_tb.vcd
	gtkwave $< &

# Cleanup
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) $(VCD_DIR)
