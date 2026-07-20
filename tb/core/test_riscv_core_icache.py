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
async def test_icache(dut):
    await load_program(dut, "programs/hex/icache.hex") # Load hex file
    # Reset PC
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Instr 1 cold miss. 10 cycle penalty. Count stalls for instr 1 to ensure 10
    stall_count = 0
    for _ in range(11):
        await Timer(1, unit="ns")
        if dut.icache_stall.value == 1:
            stall_count += 1
        await RisingEdge(dut.clk)
    

    assert stall_count == 10, f"Expected 10-cycle miss penalty, got {stall_count}"

    # Instr 1 IF-WB complete. Instr 2 completes cycle 4 of miss.
    for _ in range(5):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[1].value == 3, f"Reg x1: {dut.reg_file.regs[1].value}"

    # Instr 2 completes miss penalty
    for _ in range(6):
        await RisingEdge(dut.clk)

    # Instr 2 completes. Instr 3 complete cycle 4 of miss
    for _ in range(5):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    assert dut.reg_file.regs[1].value == 2, f"Reg x1: {dut.reg_file.regs[1].value}"

    # Instr 3 completes miss penalty
    for _ in range(6):
        await RisingEdge(dut.clk)

    # Instr 3 Completes. Instr 2 iter 2. hit, no miss penalty, in WB
    for _ in range(5):
        await RisingEdge(dut.clk)

    # Instr 2, iter. 2 complete. Instr 3 iter 2, IF
    for _ in range(1):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns") 

    assert dut.reg_file.regs[1].value == 2, f"Reg x1: {dut.reg_file.regs[1].value}"

    # Instr 3 iter 2, ID. Instr 4, IF, but it is a miss. Predict branch taken during miss cycle 1 of instr 4.
    for _ in range(1):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # No need to track each instr by cycle. Allow the whole program to complet. Estimate 300 cycles at least
    for _ in range(300):
        await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # Loop exits with x1=0
    assert dut.reg_file.regs[1].value == 0,  f"x1={dut.reg_file.regs[1].value}"

    # Branch-during-miss: skip branch taken, wrong path never ran
    assert dut.reg_file.regs[3].value == 42, f"x3={dut.reg_file.regs[3].value}"

    assert dut.reg_file.regs[10].value == 0, f"x10={dut.reg_file.regs[10].value}"

    # Conflict miss: 0x100 evicted 0x000 lines
    assert dut.reg_file.regs[4].value == 1,  f"x4={dut.reg_file.regs[4].value}"
    
    assert dut.reg_file.regs[5].value == 2,  f"x5={dut.reg_file.regs[5].value}"







