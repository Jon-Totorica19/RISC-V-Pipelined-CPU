import cocotb
from cocotb.triggers import Timer, RisingEdge

async def generate_clock(dut):
    while True:
        dut.clk.value = 0
        await Timer(5, unit="ns")
        dut.clk.value = 1
        await Timer(5, unit="ns")

@cocotb.test()
async def test_data_mem(dut):
    cocotb.start_soon(generate_clock(dut))

    # Initialize all mem to 0, MemRead, MemWrite = 0
    for i in range(256):
        dut.mem[i].value = 0
    dut.MemRead.value = 0
    dut.MemWrite.value = 0
    await Timer(1, unit="ns")

    # Test: Write to mem on MemWrite = 0
    dut.writeData.value = 0xBEEFBEEF
    dut.addr.value = 20
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.mem[5].value == 0, "Mem should not be written on MemWrite = 0"

    await Timer(3, unit="ns")

    # Test: Write to mem
    dut.MemWrite.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.mem[5].value == 0xBEEFBEEF, "Reg 5 should be written to"

    await Timer(3, unit="ns")

    # Write a second value
    dut.addr.value = 800
    dut.writeData.value = 0xAAAABBBB
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.mem[200].value == 0xAAAABBBB, "Reg 200 should be written to"

    await Timer(3, unit="ns")

    # Test: Read from mem
    dut.MemWrite.value = 0
    dut.MemRead.value = 1
    await Timer(1, unit="ns")
    assert dut.readData.value == 0xAAAABBBB, "Data should be read from mem[200]"

    await Timer(3, unit="ns")



