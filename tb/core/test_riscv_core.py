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

# Test R format: ADD and SUB (check funct7 decode works)
@cocotb.test()
async def test_r_type(dut):
    await load_program(dut, "programs/hex/r_type.hex") # Load hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # ADD instructions run
    # 3 instructions = 3 cycles
    for _ in range(3):
        await RisingEdge(dut.clk)

    await Timer(1, unit="ns")

    assert dut.reg_file.regs[3].value == 15, f"Add failed: x3 = {dut.reg_file.regs[3].value}"

    # SUB instruction run
    await RisingEdge(dut.clk)
    await Timer(1,unit="ns")
    assert dut.reg_file.regs[4].value == 5, f"Sub failed: x4 = {dut.reg_file.regs[4].value}"

# Test I-ALU: ADDI and SRAI
@cocotb.test()
async def test_i_alu_type(dut):
    await load_program(dut, "programs/hex/i_alu.hex") # Load Hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    

    # Reset Regs
    for _ in range(4):
        await RisingEdge(dut.clk)

    # ADDI 
    await RisingEdge(dut.clk)
    await Timer(1,unit="ns")

    assert dut.reg_file.regs[1].value == 10, f"Addi failed: x1 = {dut.reg_file.regs[1].value}"

    # SRAI 
    await RisingEdge(dut.clk)
    await Timer(1,unit="ns")

    assert dut.reg_file.regs[2].value == 2, f"Addi failed: x1 = {dut.reg_file.regs[2].value}"

# Test LW, SW
@cocotb.test()
async def test_lw_sw(dut):
    await load_program(dut, "programs/hex/lw_sw.hex") # Load Hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Reset Regs, set x1 = 10
    for _ in range(3):
        await RisingEdge(dut.clk)

    # SW
    await RisingEdge(dut.clk)
    await Timer(1,unit="ns")

    assert dut.data_mem.mem[1].value == 10, f"sw failed: mem[1] = {dut.data_mem.mem[1].value}"

    # LW
    await RisingEdge(dut.clk)
    await Timer(1,unit="ns")

    assert dut.reg_file.regs[2].value == 10, f"lw failed: x2 = {dut.reg_file.regs[2].value}"

# Test LUI, AUIPC
@cocotb.test()
async def test_lui_auipc(dut):
    await load_program(dut, "programs/hex/lui_auipc.hex") # Load Hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Reset Regs
    for _ in range(2):
        await RisingEdge(dut.clk)

    # lui
    await RisingEdge(dut.clk)
    await Timer(1,unit="ns")

    assert dut.reg_file.regs[5].value == 0xBEEFF000, f"lui failed: reg[5] = {dut.reg_file.regs[5].value}"

    # auipc
    await RisingEdge(dut.clk)
    await Timer(1,unit="ns")

    assert dut.reg_file.regs[6].value == 0x0000100C, f"auipc failed: x6 = {dut.reg_file.regs[6].value}"

# Test JAL, JALR
@cocotb.test()
async def test_jal_jalr(dut):
    await load_program(dut, "programs/hex/jal_jalr.hex") # Load Hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # JAL 
    for _ in range(2):
        await RisingEdge(dut.clk)

    await Timer(1, unit="ns")
    assert dut.reg_file.regs[1].value == 4, f"jal failed x1 = {dut.reg_file[1].value}"
    assert dut.reg_file.regs[10].value == 0, f"jal failed x10 = {dut.reg_file[10].value}"
    assert dut.reg_file.regs[2].value == 1, f"jal failed x2 = {dut.reg_file[2].value}"

    for _ in range(4):
        await RisingEdge(dut.clk)

    await Timer(1, unit="ns")
    assert dut.reg_file.regs[3].value == 28, f"auipc failed x3 = {dut.reg_file[3].value}"
    assert dut.reg_file.regs[4].value == 24, f"jalr failed x4 = {dut.reg_file[4].value}"
    assert dut.reg_file.regs[11].value == 0, f"jal failed x11 = {dut.reg_file[11].value}"
    assert dut.reg_file.regs[7].value == 1, f"jal failed x7 = {dut.reg_file[7].value}"

# Test B type all of BEQ, BNE, BGE, BLT, BLTU, BGEU
@cocotb.test()
async def test_b_type(dut):
    await load_program(dut, "programs/hex/branch.hex") # Load Hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Reset Regs then set x1 = 5, x2 = 3
    for _ in range(9):
        await RisingEdge(dut.clk)

    # BEQ Not taken, x3 = 1
    for _ in range(3):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[3].value == 1, f"BEQ not taken failed: x3 = {dut.reg_file.regs[3].value}"

    # BNE Taken, x4 = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[4].value == 1, f"BNE not taken failed: x4 = {dut.reg_file.regs[4].value}"

    # BLT Taken, x5 = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[5].value == 1, f"BLT not taken failed: x5 = {dut.reg_file.regs[5].value}"

    # BGE Taken, x6 = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[6].value == 1, f"BGE not taken failed: x6 = {dut.reg_file.regs[6].value}"

    # BLTU Taken, x7 = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[7].value == 1, f"BLTU not taken failed: x7 = {dut.reg_file.regs[7].value}"

     # BGEU Taken, x6 = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[8].value == 1, f"BGEU not taken failed: x8 = {dut.reg_file.regs[8].value}"


    







