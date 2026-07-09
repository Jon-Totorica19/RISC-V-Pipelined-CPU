import cocotb
from cocotb.triggers import Timer
from itertools import product

def expected_outputs(a, b, alu_ctrl):
    match alu_ctrl:
        case 0: # AND
            result = a & b
        case 1: # OR
            result = a | b
        case 2: # ADD. AND with 0xFFFFFFFF to only keep bottom 32 bits in the case of overflow
            result = (a + b) & 0xFFFFFFFF
        case 3: # SLL. Extract bottom 5 bits of b
            result = (a << (b & 0x1F)) & 0xFFFFFFFF
        case 4: # XOR
            result = a ^ b
        case 5: # SRL
            result = (a >> (b & 0x1F))
        case 6: # SUB
            result = (a - b) & 0xFFFFFFFF
        case 7: # SLT
            # To get the signed versions. 0x8000000 is the cut off for positive (MSB = 0) and negative (MSB = 1)
            # Positiv: Keep as is. Negative: Subtract by 2^32 to get true signed value
            a_s = a if a < 0x80000000 else a - 0x100000000
            b_s = b if b < 0x80000000 else b - 0x100000000
            result = 1 if a_s < b_s else 0
        case 8: # SLTU
            result = 1 if a < b else 0
        case 9: # SRA
            a_s = a if a < 0x80000000 else a - 0x100000000
            result = (a_s >> (b & 0x1F)) & 0xFFFFFFFF
        case _:
            result = 0

    zero = (result & 0xFFFFFFFF == 0)
    return result, zero

@cocotb.test()
async def test_inputs(dut):
    test_vals = [0x00000000, 0x00000001, 0x7FFFFFFF, 0x80000000, 0xFFFFFFFF]

    # Loop through all ALU operations
    for ctrl in range(10):
        dut.alu_ctrl.value = ctrl
        for a, b in product(test_vals, test_vals):
            dut.a.value = a
            dut.b.value = b
            # Allow signal to propogate before using
            await Timer(1, unit="ns")

            expected_result, expected_zero = expected_outputs(a, b, ctrl)

            actual_result = dut.result.value
            actual_zero = dut.zero.value

            assert expected_result == actual_result, (f"Result failed for ctrl={ctrl}, a={hex(a)}, b={hex(b)}")
            assert expected_zero == actual_zero, (f"Zero failed for ctrl={ctrl}, a={hex(a)}, b={hex(b)}")

            await Timer(5, unit="ns")



    await Timer(5, unit="ns")

