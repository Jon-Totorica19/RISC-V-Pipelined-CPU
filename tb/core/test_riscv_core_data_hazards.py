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
async def test_data_hazards(dut):
    await load_program(dut, "programs/hex/data_hazards.hex") # Load hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # First three instr. Instr 3 completes on end of cycle 7 (cycle 8)
    for _ in range(7):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[3].value == 15, f"Reg x3: {dut.reg_file.regs[3].value}"

    # Complete instr 4-7
    for _ in range(4):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[5].value == 18, f"Reg x5: {dut.reg_file.regs[5].value}"
    assert dut.reg_file.regs[6].value == 36, f"Reg x6: {dut.reg_file.regs[6].value}"
    assert dut.reg_file.regs[7].value == 36, f"Reg x7: {dut.reg_file.regs[7].value}"

    # Complete instr 8-10
    for _ in range(3):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[9].value == 10, f"Reg x9: {dut.reg_file.regs[9].value}"