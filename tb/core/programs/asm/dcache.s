# Data Cache Test
# Expected: x1=7, x2=7, x3=99, x4=200, x5=77, x6=7, x7=100, x8=7, x9=100
# In the testbench teh follwoing will be initialized: 
# mem[0] (0x000) = 7
# mem[1] (0x004) = 11
# mem[64] (0x100) = 100
# wmem[65] (0x104) = 200

.section .text
.global _start

_start:
    # Test 1: Load cold miss
    lw x1, 0(x0)          # miss, x1 = 7

    # Test 2: Load hit
    lw x2, 0(x0)          # hit, x2 = 7

    # Test 3: Store cold miss (write-allocate)
    addi x10, x0, 42
    sw x10, 4(x0)         # miss, fetch 0x004, write 42, dirty

    # Test 4: Store hit
    addi x11, x0, 99
    sw x11, 4(x0)         # hit, write 99, overwrite 42 in the cache

    # Test 5: Load hit after store
    lw x3, 4(x0)          # hit, x3 = 99

    # Test 6: Dirty miss - 0x104 conflicts with dirty 0x004 (index=1)
    lw x4, 260(x0)        # 11-cycle dirty miss, writeback 0x004, fetch 0x104, x4=200

    # Test 7: Store miss then load hit
    addi x12, x0, 77
    sw x12, 8(x0)         # miss, fetch 0x008, write 77, dirty
    lw x5, 8(x0)          # hit, x5 = 77

    # Test 8: Conflict miss (clean eviction)
    lw x6, 0(x0)          # hit, x6 = 7
    lw x7, 256(x0)        # miss, clean evict 0x000, fetch 0x100, x7 = 100
    lw x8, 0(x0)          # miss, clean evict 0x100, fetch 0x000, x8 = 7

    # Test 9: Dirty conflict miss
    addi x13, x0, 55
    sw x13, 0(x0)         # hit, write 55 to cache, dirty
    lw x9, 256(x0)        # 11-cycle dirty miss, writeback 55 to 0x000, fetch 0x100, x9=100

halt:
    jal x0, halt