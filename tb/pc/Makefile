SIM = verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES  = $(PWD)/../../rtl/common/riscv_pkg.sv

VERILOG_SOURCES += $(PWD)/../../rtl/core/pc.sv

TOPLEVEL = pc

MODULE   = test_pc

EXTRA_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim