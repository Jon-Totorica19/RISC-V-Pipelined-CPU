# bubble_sort.s
# Sorts [5, 3, 8, 1, 4] stored at byte addresses 0x0–0x10
# Result: data_mem[0..4] = [1, 3, 4, 5, 8]
#
# Register map:
#   x5  = outer counter i
#   x6  = inner counter j
#   x7  = base address of array
#   x8  = N (5)
#   x9  = arr[j]
#   x10 = arr[j+1]
#   x11 = byte address of arr[j]
#   x12 = inner loop limit (N-1-i)

.section .text
.globl _start
_start:

    # store array into memory
    addi x7, x0, 0
    addi x9, x0, 5
    sw   x9,  0(x7)        # arr[0] = 5
    addi x9, x0, 3
    sw   x9,  4(x7)        # arr[1] = 3
    addi x9, x0, 8
    sw   x9,  8(x7)        # arr[2] = 8
    addi x9, x0, 1
    sw   x9, 12(x7)        # arr[3] = 1
    addi x9, x0, 4
    sw   x9, 16(x7)        # arr[4] = 4

    # bubble sort
    addi x8, x0, 5         # N = 5
    addi x5, x0, 0         # i = 0

outer_loop:
    addi x12, x8, -1       # x12 = N-1
    sub  x12, x12, x5      # x12 = N-1-i
    addi x6,  x0,  0       # j = 0

inner_loop:
    bge  x6, x12, inner_done   # exit if j >= N-1-i

    slli x11, x6,  2       # x11 = j * 4
    add  x11, x11, x7      # x11 = &arr[j]
    lw   x9,  0(x11)       # x9  = arr[j]
    lw   x10, 4(x11)       # x10 = arr[j+1]   <-- load-use stall here

    bge  x10, x9, no_swap  # arr[j+1] >= arr[j], skip swap

    sw   x10, 0(x11)       # arr[j]   = arr[j+1]
    sw   x9,  4(x11)       # arr[j+1] = arr[j]

no_swap:
    addi x6, x6, 1         # j++
    jal  x0, inner_loop

inner_done:
    addi x5, x5, 1         # i++
    blt  x5, x8, outer_loop

    # load sorted array into registers for assertion
    lw x20,  0(x7)         # x20 = arr[0]  (expect 1)
    lw x21,  4(x7)         # x21 = arr[1]  (expect 3)
    lw x22,  8(x7)         # x22 = arr[2]  (expect 4)
    lw x23, 12(x7)         # x23 = arr[3]  (expect 5)
    lw x24, 16(x7)         # x24 = arr[4]  (expect 8)

halt:
    jal x0, halt