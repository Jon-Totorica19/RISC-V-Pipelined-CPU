SIM = verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES  = $(PWD)/../../rtl/common/riscv_pkg.sv

VERILOG_SOURCES += $(PWD)/../../rtl/core/reg_file.sv

TOPLEVEL = reg_file

MODULE   = test_reg_file

EXTRA_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim