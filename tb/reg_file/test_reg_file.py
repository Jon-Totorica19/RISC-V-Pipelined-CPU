import cocotb 
from cocotb.triggers import Timer, RisingEdge

async def generate_clock(dut):
    while True:
        dut.clk.value = 0
        await Timer(5, unit="ns")
        dut.clk.value = 1
        await Timer(5, unit="ns")

@cocotb.test()
async def test_reg_file(dut):
    cocotb.start_soon(generate_clock(dut))

    # Initialize all regs and RegWrite to 0
    for i in range(32):
        dut.regs[i].value = 0
    dut.RegWrite.value = 0
    await Timer(1, unit="ns") # Allow signal to propogate

    # Test: Write to desination reg
    dut.RegWrite.value = 1
    dut.rd.value = 5
    dut.WriteData.value = 0xBEEFBEEF
    await RisingEdge(dut.clk) # Writes occur on the rising edge
    await Timer(1, unit="ns")
    assert dut.regs[5].value == 0xBEEFBEEF, "0xBEEFBEEF should be written to reg 5"

    dut.rd.value = 23
    dut.WriteData.value = 0xAAAABBBB
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.regs[23].value == 0xAAAABBBB, "0xAAAABBBB should be written to reg 23"

    # Test: Write to reg x0
    dut.rd.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.regs[0].value == 0, "Reg x0 should not be overwritten"

    # Test: RegWrite=0 does not write
    dut.RegWrite.value = 0
    dut.rd.value = 5
    dut.WriteData.value = 0x11111111
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.regs[5].value == 0xBEEFBEEF, "RegWrite = 0, should not overwrite reg 5"

    await Timer(5, unit="ns")

    # Test Read rs1
    dut.rs1.value = 0x05
    await Timer(1, unit="ns")
    assert dut.rd1.value == 0xBEEFBEEF, "Should give the data of address rs1, reg 5"

    await Timer(5, unit="ns")


    # Test Read rs2
    dut.rs2.value = 0x17
    await Timer(1, unit="ns")
    assert dut.rd2.value == 0xAAAABBBB, "Should give the data of address rs2, reg 23"

    await Timer(5, unit="ns")


    # Test Read x0
    dut.rs1.value = 0
    await Timer(1, unit="ns")
    assert dut.rd1.value == 0, "Reading reg 0 should always give 0"

    await Timer(5, unit="ns")
    