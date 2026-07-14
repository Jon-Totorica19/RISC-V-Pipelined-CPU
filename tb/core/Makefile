SIM = verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES  = $(PWD)/../../rtl/common/riscv_pkg.sv

VERILOG_SOURCES += \
	$(PWD)/../../rtl/core/alu.sv \
	$(PWD)/../../rtl/core/alu_control.sv \
	$(PWD)/../../rtl/core/reg_file.sv \
	$(PWD)/../../rtl/core/imm_gen.sv \
	$(PWD)/../../rtl/core/pc.sv \
	$(PWD)/../../rtl/core/instr_mem.sv \
	$(PWD)/../../rtl/core/data_mem.sv \
	$(PWD)/../../rtl/core/control_unit.sv \
	$(PWD)/../../rtl/core/if_id_reg.sv \
	$(PWD)/../../rtl/core/id_ex_reg.sv \
	$(PWD)/../../rtl/core/ex_mem_reg.sv \
	$(PWD)/../../rtl/core/mem_wb_reg.sv \
	$(PWD)/../../rtl/core/forwarding_unit.sv \
	$(PWD)/../../rtl/core/riscv_core.sv

TOPLEVEL = riscv_core

MODULE = test_riscv_core_data_hazards

EXTRA_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim