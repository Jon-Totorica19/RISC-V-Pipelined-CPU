SIM = verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES  = $(PWD)/../../rtl/common/riscv_pkg.sv

VERILOG_SOURCES += $(PWD)/../../rtl/core/control_unit.sv

TOPLEVEL = control_unit

MODULE   = test_control_unit

EXTRA_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim