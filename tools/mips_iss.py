from pathlib import Path
import isa_defs

class MipsISS:
    # (Constructor)
    def __init__(self, log_path=None):
        # Program Counter (PC)
        self.pc = isa_defs.PC_START
        # Register File
        self.regs = [0] * 32
        # Memory (Not nessury)
        self.mem = {}
        # Finish Flag
        self.halted = False

        if log_path is None:
            project_root = Path(__file__).resolve().parent.parent
            self.log_path = project_root / "sim" / "logs" / "iss_trace.log"
        else:
            self.log_path = Path(log_path)

        self.log_path.parent.mkdir(parents=True, exist_ok=True)
    
    def reset(self):
        self.pc = isa_defs.PC_START
        self.regs = [0] * 32
        self.mem.clear()
        self.halted = False

    def load_hex(self, file_path):
        address = isa_defs.PC_START
        
        with open(file_path, 'r') as f:
            for line in f:
                clean_line = line.strip()
                
                if not clean_line:
                    continue
                
                instruction = int(clean_line, 2)
                
                # Store the instruction value in the memory dictionary
                self.mem[address] = instruction
                
                # Move to the next address
                address += isa_defs.PC_STEP
    def fetch(self):
        instruction = self.mem.get(self.pc, 0)
        return instruction

    def decode(self, instruction):
        
        return {
            "opcode": (instruction >> 26) & 0x3F,          # 6 bits
            "rs":     (instruction >> 21) & 0x1F,          # 5 bits
            "rt":     (instruction >> 16) & 0x1F,          # 5 bits
            "rd":     (instruction >> 11) & 0x1F,          # 5 bits
            "shamt":  (instruction >> 6)  & 0x1F,          # 5 bits
            "funct":  instruction & 0x3F,                  # 6 bits
            "imm":    instruction & 0xFFFF,                # 16 bits
            "address":(instruction & 0x03FFFFFF)           # 26 bits
        }
    def sign_extend_16(self, val):
        if val & 0x8000:
            return val - 0x10000
        return val

    def to_signed_32(self, val):
        val = val & 0xFFFFFFFF
        if val & 0x80000000:
            return val - 0x100000000
        return val

    def write_reg(self, reg_num, val):
        if reg_num != 0:
            self.regs[reg_num] = val & 0xFFFFFFFF

    def execute(self, decoded):
        opcode = decoded["opcode"]
        rs = decoded["rs"]
        rt = decoded["rt"]
        rd = decoded["rd"]
        funct = decoded["funct"]
        imm = decoded["imm"]

        val_rs = self.regs[rs]
        val_rt = self.regs[rt]

        match opcode:
            # 1. R-Type (Opcode == 0)
            case 0x00:
                match funct:
                    case 0x20:  # add
                        self.write_reg(rd, val_rs + val_rt)
                    case 0x22:  # sub
                        self.write_reg(rd, val_rs - val_rt)
                    case 0x24:  # and
                        self.write_reg(rd, val_rs & val_rt)
                    case 0x25:  # or
                        self.write_reg(rd, val_rs | val_rt)
                    case 0x2A:  # slt (Signed comparison)
                        res = 1 if self.to_signed_32(val_rs) < self.to_signed_32(val_rt) else 0
                        self.write_reg(rd, res)
                    case _:
                        pass  # default
                
                self.pc += isa_defs.PC_STEP

            # 2. I-Type
            case 0x08:  # addi
                simm = self.sign_extend_16(imm)
                self.write_reg(rt, val_rs + simm)
                self.pc += isa_defs.PC_STEP

            case 0x0C:  # andi
                self.write_reg(rt, val_rs & imm)
                self.pc += isa_defs.PC_STEP

            case 0x0D:  # ori
                self.write_reg(rt, val_rs | imm)
                self.pc += isa_defs.PC_STEP
                
            # 3. Memory Instructions
            case 0x23:  # lw (Load Word)
                address = self.regs[rs] + self.sign_extend_16(imm)
                self.write_reg(rt, self.mem.get(address, 0))
                self.pc += isa_defs.PC_STEP

            case 0x2B:  # sw (Store Word)
                address = self.regs[rs] + self.sign_extend_16(imm)
                self.mem[address] = self.regs[rt] & 0xFFFFFFFF
                self.pc += isa_defs.PC_STEP
            
            # 4. Branch & Jump
            case 0x04:  # beq
                if val_rs == val_rt:
                    # PC jumps to PC + 1 + sign_extended_imm
                    self.pc += (1 + self.sign_extend_16(imm))
                else:
                    self.pc += isa_defs.PC_STEP

            case 0x02:  # j
                # Jump address is typically (address << 2)
                self.pc = decoded["address"]

            case _:
                # Handle unknown opcode (default)
                pass

    def trace(self, log_file, pc, instruction, decoded):
        log_file.write(f"PC:{hex(pc)} | Inst:{hex(instruction)} | Op:{hex(decoded['opcode'])}\n")
        # with open("iss_trace.log", "a") as f:
        #     f.write(f"PC:{hex(pc)} | Inst:{hex(instruction)} | Op:{hex(decoded['opcode'])}\n")

    def run(self, steps=1000):
        # open("iss_trace.log", "w").close()
        with open(self.log_path, "w") as log_file:
            for _ in range(steps):

                if self.halted:
                    break

                if self.pc not in self.mem:
                    self.halted = True
                    break

                pc_current = self.pc
                instr = self.fetch()
                dec = self.decode(instr)
            
                self.trace(log_file, pc_current, instr, dec)
                self.execute(dec)
            
                if pc_current == self.pc:
                    self.halted = True
                    

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 tools/mips_iss.py <program.hex> [custom_log_path]")
        sys.exit(1)
        
    hex_file = sys.argv[1]
    custom_log = sys.argv[2] if len(sys.argv) > 2 else None

    iss = MipsISS(log_path=custom_log)
    iss.load_hex(hex_file)
    iss.run()
    print(f"Simulation finished. Check {iss.log_path}")
