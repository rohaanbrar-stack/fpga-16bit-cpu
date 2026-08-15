import sys

INSTRUCTIONS = {
    "add": ("R", 0b0000, 0b000),
    "sub": ("R", 0b0000, 0b001),
    "and": ("R", 0b0000, 0b010),
    "or":  ("R", 0b0000, 0b011),
    "xor": ("R", 0b0000, 0b100),
    "not": ("R", 0b0000, 0b101),
    "shl": ("R", 0b0000, 0b110),
    "shr": ("R", 0b0000, 0b111),
    "li":   ("LI", 0b0001, None),
    "addi": ("I",  0b0010, None),
    "lw":   ("M",  0b0011, None),
    "sw":   ("M",  0b0100, None),
    "beq":  ("B",  0b0101, None),
    "bne":  ("B",  0b0110, None),
    "blt":  ("B",  0b0111, None),
    "j":    ("J",  0b1000, None),
}

# both passes must agree on this or every label after a multi-word line shifts
WORD_COUNT = {
    "neg":  2,
    "li16": 2,
}


def parse_reg(token):
    token = token.strip().lower()
    if not token.startswith("r"):
        raise ValueError(f"expected a register, got '{token}'")
    n = int(token[1:])
    if not 0 <= n <= 7:
        raise ValueError(f"register out of range: '{token}' (only r0..r7 exist)")
    return n


def parse_int(token):
    try:
        return int(token.strip(), 0)
    except ValueError:
        raise ValueError(f"expected a number, got '{token}'")


def parse_mem_operand(token):
    token = token.strip()
    if "(" not in token or not token.endswith(")"):
        raise ValueError(f"expected imm(rs), e.g. 4(r2), got '{token}'")
    offset_text, base_text = token.split("(", 1)
    return parse_int(offset_text), parse_reg(base_text.rstrip(")"))


def parse_sel(token):
    token = token.strip().lower()
    if token not in ("hi", "lo"):
        raise ValueError(f"expected 'hi' or 'lo', got '{token}'")
    return 1 if token == "hi" else 0


def check_range(value, low, high, what):
    if not low <= value <= high:
        raise ValueError(f"{what} out of range: {value} (must be {low}..{high})")
    return value


def need(operands, count, syntax):
    if len(operands) != count:
        raise ValueError(f"expected {count} operands: {syntax}")
    return operands


def strip_comment(line):
    for marker in ("#", ";"):
        if marker in line:
            line = line.split(marker, 1)[0]
    return line.strip()


def split_line(line):
    parts = line.replace(",", " ").split()
    return parts[0].lower(), parts[1:]


def take_label(line):
    if ":" not in line:
        return None, line
    label, rest = line.split(":", 1)
    label = label.strip()
    if not label or " " in label:
        raise ValueError(f"bad label: '{label}'")
    return label, rest.strip()


def word_count(mnemonic):
    return WORD_COUNT.get(mnemonic, 1)


def encode_r(opcode, funct, operands):
    rt = parse_reg(operands[2]) if len(operands) > 2 else 0
    mcode = (opcode << 12) | (parse_reg(operands[0]) << 9) | (parse_reg(operands[1]) << 6) | (rt << 3) | (funct)
    return mcode


def encode_i(opcode, operands):
    need(operands, 3, "addi rd, rs, imm6")
    imm = check_range(parse_int(operands[2]), -32, 31, "imm6")
    mcode = (opcode << 12) | (parse_reg(operands[0]) << 9) | (parse_reg(operands[1]) << 6) | (imm & 0x3F)
    return mcode


def encode_m(opcode, operands):
    need(operands, 2, "lw rd, imm6(rs)")
    imm, rs = parse_mem_operand(operands[1])
    check_range(imm, -32, 31, "imm6")
    mcode = (opcode << 12) | (parse_reg(operands[0]) << 9) | (rs << 6) | (imm & 0x3F)
    return mcode


