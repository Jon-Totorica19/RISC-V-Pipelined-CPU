SIM = verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES  = $(PWD)/../../rtl/common/riscv_pkg.sv

VERILOG_SOURCES += $(PWD)/../../rtl/core/imm_gen.sv

TOPLEVEL = imm_gen

MODULE   = test_imm_gen

EXTRA_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim