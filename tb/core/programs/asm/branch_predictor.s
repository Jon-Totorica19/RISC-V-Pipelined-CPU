# Branch Predictor Test
# Case 1: Predict NOT-TAKEN, Actual NOT-TAKEN  (correct,      0-cycle penalty)
# Case 2: Predict NOT-TAKEN, Actual TAKEN      (misprediction, 2-cycle penalty)
# Case 3: Predict TAKEN,     Actual TAKEN      (correct,      1-cycle penalty)
# Case 4: Predict TAKEN,     Actual NOT-TAKEN  (misprediction, 2-cycle penalty)

.section .text
.global _start

_start:
    addi x1, x0, 0        # x1 = 0  (sum)
    addi x2, x0, 1        # x2 = 1  (counter)
    addi x3, x0, 3        # x3 = 3  (limit)
    addi x4, x0, 10       # x4 = 10 (≠ x2, for Case 1 not-taken branch)

    # Case 1: BHT[beq PC] = 01 → predict NT. x2(1) ≠ x4(10) → actual NT. Correct.
    beq  x2, x4, c1_skip
    addi x10, x0, 1       # x10 = 1 (must execute — branch not taken)
c1_skip:

    # Case 2 (iter 1): BHT[bge PC] = 01 → predict NT. 3≥2 → actual T. Misprediction. BHT→10
    # Case 3 (iter 2): BHT[bge PC] = 10 → predict T.  3≥3 → actual T. Correct.     BHT→11
    # Case 4 (exit):   BHT[bge PC] = 11 → predict T.  3<4  → actual NT. Misprediction. BHT→10
loop:
    add  x1, x1, x2       # sum += i
    addi x2, x2, 1        # i++  (gap=0 → EX/MEM forward to bge)
    bge  x3, x2, loop     # if limit >= i, loop

    addi x11, x0, 7       # x11 = 7 (sentinel — confirms exit from loop)

halt:
    jal  x0, halt