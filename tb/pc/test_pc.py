import cocotb
from cocotb.triggers import Timer, RisingEdge

async def generate_clock(dut):
    while True:
        dut.clk.value = 0
        await Timer(5, unit="ns")
        dut.clk.value = 1
        await Timer(5, unit="ns")

@cocotb.test()
async def test_pc(dut):
    cocotb.start_soon(generate_clock(dut))

    # Initialize next_pc to 0
    dut.next_pc.value = 0
    await Timer(1, unit="ns")

    # Test: Initialization to 0
    assert dut.pc_addr.value == 0, "PC should be initialized to 0"

    # Test: Update pc on clk edge
    dut.next_pc.value = 4
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.pc_addr.value == 4, "PC should update on clock edge"

    # Test: Sequential Increments (Simulate a program)
    for i in range(1, 5):
        dut.next_pc.value = i * 4
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        assert dut.pc_addr.value == i*4, f"PC should be: {i*4}"

    await Timer(4,unit="ns")
