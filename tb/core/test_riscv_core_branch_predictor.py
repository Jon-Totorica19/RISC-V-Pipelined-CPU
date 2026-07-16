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
async def test_integration_test(dut):
    await load_program(dut, "programs/hex/branch_predictor.hex") # Load hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # First 4 instr. BEQ: WB (No stalls, Predict: NT Actual: NT), ADDI: MEM, ADD: EX, ADDI: ID, BGE: IF
    for _ in range(8):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # BGE: ID. Predict: NT. ADDI: IF
    for _ in range(1):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # BGE: EX. (Actual: T). ADDI: Flush, JAL (Wrong Path): IF
    for _ in range(1):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[10].value == 1, f"Reg x10: {dut.reg_file.regs[10].value}"

    # BGE: MEM. JAL: FLushed. Target ADD: IF
    for _ in range(1):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # ADD: MEM ADDI: EX. BGE : ID. Predict: T ADDI: IF
    for _ in range(3): 
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # ADD: WB. ADDI: MEM. BGE: EX. (Actual T). ADDI: Flush. Target ADD: IF
    for _ in range(1):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # BGE: MEM. ADD: ID. ADDI: IF
    for _ in range(1):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")


    # Bubble: WB ADD: MEM ADDI: EX BGE: ID (Predict T) ADDI: IF
    for _ in range(2):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # BGE: EX (Actual NT). ADDI: Flushed ADD (Wrong Path): IF
    for _ in range(1):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # ADD: FLushed. ADDI: IF
    for _ in range(1):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # ADDI: Complete. JAL:WB
    for _ in range(5):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[1].value == 6, f"Reg x1: {dut.reg_file.regs[1].value}"
    assert dut.reg_file.regs[2].value == 4, f"Reg x2: {dut.reg_file.regs[2].value}"
    assert dut.reg_file.regs[3].value == 3, f"Reg x3: {dut.reg_file.regs[3].value}"
    assert dut.reg_file.regs[4].value == 10, f"Reg x4: {dut.reg_file.regs[4].value}"
    assert dut.reg_file.regs[11].value == 7, f"Reg x7: {dut.reg_file.regs[11].value}"

