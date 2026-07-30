# FPGA & Verilog — Crash Course
*Written 2026-07-29, the night the first bitstream blinked. Reference doc — reread it, don't memorize it.*

Assumes you know C and bare-metal embedded, and that you've built a CPU from gates in nandgame. Both help. One of them will also actively mislead you, and this document says where.

---

## 1. The mental model

### An FPGA is not a processor

Your STM32 has a fixed circuit. Software is a list of instructions it fetches and executes, one after another, forever.

An FPGA has **no fixed circuit and no instructions**. It is a field of configurable logic and programmable wires. You describe a circuit; the tools configure the fabric to *physically become* that circuit. There is no program counter, nothing "runs."

| | STM32 | FPGA |
|---|---|---|
| What you write | instructions | a circuit description |
| What the chip does | fetch, decode, execute | *is* the circuit |
| Order of execution | sequential | everything, always, at once |
| To do 2 things at once | interrupts / time-slicing | build two circuits |
| Speed limit | clock × cycles per instruction | how fast signals settle through logic |

### Verilog is not a programming language

This is the shift that breaks C programmers, and it will break you a few times before it sticks.

```verilog
assign x = a & b;
assign y = c | d;
```

These are **not** two statements executed in order. They are **two pieces of circuitry that both exist, permanently and simultaneously**. Swapping the lines changes nothing. There is no "before" or "after." A Verilog file is a wiring diagram written in text.

Whenever you're confused about what code does, ask: **"what hardware does this describe?"** Not "what happens when this runs."

### What nandgame gave you, and what it costs you

**Keeps its value:** the architecture. Datapaths, ALUs, register files, program counters, instruction decode, how a jump works. You already understand *why* a CPU is shaped the way it is. That's most of the battle.

**Actively misleads:** building everything from NAND gates. FPGAs have **no gates**. Writing gate-level Verilog produces slower, larger designs than describing behavior and letting synthesis do its job — and it would make a CPU take all summer. See §5.

---

## 2. What's actually on the chip

Your Artix-7 XC7A35T contains, in round numbers:

| Resource | Count | What it is |
|---|---|---|
| **LUTs** | ~20,800 | 6-input lookup tables — all combinational logic |
| **Flip-flops** | ~41,600 | 1-bit storage, one per clock edge |
| **Block RAM** | 50 × 36 Kb | real memory blocks (~1.8 Mb total) |
| **DSP slices** | 90 | hardware multiply-accumulate |
| **Carry chains** | in every slice | dedicated fast adder hardware |
| **Clock buffers (BUFG)** | 32 | low-skew global clock distribution |
| **I/O pins** | 106 usable | package balls |

### The LUT — the single most important idea

**A LUT is a tiny memory, not a gate.** A 6-input LUT is **64 bits of SRAM plus a 64-to-1 multiplexer**. The six inputs are used as an *address*; the output is the bit stored there.

To implement a function, you store its **truth table**:

- 2-input AND → store `1` only at address `11`
- 3-input XOR → store `1` at every odd-parity address
- any 6-input monstrosity → store all 64 rows

Any function of ≤6 inputs has a ≤64-row truth table. A LUT6 holds exactly 64 bits. **That's why it's universal.**

Two consequences:

- **Complexity is free up to 6 inputs.** A 6-input XOR and a 2-input AND cost the same one LUT and the same delay. "Simpler gate = faster" is a gate-world intuition that does not apply.
- **Past 6 inputs you pay.** Wider functions need cascaded LUTs, and each hop adds delay. This is why wide logic is slow and why timing closure exists.

### The flip-flop (FDRE)

Xilinx names decode: **FD** = D flip-flop, **R** = synchronous **R**eset, **E** = clock **E**nable.

```
on rising edge of C:
    if (R)       Q <= 0
    else if (CE) Q <= D
    else         Q holds
```

Family: `FDRE` (sync reset), `FDSE` (sync set), `FDCE` (async clear), `FDPE` (async preset). Same physical flip-flop, configured by the bitstream.

**`CE` is free and important.** "Update this register only when X" costs nothing — it's built into the flip-flop. Without it you'd need a feedback mux burning LUTs. You'll use CE constantly: the register file only writes on write instructions, the PC only loads a target on jumps.

### Carry chains

Every slice has dedicated adder hardware wired to the slice **above** it. When you write `+`, synthesis grabs this instead of building an adder from LUTs.