# rB goes in the upper field and rA in the lower, addr1 is hardwired to
# instr[8:6] and feeds alu.a, so swapping these runs the compare backwards
def encode_b(opcode, operands):
    need(operands, 3, "beq rA, rB, off")
    off = check_range(parse_int(operands[2]), -32, 31, "branch offset")
    mcode = (opcode << 12) | (parse_reg(operands[1]) << 9) | (parse_reg(operands[0]) << 6) | (off & 0x3F)
    return mcode


def encode_li(opcode, operands):
    need(operands, 3, "li rd, hi|lo, imm8")
    imm = check_range(parse_int(operands[2]), 0, 255, "imm8")
    mcode = (opcode << 12) | (parse_reg(operands[0]) << 9) | (parse_sel(operands[1]) << 8) | (imm & 0xFF)
    return mcode


def encode_j(opcode, operands):
    need(operands, 1, "j addr12")
    addr = check_range(parse_int(operands[0]), 0, 4095, "addr12")
    mcode = (opcode << 12) | (addr & 0xFFF)
    return mcode


def resolve_branch(token, labels, addr):
    if token.strip() in labels:
        target = labels[token.strip()]
        return target - addr
    return parse_int(token)


def resolve_jump(token, labels):
    if token.strip() in labels:
        return labels[token.strip()]
    return parse_int(token)


def expand(mnemonic, operands):
    if mnemonic == "mov":
        need(operands, 2, "mov rd, rs")
        return [("or", [operands[0], operands[1], operands[1]])]

    if mnemonic == "nop":
        need(operands, 0, "nop")
        return [("or", ["r7", "r7", "r7"])]

    if mnemonic == "neg":
        need(operands, 2, "neg rd, rs")
        return [("not", [operands[0], operands[1]]), ("addi", [operands[0], operands[0], str(0x1)])]

    if mnemonic == "li16":
        need(operands, 2, "li16 rd, imm16")
        value = check_range(parse_int(operands[1]), 0, 65535, "imm16")
        return [("li", [operands[0], "lo", str(value & 0xFF)]), ("li", [operands[0], "hi", str(value >> 8)])]

    if mnemonic == "bgt":
        need(operands, 3, "bgt rA, rB, off")
        return [("blt", [operands[1], operands[0], operands[2]])]

    return None


def encode(mnemonic, operands, labels, addr):
    expanded = expand(mnemonic, operands)
    if expanded is not None:
        return [encode(mn, ops, labels, addr + i) for i, (mn, ops) in enumerate(expanded)]

    if mnemonic not in INSTRUCTIONS:
        raise ValueError(f"unknown instruction: '{mnemonic}'")

    fmt, opcode, funct = INSTRUCTIONS[mnemonic]

    if fmt == "R":
        return encode_r(opcode, funct, operands)
    if fmt == "I":
        return encode_i(opcode, operands)
    if fmt == "M":
        return encode_m(opcode, operands)
    if fmt == "B":
        need(operands, 3, "beq rA, rB, off|label")
        off = resolve_branch(operands[2], labels, addr)
        return encode_b(opcode, [operands[0], operands[1], str(off)])
    if fmt == "LI":
        return encode_li(opcode, operands)
    if fmt == "J":
        need(operands, 1, "j addr12|label")
        return encode_j(opcode, [str(resolve_jump(operands[0], labels))])

    raise ValueError(f"unknown format '{fmt}' for '{mnemonic}'")


def scan_labels(source_text):
    labels = {}
    addr = 0
    for lineno, raw in enumerate(source_text.splitlines(), start=1):
        line = strip_comment(raw)
        if not line:
            continue
        try:
            label, rest = take_label(line)
            if label is not None:
                if label in labels:
                    raise ValueError(f"duplicate label: '{label}'")
                labels[label] = addr
            if rest:
                mnemonic, _ = split_line(rest)
                addr += word_count(mnemonic)
        except Exception as e:
            raise SystemExit(f"line {lineno}: {e}\n    {raw.strip()}")
    return labels


