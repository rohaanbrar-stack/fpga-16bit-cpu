# Verilog 16-Bit CPU

![HDL](https://img.shields.io/badge/HDL-Verilog-blue) ![Board](https://img.shields.io/badge/board-Basys%203-green) ![FPGA](https://img.shields.io/badge/FPGA-Artix--7-red)

A 16-bit CPU designed and built from scratch on a Digilent Basys 3 — custom instruction set, hand-drawn datapath, single-cycle, written in plain Verilog. Not a softcore port and not a RISC-V implementation: the point is designing the architecture, not transcribing someone else's spec.

## Approach

Learning FPGA design from zero, one rung at a time. Every phase has a gate that has to pass before the next one starts — the toolchain gets proven with a blinking LED before any logic is designed, blocks get simulated before they're synthesized, and the instruction set gets written on paper before any RTL exists. Nothing is built on an unproven layer.

## Hardware

- Digilent Basys 3 — Xilinx Artix-7 XC7A35T-1CPG236C
- ~20,800 LUTs, ~41,600 flip-flops, 1.8 Mb block RAM
- 100 MHz onboard oscillator
- 16 switches, 16 LEDs, 4-digit 7-segment, 5 buttons
- Built-in USB-UART bridge — the output path once programs are running
- Vivado ML Standard, Verilog

## Status

- Phase 0 — Toolchain + flash pipeline ✅ (2026-07-29 — blink running on hardware)
- Phase 1 — HDL fundamentals, simulation-first ✅ (2026-08-01 — blocks simulated, mux confirmed on hardware)
- Phase 2 — ISA + datapath on paper, no RTL ✅ (2026-08-02 — 16 instructions, datapath drawn)
- Phase 3 — Datapath blocks, each with its own testbench ⬜
- Phase 4 — Control unit + single-cycle integration ⬜
- Phase 5 — On-hardware bring-up, state observable over UART ⬜
- Phase 6 — Python assembler, demo program ⬜

Locked so far: single-cycle before anything else (pipelining is explicitly out of scope for now), Harvard memory model on block RAM, 8 registers, 16 instructions across four formats.

## Phase 1 — Simulation

A 2:1 mux, an 8-bit register with synchronous reset and clock enable, a 2→4 decoder, and an 8-bit ALU. Each one written, testbenched, and read in the waveform viewer before anything reached the board.

The mux is built twice — once with `assign`, once with `always @(*)` — and its testbench instantiates both against shared stimulus. Identical outputs across all eight input combinations, which makes "the two styles synthesize to the same hardware" something measured here rather than taken on faith.

Choosing test operands turned out to be the real skill. Driving the ALU with `a=08, b=08` makes AND and OR return the same value, so a swapped opcode would look correct; fix that with `a=08, b=04` and `a+b` collides with `a|b` instead, because operands sharing no bits generate no carries. A testbench that can't tell a right answer from a wrong one passes either way.

## Phase 2 — Instruction Set

Sixteen bits doesn't leave much room, so most of the ISA decided itself.

Register count went first. Sixteen registers need 4-bit fields, three per instruction, leaving 4 bits of opcode — exactly 16 patterns for a target of 16–25 instructions. The encoding is full before anything gets named. So: 8 registers, 3 bits each.

Opcode width was the real corner. Five bits allows 32 instructions but shrinks the immediate to ±16, which hurts as a load offset. Three bits allows only 8 instructions. Neither works. But an R-type only uses 13 of its 16 bits — opcode plus three register names — so three bits sit idle on every arithmetic instruction. Hand those three bits the job of picking *which* ALU operation and all eight arithmetic ops share one opcode, which frees 15 opcodes and keeps the wide immediate. It's MIPS's funct field; I got there by staring at the unused bits.

Constants have the same problem. `addi` reaches ±32 and registers hold 16 bits. An instruction naming only a destination costs 7 bits and leaves 9 — one as a high/low selector, eight left, exactly a byte. Two of them build any 16-bit value. The usual answer is two opcodes, `lui` and `lli`; putting the selector inside the instruction costs one, and a byte split has no use for a ninth bit anyway.

No hardwired zero register. With 8 registers, storage is scarce and opcodes aren't, so spending a register to save encoding space is the wrong trade. `mov` is `or rd, rs, rs`, `nop` is `or r7, r7, r7`, negate is `not` then `addi rd, rd, 1`.

```
R:  op(4)  rd(3)  rs(3)  rt(3)  funct(3)     add sub and or xor not shl shr
I:  op(4)  rd(3)  rs(3)  imm(6)              addi lw sw beq bne blt
J:  op(4)  addr(12)                          j
LI: op(4)  rd(3)  sel(1) imm8(8)             li
```

Drawing the datapath is what audits the encoding. `rd` sits at bits 11–9 and `rs` at bits 8–6 in every format that uses them, so those wires run straight to the register file with no mux in between — two muxes that never had to be built. The five left over are ALU input B, write-back source, second read address, next PC, and the byte splice in `li`. That list is the whole job of the control unit.

## Repo Structure

```
fpga-16bit-cpu/
├── phase0-blink/      # First working bitstream
├── phase1-sim/        # HDL blocks + their testbenches
│   ├── src/
│   └── tb/
└── constraints/       # Digilent Basys 3 master XDC
```

Vivado project directories are gitignored — they're regenerated by synthesis and accounted for 98% of the Phase 0 project's size. Only sources and constraints are tracked.

## Author

Rohaan Brar — digital design learning project, Purdue CompE.
