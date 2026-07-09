SIM = verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES  = $(PWD)/../../rtl/common/riscv_pkg.sv

VERILOG_SOURCES += $(PWD)/../../rtl/core/alu.sv

TOPLEVEL = alu

MODULE   = test_alu

EXTRA_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim