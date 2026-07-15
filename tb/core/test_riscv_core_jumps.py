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
async def test_jumps(dut):
    await load_program(dut, "programs/hex/jumps.hex") # Load hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Instr 1-2. In cycle 4, Instr 2 (jal) in EX stage, Instr 3 flushed in ID, instr 4 flushed in IF.
    # In cycle 5, jal: MEM, target instr 5: IF
    # In cycle 6, jal: WB, target instr 5: ID
    for _ in range(6):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[1].value == 0x08, f"reg x1: {dut.reg_file.regs[1].value}"

    # Instr 5 complete. Instr 6 WB. Instr 7: MEM. Instr 8,9 flushed. Instr 10: target IF
    for _ in range(3):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[10].value == 0x01, f"reg x10: {dut.reg_file.regs[10].value}"

    # Instr 6, 7, 10 complete
    for _ in range(7):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[2].value == 0x24, f"reg x2: {dut.reg_file.regs[2].value}"
    assert dut.reg_file.regs[3].value == 0x1C, f"reg x3: {dut.reg_file.regs[3].value}"
    assert dut.reg_file.regs[11].value == 0x2, f"reg x11: {dut.reg_file.regs[11].value}"




