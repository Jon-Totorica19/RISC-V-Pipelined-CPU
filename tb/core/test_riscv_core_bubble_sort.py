import cocotb
from cocotb.triggers import RisingEdge, Timer


async def load_program(dut, hex_path):
    with open(hex_path, 'r') as f:
        addr = 0
        for line in f:
            line = line.strip()
            if line.startswith('@'):
                addr = int(line[1:], 16) // 4
            elif line:
                bytes_ = line.split()
                for i in range(0, len(bytes_), 4):
                    if i + 3 < len(bytes_):
                        word = int(bytes_[i], 16) | \
                               int(bytes_[i+1], 16) << 8 | \
                               int(bytes_[i+2], 16) << 16 | \
                               int(bytes_[i+3], 16) << 24
                        dut.instr_mem.mem[addr].value = word
                        addr += 1


async def generate_clock(dut):
    while True:
        dut.clk.value = 0
        await Timer(5, unit="ns")
        dut.clk.value = 1
        await Timer(5, unit="ns")


@cocotb.test()
async def test_bubble_sort(dut):
    await load_program(dut, "programs/hex/bubble_sort.hex")
    dut.rst.value = 1
    cocotb.start_soon(generate_clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # 1000 cycles: ~270 icache cold misses + ~50 dcache cold misses + ~200 execution
    for _ in range(1000):
        await RisingEdge(dut.clk)

    # Sorted array is in dcache (write-back, never evicted to data_mem).
    # Program loads arr[0..4] into x20-x24 before halting so we can assert registers.
    assert dut.reg_file.regs[20].value == 1, f"arr[0]: expected 1, got {dut.reg_file.regs[20].value}"

    assert dut.reg_file.regs[21].value == 3, f"arr[1]: expected 3, got {dut.reg_file.regs[21].value}"

    assert dut.reg_file.regs[22].value == 4, f"arr[2]: expected 4, got {dut.reg_file.regs[22].value}"

    assert dut.reg_file.regs[23].value == 5, f"arr[3]: expected 5, got {dut.reg_file.regs[23].value}"
    
    assert dut.reg_file.regs[24].value == 8, f"arr[4]: expected 8, got {dut.reg_file.regs[24].value}"