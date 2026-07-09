#!/bin/bash
# assemble.sh - usage: ./assemble.sh <name>
# e.g. ./assemble.sh r_type

NAME=$1
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o obj/$NAME.o asm/$NAME.s
riscv64-unknown-elf-ld -m elf32lriscv -Ttext=0x0 -o elf/$NAME.elf obj/$NAME.o
riscv64-unknown-elf-objcopy -O verilog elf/$NAME.elf hex/$NAME.hex
echo "Done: hex/$NAME.hex"