**Visible consequence:** carry chains run *vertically up a column*, so any arithmetic gets placed as a vertical stripe on the die. You saw this in the Device view.

### The bitstream

Not a program. It is **the contents of several million configuration memory cells**: every LUT's 64 truth-table bits, every interconnect switch position, every I/O buffer's voltage standard, every flip-flop's power-up value.

Loading it doesn't tell the chip what to do — it makes the chip *become* your circuit.

It lives in **SRAM**, so it's **volatile**: power-cycle and the chip is blank. Program the QSPI flash instead if you want it to survive (mode jumper to QSPI; the FPGA self-loads at power-up in about a second).

---

## 3. Verilog from zero

### Modules

The unit of design. Like a chip you can instantiate.

```verilog
module adder16(
    input  [15:0] a,        // 16-bit input
    input  [15:0] b,
    input         cin,      // 1-bit (no range = 1 bit)
    output [15:0] sum,
    output        cout
);
    assign {cout, sum} = a + b + cin;
endmodule
```

`{cout, sum}` is **concatenation** — a 17-bit bundle. `a + b + cin` produces 17 bits, split across carry-out and sum. Idiomatic and worth remembering.

### `wire` vs `reg`

The worst-named thing in Verilog.

- **`wire`** — a connection. Driven continuously by `assign` or by a module's output. Has no memory.
- **`reg`** — a variable assigned inside a procedural block (`always`, `initial`).

**`reg` does NOT mean flip-flop.** A `reg` assigned in `always @(*)` becomes pure combinational logic. Whether you get a flip-flop depends *entirely* on whether you used `posedge clk`. The name is a historical accident. Ignore what it implies.

Rule of thumb: if you assign it inside an `always` block, declare it `reg`. Otherwise `wire`.

*(SystemVerilog's `logic` replaces both and Vivado supports it. Stick with `wire`/`reg` — nearly every tutorial and reference you'll find uses them.)*

### Numbers and widths

```verilog
4'b1010      // 4 bits, binary       = 10
8'hFF        // 8 bits, hex          = 255
16'd1000     // 16 bits, decimal     = 1000
1'b0         // single bit zero
26'd0        // 26-bit zero
```

Format is `<width>'<base><value>`. `b`=binary, `h`=hex, `d`=decimal, `o`=octal.

**Always specify the width.** A bare `0` is a 32-bit integer, and width mismatches don't error — they silently truncate or zero-extend. This is a top-three source of bugs that simulate fine and behave wrong.

### Vectors

```verilog
reg [15:0] data;      // 16 bits, numbered 15 down to 0
wire [7:0] low;

assign low = data[7:0];      // slice — bits 7 through 0
assign msb = data[15];       // single bit
```

`[high:low]`, **inclusive both ends**, so the width is `high - low + 1`. `[25:0]` is 26 bits. Off-by-one lives here.

Selecting a bit that doesn't exist doesn't error — it becomes a **constant**. Silent, and your LED sits dark.

### Operators

```verilog
// Bitwise (operate per-bit, result is a vector)
a & b    a | b    a ^ b    ~a

// Logical (operate on truth, result is 1 bit)
a && b   a || b   !a

// Reduction (fold a vector into 1 bit)
&a       // AND of all bits
|a       // OR of all bits  → handy: |a is "a is nonzero"
^a       // XOR of all bits → parity

// Arithmetic
a + b    a - b    a * b

// Shifts
a << 2   a >> 2

// Comparison
a == b   a != b   a < b   a >= b

// Concatenation and replication
{a, b}          // bundle together
{4{1'b1}}       // 1111 — four copies
{a, {3{1'b0}}}  // a followed by 000

// Ternary — this is a MUX in hardware
assign y = sel ? a : b;
```

Reduction operators are underrated. `assign zero_flag = ~|result;` is "result is all zeros" — exactly the ALU zero flag you need.

### Parameters

Named constants. Use them for opcodes.

```verilog
localparam OP_ADD = 4'b0000;
localparam OP_SUB = 4'b0001;

parameter WIDTH = 16;        // can be overridden at instantiation
reg [WIDTH-1:0] data;
```

`localparam` can't be overridden — use it for anything that's genuinely fixed, like opcode encodings.

### Instantiating modules

```verilog
adder16 my_adder (
    .a    (operand_a),      // .port_name (your_signal)
    .b    (operand_b),
    .cin  (1'b0),
    .sum  (result),
    .cout (carry_out)
);
```