def assemble(source_text):
    labels = scan_labels(source_text)

    words = []
    addr = 0
    for lineno, raw in enumerate(source_text.splitlines(), start=1):
        line = strip_comment(raw)
        if not line:
            continue
        try:
            _, rest = take_label(line)
            if not rest:
                continue
            mnemonic, operands = split_line(rest)
            emitted = encode(mnemonic, operands, labels, addr)
            if isinstance(emitted, int):
                emitted = [emitted]
            if len(emitted) != word_count(mnemonic):
                raise ValueError(f"'{mnemonic}' emitted {len(emitted)} word(s) but WORD_COUNT says {word_count(mnemonic)}")
            words.extend(emitted)
            addr += len(emitted)
        except Exception as e:
            raise SystemExit(f"line {lineno}: {e}\n    {raw.strip()}")
    return words


def write_mem(path, words):
    with open(path, "w") as f:
        for w in words:
            f.write(f"{w:04X}\n")


TESTS = [
    ("add  r1, r2, r3",  0x0298),
    ("sub  r7, r0, r1",  0x0E09),
    ("or   r1, r3, r3",  0x02DB),
    ("not  r2, r5",      0x0545),
    ("addi r1, r2, -1",  0x22BF),
    ("lw   r1, 4(r2)",   0x3284),
    ("sw   r1, 4(r2)",   0x4284),
    ("beq  r1, r2, 3",   0x5443),
    ("li   r4, hi, 0x01",0x1901),
    ("j    12",          0x800C),
    ("mov  r1, r3",      0x02DB),
    ("nop",              0x0FFB),
    ("neg  r1, r2",      [0x0285, 0x2241]),
    ("li16 r1, 0x1234",  [0x1234, 0x1312]),
    ("bgt  r1, r2, 3",   0x7283),
    ("blt  r1, r2, 3",   0x7443),
]

ERROR_TESTS = [
    ("addi r1, r2",     "3 operands"),
    ("lw   r1, 4",      "imm(rs)"),
    ("beq  r1, r2, 99", "out of range"),
    ("li   r1, up, 5",  "hi"),
    ("addi r9, r1, 1",  "out of range"),
    ("frob r1, r2, r3", "unknown instruction"),
]


def self_test():
    passed = failed = 0

    for text, expected in TESTS:
        mnemonic, operands = split_line(text)
        got = encode(mnemonic, operands, {}, 0)
        if isinstance(got, int):
            got = [got]
        if isinstance(expected, int):
            expected = [expected]

        shown = " ".join(f"{w:04X}" for w in got)
        if got == expected:
            print(f"ok    {text:<20} -> {shown}")
            passed += 1
        else:
            want = " ".join(f"{w:04X}" for w in expected)
            print(f"FAIL  {text:<20} -> {shown}, expected {want}")
            failed += 1

    for text, want in ERROR_TESTS:
        try:
            mnemonic, operands = split_line(text)
            got = encode(mnemonic, operands, {}, 0)
        except Exception as e:
            if want in str(e):
                print(f"ok    {text:<20} -> rejected: {e}")
                passed += 1
            else:
                print(f"FAIL  {text:<20} -> wrong error: {e}")
                failed += 1
        else:
            print(f"FAIL  {text:<20} -> accepted, gave {got}")
            failed += 1

    print(f"\n{passed} passed, {failed} failed")
    return failed == 0


USAGE = """usage:
  python tools/asm.py programs/myprog.asm            -> programs/imem.mem
  python tools/asm.py programs/myprog.asm out.mem
  python tools/asm.py --test
"""

DEFAULT_OUTPUT = "programs/imem.mem"

if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--test":
        sys.exit(0 if self_test() else 1)

    if len(sys.argv) not in (2, 3):
        print(USAGE)
        sys.exit(1)

    source = sys.argv[1]
    output = sys.argv[2] if len(sys.argv) == 3 else DEFAULT_OUTPUT

    with open(source) as f:
        words = assemble(f.read())
    write_mem(output, words)
    print(f"{len(words)} instructions -> {output}")
