SIM = verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES  = $(PWD)/../../rtl/common/riscv_pkg.sv

VERILOG_SOURCES += $(PWD)/../../rtl/core/alu_control.sv

TOPLEVEL = alu_control

MODULE   = test_alu_control

EXTRA_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim