SIM = verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES  = $(PWD)/../../rtl/common/riscv_pkg.sv

VERILOG_SOURCES += $(PWD)/../../rtl/core/data_mem.sv

TOPLEVEL = data_mem

MODULE   = test_data_mem

EXTRA_ARGS += --trace

COMPILE_ARGS += --trace-depth 2

include $(shell cocotb-config --makefiles)/Makefile.sim