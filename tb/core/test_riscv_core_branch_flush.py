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
async def test_branch_flush(dut):
    await load_program(dut, "programs/hex/branch_flush.hex") # Load hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # First 5 instr
    for _ in range(9):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # BEQ Instr, next two to get flushed, and one the correct instr to be jumped to
    for _ in range(8):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[10].value == 1, f"x10: {dut.reg_file.regs[10].value}"

    # BNE Instr, next two, target instr
    for _ in range(8):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[11].value == 2, f"x11: {dut.reg_file.regs[11].value}"

    # BLT Instr, next two, target instr
    for _ in range(8):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[12].value == 3, f"x11: {dut.reg_file.regs[12].value}"

    # BGE Instr, next two, target instr
    for _ in range(8):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[13].value == 4, f"x11: {dut.reg_file.regs[13].value}"

    # BLTU Instr, next two, target instr
    for _ in range(8):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[14].value == 5, f"x11: {dut.reg_file.regs[14].value}"

    # BGEU Instr, next two, target instr
    for _ in range(8):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[15].value == 6, f"x11: {dut.reg_file.regs[15].value}"

    # BEQ not taken, next instr
    for _ in range(2):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[16].value == 7, f"x11: {dut.reg_file.regs[16].value}"
