PC_START = 0
PC_STEP = 1


REG_MAP = {
    "$zero": 0, "zero": 0,
    "$at": 1,   "at": 1,
    "$v0": 2,   "v0": 2,
    "$v1": 3,   "v1": 3,
    "$a0": 4,   "a0": 4,
    "$a1": 5,   "a1": 5,
    "$a2": 6,   "a2": 6,
    "$a3": 7,   "a3": 7,
    "$a4": 8,   "a4": 8,
    "$t0": 9,   "t0": 9,
}

INSTRUCTIONS = {
    # R-Type: add rd, rs, rt
    "add":  {"type": "R", "opcode": 0, "funct": 0x20},
    "sub":  {"type": "R", "opcode": 0, "funct": 0x22},
    "and":  {"type": "R", "opcode": 0, "funct": 0x24},
    "or":   {"type": "R", "opcode": 0, "funct": 0x25},
    "slt":  {"type": "R", "opcode": 0, "funct": 0x2A},

    # I-Type: addi rt, rs, imm
    "addi": {"type": "I", "opcode": 0x08},
    "andi": {"type": "I", "opcode": 0x0C},
    "ori":  {"type": "I", "opcode": 0x0D},
    "lw":   {"type": "I", "opcode": 0x23},
    "sw":   {"type": "I", "opcode": 0x2B},
    "beq":  {"type": "I", "opcode": 0x04},

    # J-Type: j target
    "j":    {"type": "J", "opcode": 0x02},
    "jal":  {"type": "J", "opcode": 0x03},

    # System / Halt
    "halt": {"type": "H", "opcode": 0x3F},
}

