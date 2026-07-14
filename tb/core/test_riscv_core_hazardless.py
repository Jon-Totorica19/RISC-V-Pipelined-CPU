import cocotb
from cocotb.triggers import RisingEdge, Timer


# Helper function to load the assemble the hex file into words and load them into instruction memeory
async def load_program(dut, hex_path):
    # Parse the sysverilog hex file and load into instr_mem
    with open(hex_path, 'r') as f:
        addr = 0
        for line in f:
            line = line.strip()
            if line.startswith('@'):
                addr = int(line[1:], 16) // 4  # convert byte address to word index
            elif line:
                # each line has space-separated bytes in little-endian order
                bytes_ = line.split()
                for i in range(0, len(bytes_), 4):
                    if i + 3 < len(bytes_):
                        word = int(bytes_[i], 16) | \
                               int(bytes_[i+1], 16) << 8 | \
                               int(bytes_[i+2], 16) << 16 | \
                               int(bytes_[i+3], 16) << 24
                        dut.instr_mem.mem[addr].value = word
                        addr += 1

# Generate the clock
async def generate_clock(dut):
    while True:
        dut.clk.value = 0
        await Timer(5, unit="ns")
        dut.clk.value = 1
        await Timer(5, unit="ns")

# Test hazard free program with pipelined CPU
@cocotb.test()
async def test_hazardless(dut):
    await load_program(dut, "programs/hex/no_hazards.hex") # Load hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # ADDI instr 1, 2, 3, 4, 5 (x1=5, x2=10, x4=3, x8=100) 
    # First 4 instructions run. Instr 5 fetched on cycle 5, complete on cycle 9
    for _ in range(9):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # After 9 cycles (during the 10th cycle), instr 6: WB (x3 = 15, in the mem/wb pipeline reg and will be written to reg file on the next rising edge) instr 7: MEM instr 8: EX instr 9: ID instr 10: IF
    assert dut.reg_file.regs[1].value == 5, f"Reg x1 = {dut.reg_file.regs[1].value}"
    assert dut.reg_file.regs[2].value == 10, f"Reg x2 = {dut.reg_file.regs[2].value}"
    assert dut.reg_file.regs[4].value == 3, f"Reg x4 = {dut.reg_file.regs[4].value}"
    assert dut.reg_file.regs[8].value == 100, f"Reg x8 = {dut.reg_file.regs[8].value}"
    assert dut.mem_wb_reg.alu_result.value == 15, f"Reg x3 value to be written to reg file next rising edge = {dut.mem_wb_reg.alu_result.value}"

    # Instr 6 completes at end of cycle 10
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.reg_file.regs[3].value == 15, f"Reg x3 = {dut.reg_file.regs[3].value}"

    # Instr 7 completes at end of cycle 11
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.reg_file.regs[9].value == 50, f"Reg x9 = {dut.reg_file.regs[9].value}"

    # Instr 8 completes at end of cycle 12
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.reg_file.regs[10].value == 7, f"Reg x10 = {dut.reg_file.regs[10].value}"

    # Instr 9-13 run. Cycle 13, 14, 15, 16, 17. Instr 14 (sw) in MEM, value written to data mem after cycle 17
    for _ in range(5):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[5].value == 12, f"Reg x5 = {dut.reg_file.regs[5].value}"
    assert dut.reg_file.regs[11].value == 1, f"Reg x11 = {dut.reg_file.regs[11].value}"
    assert dut.reg_file.regs[12].value == 2, f"Reg x12 = {dut.reg_file.regs[12].value}"
    assert dut.data_mem.mem[0].value == 12, f"Mem[0] = {dut.data_mem.mem[0].value}"

    # Instr 14-17 run. Instr 17 fetched on cycle 17. Completes after cycle 21
    for _ in range(8):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[13].value == 9, f"Reg 13 = {dut.reg_file.regs[13].value}"
    assert dut.reg_file.regs[14].value == 8, f"Reg x14 = {dut.reg_file.regs[14].value}"
    assert dut.reg_file.regs[6].value == 12, f"Reg x6 = {dut.reg_file.regs[6].value}"

    # Instr 18-21
    for _ in range(8):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[15].value == 62, f"Reg x15 = {dut.reg_file.regs[15].value}"







    