**Always use named ports** (`.a(...)`), never positional. Positional connection silently misconnects when you reorder ports later.

---

## 4. The three patterns (this is 95% of all Verilog you'll write)

### Pattern 1 — combinational, simple: `assign`

```verilog
assign y       = a & b;
assign alu_b   = use_imm ? immediate : reg_b;   // a mux
assign is_zero = ~|result;
```

For anything expressible as one expression. Output must be a `wire`.

### Pattern 2 — combinational, complex: `always @(*)`

```verilog
always @(*) begin
    case (op)
        3'b000: result = a + b;
        3'b001: result = a - b;
        3'b010: result = a & b;
        3'b011: result = a | b;
        3'b100: result = a ^ b;
        default: result = 16'b0;      // ← never omit this
    endcase
end
```

- `@(*)` means "re-evaluate whenever any input changes" — i.e. continuously, like a wire.
- Use **blocking `=`** here.
- Output must be declared `reg` (even though it's combinational — see the naming complaint above).
- **Every branch must assign every output.** See §6 on latches.

### Pattern 3 — sequential: `always @(posedge clk)`

```verilog
always @(posedge clk) begin
    if (rst)       pc <= 16'b0;
    else if (jump) pc <= jump_target;
    else           pc <= pc + 1;
end
```

- Use **non-blocking `<=`** here. Always.
- This is the *only* construct that creates flip-flops.
- Unassigned in some branch = **holds its value**, which is correct and desirable here.

### The rule

> **`<=` inside `posedge` blocks. `=` inside `always @(*)`. Never mix them, never assign one signal from two blocks.**

---

## 5. Blocking vs non-blocking — the one that matters

The most common source of "it simulates fine but hardware is wrong."

### `=` (blocking) — executes immediately, in order

```verilog
always @(posedge clk) begin
    b = a;      // b gets a NOW
    c = b;      // c gets the NEW b — so c gets a
end
```
Result: **one** flip-flop. `a` flows through to both.

### `<=` (non-blocking) — all right-hand sides sampled first, then all assigned

```verilog
always @(posedge clk) begin
    b <= a;     // b will get a
    c <= b;     // c gets the OLD b
end
```
Result: **two** flip-flops in a shift register. This is what real hardware does — every flip-flop captures its input simultaneously on the edge.

### Why it matters

Non-blocking models actual flip-flop behavior: they all sample their inputs at the same instant, *before* any output changes. Blocking assignment in a clocked block describes something a real edge-triggered register can't do, and simulation and synthesis can disagree about it.

**Just follow the rule: `<=` in clocked blocks, `=` in combinational blocks.** You will not be wrong.

---

## 6. Traps that bite everyone

### Inferred latches

```verilog
always @(*) begin
    if (enable)
        y = a;          // what is y when enable is 0?
end
```

Verilog's answer: "y keeps its old value" — which requires **memory**, so synthesis builds a **latch**. Latches are transparent, hard to time, and almost never what you meant. Vivado will warn.

**Two fixes, both good:**
```verilog
always @(*) begin
    y = 1'b0;           // default first, then override
    if (enable) y = a;
end
```
```verilog
always @(*) begin
    if (enable) y = a;
    else        y = 1'b0;      // complete the if
end
```

Same rule drives the `default:` in every `case`.

**Note the asymmetry:** in a *clocked* block, "holds its value" is exactly right and gives you a flip-flop with a clock enable. Incomplete assignment is only a bug in combinational blocks.

### Multiple drivers

Assigning one signal from two `always` blocks (or an `assign` plus an `always`) is two circuits fighting over one wire. Synthesis errors out. **One signal, one driver, always.**

### Width mismatches

```verilog
reg [7:0]  small;
reg [15:0] big;
small <= big;         // silently drops the top 8 bits — no error
```

No warning by default in many cases. Check your widths.

### `reg` is not a register

Said three times because it's caught everyone since 1995.

### Uninitialized state

Unlike C, this is *fine* on Xilinx FPGAs: the bitstream sets every flip-flop's power-up value, defaulting to zero. Your blink counter genuinely started at 0 with no reset.

You'll still want an explicit reset in real designs — for restarting without a power cycle, and because it makes intent clear.

### Simulation-only constructs

`initial`, `#10` delays, `$display` — these exist for testbenches. Delays are **ignored** by synthesis. (Xilinx does honor `initial` for register initialization, unlike ASIC flows — so advice you read online may not apply here.)

---

## 7. Simulation and testbenches

**This is Phase 1, and it's where you'll actually live.** Implementation takes minutes; simulation takes seconds. Debug in sim, confirm on hardware.

A testbench is a Verilog module with **no ports** that instantiates your design, drives its inputs, and watches its outputs.

```verilog
`timescale 1ns / 1ps

module adder16_tb;

    // Signals to drive the DUT (Device Under Test)
    reg  [15:0] a, b;
    reg         cin;
    wire [15:0] sum;
    wire        cout;

    // Instantiate what we're testing
    adder16 dut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    initial begin
        a = 16'd0;  b = 16'd0;  cin = 1'b0;
        #10;                                  // wait 10 ns
        if (sum !== 16'd0) $display("FAIL: 0+0 gave %d", sum);

        a = 16'd5;  b = 16'd7;
        #10;
        $display("5 + 7 = %d (expected 12)", sum);

        a = 16'hFFFF; b = 16'd1;
        #10;
        $display("overflow: sum=%h cout=%b", sum, cout);

        $finish;                              // end simulation
    end
endmodule
```

### Generating a clock

For anything sequential:

```verilog
reg clk = 1'b0;
always #5 clk = ~clk;      // flip every 5ns → 10ns period → 100 MHz
```

That `always` has no `posedge` — it's a free-running simulation construct, not hardware.

### Useful system tasks

| Task | Does |
|---|---|
| `$display("fmt", args)` | print once, like `printf` |
| `$monitor("fmt", args)` | print automatically whenever an argument changes |
| `$finish` | end the simulation |
| `$time` | current sim time |

Format specifiers: `%d` decimal, `%h` hex, `%b` binary, `%t` time.

### `!==` vs `!=`

Use `===` / `!==` in testbenches. They compare `x` (unknown) and `z` (high-impedance) properly; `==` returns `x` when either side is unknown, so a check can silently neither pass nor fail.

### Running it in Vivado

Add the testbench under **Simulation Sources**, then **Run Simulation → Run Behavioral Simulation**. The waveform viewer opens.

**Reading waveforms is the core skill.** Add signals from the scope panel, zoom to a transition, and check: did this register update on the edge you expected, with the value you expected? Most bugs are visible in about ten seconds once you can read them.

---

## 8. The Vivado flow

| Stage | Input → Output | What happens |
|---|---|---|
| **Elaboration** | RTL → generic schematic | parses Verilog, builds device-independent logic. Syntax errors surface here. |
| **Synthesis** | generic → netlist | maps to real primitives: LUTs, FDREs, carry chains, BUFGs. First device-specific step. |
| **Opt Design** | netlist → smaller netlist | removes redundancy. *This is what turns an out-of-range bit select into a constant.* |
| **Place** | netlist → placed design | assigns every primitive a physical site on the die |
| **Route** | placed → routed | configures interconnect switches to wire it together |
| **Timing analysis** | routed → reports | checks every path settles within the clock period |
| **Bitstream** | routed → `.bit` | writes the configuration memory contents |
| **Program** | `.bit` → chip | shifts it in over JTAG; the fabric becomes your circuit |

**Look at the schematics.** `RTL Analysis → Schematic` shows the generic logic your Verilog implies. `Open Synthesized Design → Schematic` shows the actual primitives. Cross-probing between schematic, netlist, and Device view is the best learning tool in the whole toolchain.

---

## 9. Constraints (XDC)

Verilog says *what the logic is*. The XDC says *where it physically connects and how fast the clock runs*. Neither is inferable from the other — the tools have no idea a 100 MHz oscillator is soldered to ball W5 on this particular PCB.

It's **Tcl**, not Verilog.

```tcl
## Pin assignment + electrical standard (compact -dict form)
set_property -dict { PACKAGE_PIN W5  IOSTANDARD LVCMOS33 } [get_ports clk]

## Equivalent long form
set_property PACKAGE_PIN W5      [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Timing: 10 ns period = 100 MHz
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
```

- `get_ports <name>` matches your **top module's port name, exactly**. Rename a port in Verilog and forget the XDC → "no ports matched."
- Every top-level port needs a pin, or bitstream generation is blocked by DRC.
- `LVCMOS33` = 3.3 V CMOS, what the Basys 3's I/O banks run at.
- Digilent's `Basys-3-Master.xdc` (in this folder) lists every pin on the board, all commented. Uncomment what you need. **Watch out:** it assumes vector ports like `led[0]` — if your port is a scalar `led`, drop the index and braces.

---

## 10. Reading the reports

### Utilization

`Reports → Report Utilization`. Shows LUTs, FFs, BRAM, DSP used vs available. Watch the trend as your CPU grows, not the absolute number.

### Timing

The number that matters is **WNS — Worst Negative Slack**.

- **WNS positive** → timing met. Signals settle with room to spare.
- **WNS negative** → **timing failed**. Some path can't settle within one clock period. The bitstream may still build, and the hardware will behave erratically in ways that look like logic bugs.

**Always check WNS before believing hardware results.** This is the FPGA equivalent of your "green build + bumped marker" ritual — a check you do *before* trusting output, not after being confused by it.

Fixing negative slack, roughly in order of preference: reduce logic depth between registers, pipeline (insert a register stage), or lower the clock frequency.

---

## 11. Glossary

| Term | Meaning |
|---|---|
| **RTL** | Register Transfer Level — describing what happens to values between register stages |
| **Netlist** | list of primitives and their connections |
| **Primitive** | a physical building block: LUT6, FDRE, CARRY4, BUFG, OBUF |
| **LUT** | Lookup Table — 64-bit memory implementing any ≤6-input function |
| **FDRE** | D flip-flop with sync Reset and clock Enable |
| **BUFG** | Global clock buffer — puts a clock on the low-skew global network |
| **IBUF / OBUF** | input / output pin buffer |
| **BRAM** | Block RAM — dedicated on-chip memory blocks |
| **Slice** | a group of LUTs + flip-flops + carry logic |
| **CLB** | Configurable Logic Block — contains slices |
| **Bitstream** | the configuration data that makes the fabric become your circuit |
| **Synthesis** | RTL → netlist of primitives |
| **Implementation** | netlist → placed and routed physical design |
| **Slack / WNS** | timing margin; negative means failure |
| **DUT** | Device Under Test — what a testbench instantiates |
| **XDC** | Xilinx Design Constraints — pins and timing, in Tcl |
| **Inferred latch** | accidental memory from an incomplete combinational assignment |

---

## 12. How to design (the actual method)

> **A digital design is registers holding state, with combinational logic between them computing the next state.**

Three questions, in order:

1. **What state does my machine have?** (PC, register file, flags, memory)
2. **For each piece of state — what is its next value, as a function of current state and inputs?**
3. Write that function as combinational logic, and clock it.

You stop asking *"how do I build this from gates"* and start asking *"what should this register become next tick."*

### Why a single-cycle CPU is less scary than it sounds

It has surprisingly **little** state: the PC, the register file, and data memory. Everything else is one big combinational cloud.

One cycle: PC drives instruction memory → decode → register file reads → ALU computes → result routes back to the write port. **All of it settles combinationally within one clock period**, then every register latches simultaneously on the edge.

Which is also why "does my CPU run at 100 MHz?" is exactly the question "does that whole chain settle in under 10 ns?" — and the timing report answers it for you.

### Draw it first

Your Phase 2 gate is *"ISA spec + datapath diagram exist before any RTL."* That's not bureaucracy. Draw the boxes and arrows on paper; each box becomes a module with the shapes from §4. **The diagram is the design. The Verilog is transcription.**

---

## Quick reference card

```verilog
// COMBINATIONAL — simple
assign y = sel ? a : b;

// COMBINATIONAL — complex (default first, avoid latches!)
always @(*) begin
    y = 1'b0;
    case (op)
        2'b00: y = a & b;
        default: y = 1'b0;
    endcase
end

// SEQUENTIAL — flip-flops
always @(posedge clk) begin
    if (rst)     q <= 16'd0;
    else if (en) q <= d;
end

// MEMORY ARRAY
reg [15:0] mem [0:255];
assign rd = mem[addr];                          // comb read
always @(posedge clk) if (we) mem[addr] <= wd;  // clocked write

// INSTANTIATION — always named ports
adder16 u_add (.a(x), .b(y), .cin(1'b0), .sum(s), .cout(c));
```

**The rule that prevents most bugs:** `<=` in clocked blocks, `=` in combinational blocks, one driver per signal, always write the `default`.
