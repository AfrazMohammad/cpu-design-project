# V1 Assembler Contains:
# Parser
# Operand Validation
# Immediate Parsing and Range Checking
# Instruction Format Checks
# Machine Code Translation
# Hexadecimal Output
# Line-By-Line Error Detection

REGISTERS = {
    "R0" : "000",
    "R1" : "001",
    "R2" : "010",
    "R3" : "011",
    "R4" : "100",
    "R5" : "101",
    "R6" : "110",
    "R7" : "111"
}

OPCODES = {
    "ADD"   :   "0000",
    "ADDI"  :   "0000",

    "SUB"   :   "0001",
    "SUBI"  :   "0001",

    "MUL"   :   "0010",
    "MULI"  :   "0010",

    "AND"   :   "0011",
    "ANDI"  :   "0011",

    "OR"    :   "0100",
    "ORI"   :   "0100",

    "XOR"   :   "0101",
    "XORI"  :   "0101",

    "NOT"   :   "0110",

    "SHL"   :   "0111",
    "SHR"   :   "0111",
    "SHA"   :   "0111",
    "ROR"   :   "0111",

    "LD"    :   "1000",
    "ST"    :   "1000",
    "LDI"   :   "1000",
    "STI"   :   "1000",

    "LDR"   :   "1001",
    "STR"   :   "1001",

    "LI"    :   "1010",
    "LEA"   :   "1010",

    "JAL"   :   "1011",
    "JMP"   :   "1011",
    "JALR"  :   "1011",

    # Reserved : "1100"

    "CMP"   :   "1101",
    "CMPI"  :   "1101",

    "BR"    :   "1110",
    "BEQ"   :   "1110",
    "BNE"   :   "1110",
    "BLT"   :   "1110",
    "BLE"   :   "1110",
    "BGT"   :   "1110",
    "BGE"   :   "1110",

    "NOP"   :   "1111",
    "HALT"  :   "1111"
}

SUBCODES = {
    "SHL"   :   "00",
    "SHR"   :   "01",
    "SHA"   :   "10",
    "ROR"   :   "11",

    "LD"    :   "00",
    "ST"    :   "01",
    "LDI"   :   "10",
    "STI"   :   "11",

    "LDR"   :   "0",
    "STR"   :   "1",

    "LI"    :   "0",
    "LEA"   :   "1",

    "JAL"   :   "00",
    "JMP"   :   "01",
    "JALR"  :   "10",

    "BGT"   :   "001",
    "BEQ"   :   "010",
    "BGE"   :   "011",
    "BLT"   :   "100",
    "BNE"   :   "101",
    "BLE"   :   "110",
    "BR"    :   "111",

    "NOP"   :   "00",
    "HALT"  :   "11"
}

INSTRUCTION_FORMATS = {
    # ADD, SUB, MUL, AND, OR, XOR
    "RRR_FORMAT" : {
        "operand_count" : 3,
        "operand_types" : ["REG", "REG", "REG"]
    },

    # ADDI, SUBI, MULI, LDR, STR
    "RRSI5_FORMAT" : {
        "operand_count" : 3,
        "operand_types" : ["REG", "REG", "SIMM5"]
    },

    # ANDI, ORI, XORI
    "RRUI5_FORMAT" : {
        "operand_count" : 3,
        "operand_types" : ["REG", "REG", "UIMM5"]
    },

    # NOT, CMP
    "RR_FORMAT" : {
        "operand_count" : 2,
        "operand_types" : ["REG", "REG"]
    },

    # SHIFT
    "RRUI4_FORMAT" : {
        "operand_count" : 3,
        "operand_types" : ["REG", "REG", "UIMM4"]
    },

    # LD, ST, LDI, STI, LEA, 
    "RLABEL_FORMAT" : {
        "operand_count" : 2,
        "operand_types" : ["REG", "LABEL"]
    },

    # JMP, JALR
    "RI7_FORMAT" : {
        "operand_count" : 2,
        "operand_types" : ["REG", "IMM7"]
    },

    # LI, CMPI
    "RI8_FORMAT" : {
        "operand_count" : 2,
        "operand_types" : ["REG", "IMM8"]
    },

    # JAL, BR
    "LABEL_FORMAT" : {
        "operand_count" : 1,
        "operand_types" : ["LABEL"]
    },

    # NOP, HALT
    "NONE_FORMAT" : {
        "operand_count" : 0,
        "operand_types" : ["NO OPERAND"]
    }
}

INSTRUCTION_TO_FORMAT = {
    "ADD"   :   ["RRR_FORMAT", "RRSI5_FORMAT"],
    "ADDI"  :   ["RRSI5_FORMAT"],
    "SUB"   :   ["RRR_FORMAT", "RRSI5_FORMAT"],
    "SUBI"  :   ["RRSI5_FORMAT"],
    "MUL"   :   ["RRR_FORMAT", "RRSI5_FORMAT"],
    "MULI"  :   ["RRSI5_FORMAT"],

    "AND"   :   ["RRR_FORMAT", "RRUI5_FORMAT"],
    "ANDI"  :   ["RRUI5_FORMAT"],
    "OR"    :   ["RRR_FORMAT", "RRUI5_FORMAT"],
    "ORI"   :   ["RRUI5_FORMAT"],
    "XOR"   :   ["RRR_FORMAT", "RRUI5_FORMAT"],
    "XORI"  :   ["RRUI5_FORMAT"],

    "NOT"   :   ["RR_FORMAT"],

    "SHL"   :   ["RRUI4_FORMAT"],
    "SHR"   :   ["RRUI4_FORMAT"],
    "SHA"   :   ["RRUI4_FORMAT"],
    "ROR"   :   ["RRUI4_FORMAT"],

    "LD"    :   ["RLABEL_FORMAT"],
    "ST"    :   ["RLABEL_FORMAT"],
    "LDI"   :   ["RLABEL_FORMAT"],
    "STI"   :   ["RLABEL_FORMAT"],

    "LDR"   :   ["RRSI5_FORMAT"],
    "STR"   :   ["RRSI5_FORMAT"],

    "LI"    :   ["RI8_FORMAT"],
    "LEA"   :   ["RLABEL_FORMAT"],

    "JAL"   :   ["LABEL_FORMAT"],
    "JMP"   :   ["RI7_FORMAT"],
    "JALR"  :   ["RI7_FORMAT"],

    "CMP"   :   ["RR_FORMAT", "RI8_FORMAT"],
    "CMPI"  :   ["RI8_FORMAT"],

    "BGT"   :   ["LABEL_FORMAT"],
    "BGE"   :   ["LABEL_FORMAT"],
    "BLT"   :   ["LABEL_FORMAT"],
    "BLE"   :   ["LABEL_FORMAT"],
    "BEQ"   :   ["LABEL_FORMAT"],
    "BNE"   :   ["LABEL_FORMAT"],
    "BR"    :   ["LABEL_FORMAT"],

    "NOP"   :   ["NONE_FORMAT"],
    "HALT"  :   ["NONE_FORMAT"]
}

def is_immediate(token):
    if token.startswith("#"):
        token = token[1:]
        if token.startswith("-"):
            token = token[1:]
        return token.isdigit()

    # For Binary and Hex, Filter out - and 0
    # Result is only left with B or X
    if token.startswith("-"):
        token = token[1:]

    if token.startswith("0"):
        token = token[1:]

    if token.startswith("B"):
        token = token[1:]
        if not token.isdigit():
            return False
        for digit in token:
            if int(digit) > 1:
                return False
        return True

    if token.startswith("X"):
        token = token[1:]
        if len(token) == 0:
            return False
        for char in token:
            if ord(char) < 48 or ord(char) > 70:
                return False
            if ord(char) > 57 and ord(char) < 65:
                return False
        return True

    return False


def parse_value(token):
    if token.startswith("#"):
        token = token[1:]
        return int(token)

    negative = False
    sum = 0
    base = 0

    if token.startswith("-"):
        token = token[1:]
        negative = True

    if token.startswith("0"):
        token = token[1:]

    if token.startswith("B"):
        token = token[1:]
        power = len(token) - 1
        for bit in token:
            sum += int(bit) * 2**power
            power -= 1
        if negative:
            sum *= -1
        return sum

    if token.startswith("X"):
        token = token[1:]
        power = len(token) - 1
        bitval = 0
        sum = 0
        for bit in token:
            if (bit == "A"):
                bitval = 10
            elif (bit == "B"):
                bitval = 11
            elif (bit == "C"):
                bitval = 12
            elif (bit == "D"):
                bitval = 13
            elif (bit == "E"):
                bitval = 14
            elif (bit == "F"):
                bitval = 15
            else:
                bitval = int(bit)
            sum += bitval * 16**power
            power -= 1

        if negative:
            sum *= -1
        return sum


def fits_in_bits(value, bits, signed):
    if not signed:
        return value < 2**bits and value >= 0
    else:
        return value >= -(2**(bits-1)) and value < (2**(bits-1))


def encode_immediate(value, bits, signed):
    if not signed or value >= 0:
        return bin(value)[2:].zfill(bits)
    else:
        return bin(2**bits + value)[2:]


def is_label_name(token):
    if token[0] in "_0123456789":
        return False
    if token in REGISTERS:
        return False
    if token in OPCODES:
        return False
    if is_immediate(token):
            return False
    
    for char in token:
        if char not in "ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789":
            return False
    return True


def get_operand_types(operands):
    actual_format = []

    for item in operands:
        if item in REGISTERS:
            actual_format.append("REG")
        elif is_immediate(item):
            actual_format.append("IMM")
        elif is_label_name(item):
            actual_format.append("LABEL")
        else:
            actual_format.append("UNKNOWN")

    return actual_format
        

# Ex: find_format("ADD", "R0, R1, #5") returns "RRSI5_FORMAT"
def find_format(opcode, operands):
    actual_format = get_operand_types(operands)
    possible_formats = INSTRUCTION_TO_FORMAT[opcode]

    for format_name in possible_formats:
        if len(operands) != INSTRUCTION_FORMATS[format_name]["operand_count"]:
            return None
        
        correct_operands = 0
        expected_format = INSTRUCTION_FORMATS[format_name]["operand_types"]

        for i in range(INSTRUCTION_FORMATS[format_name]["operand_count"]):
            if actual_format[i] in expected_format[i]:
                correct_operands += 1
        if correct_operands == INSTRUCTION_FORMATS[format_name]["operand_count"]:
            return format_name

    return None


def encode_instruction(opcode, operands, format_name):
    # ADD, SUB, MUL, AND, OR, XOR
    if format_name == "RRR_FORMAT":
        return (OPCODES[opcode] + REGISTERS[operands[0]]
                + REGISTERS[operands[1]] + "000" + REGISTERS[operands[2]])

    # NOT, CMP
    if format_name == "RR_FORMAT":
        if opcode == "NOT":
            return (OPCODES[opcode] + REGISTERS[operands[0]] + 
                    REGISTERS[operands[1]] + "000000")
        elif opcode == "CMP":
            return (OPCODES[opcode] + REGISTERS[operands[0]] +
                    "000000" + REGISTERS[operands[1]])

    # ADDI, SUBI, MULI, ANDI, ORI, XORI, LDR, STR
    if format_name == "RRSI5_FORMAT" or format_name == "RRUI5_FORMAT":
        op = OPCODES[opcode]
        r1 = REGISTERS[operands[0]]
        r2 = REGISTERS[operands[1]]
        signed = format_name.startswith("RRS")
        imm = encode_immediate((parse_value(operands[2])), 5, signed)

        if opcode == "LDR":
            return (op + r1 + "0" + r2 + imm)
        elif opcode == "STR":
            return (op + r1 + "1" + r2 + imm)
        else:
            return (op + r1 + r2 + "1" + imm)

    # SHL, SHR, SHA, ROR
    if format_name == "RRUI4_FORMAT":
        return (OPCODES[opcode] + REGISTERS[operands[0]] + REGISTERS[operands[1]]
                + SUBCODES[opcode] + encode_immediate((parse_value(operands[2])), 4, False))

    # JMP, JALR
    if format_name == "RI7_FORMAT":
        return (OPCODES[opcode] + SUBCODES[opcode] + REGISTERS[operands[0]]
                + encode_immediate((parse_value(operands[1])), 7, True))

    # LI, CMPI
    if format_name == "RI8_FORMAT":
        if opcode == "LI":
            bit8 = "0"
        else:
            bit8 = "1"

        return (OPCODES[opcode] + REGISTERS[operands[0]] + bit8 + 
                encode_immediate((parse_value(operands[1])), 8, True))

    if format_name == "NONE_FORMAT":
        if opcode == "NOP":
            return "1111000000000000"
        elif opcode == "HALT":
            return "1111110000000000"
    
    return None


def assemble_instruction(line, line_number):
    instruction = line.upper()
    instruction = instruction.replace(",", " ")
    instruction = instruction.split()

    opcode = instruction[0]
    operands = instruction[1:]

    if opcode not in OPCODES:
        print("Error on line " + str(line_number) + ":\n\t" + line + "\n\nUnknown instruction '" + opcode + "'")
        return None
    else:
        format_name = find_format(opcode, operands)
        if format_name == None:
            expected_formats = INSTRUCTION_TO_FORMAT[opcode]
            print("Error on line " + str(line_number) + ":\n\t" + line + "\n\nInvalid operand format for '" + opcode + "'")
            print("Expected:")
            for item in expected_formats:
                print("\t" + str(INSTRUCTION_FORMATS[item]["operand_types"]))
            print("Got:")
            print("\t" + str(get_operand_types(operands)))
            return None
        else:
            operand_types = INSTRUCTION_FORMATS[format_name]["operand_types"]
            if "IMM" in operand_types[-1]:
                imm_format = operand_types[-1]
                imm_value = parse_value(operands[-1])
                bits = int(imm_format[-1])
                signed = imm_format.startswith("S") or imm_format.startswith("I")
                if not fits_in_bits(imm_value, bits, signed):
                    if (signed):
                        print("Error on line " + str(line_number) + ":\n\t" + line + "\n\nImmediate out of signed " + str(bits) + " bit range")
                        print("\tAllowed Range: -" + str(2**(bits-1)) + " to +" + str(2**(bits-1)-1))
                    else:
                        print("Error on line " + str(line_number) + ":\n\t" + line + "\n\nImmediate out of unsigned " + str(bits) + " bit range")
                        print("\tAllowed Range: 0 to +" + str(2**bits - 1))
                    return None
                else:
                    return encode_instruction(opcode, operands, format_name)
            else:
                return encode_instruction(opcode, operands, format_name) # So far, but check LABEL PCOffset within range later


program = ["LI R0, x42",
           "                 ",
           "ADD R2, R2, #10",
           "ADD R3, R2, R2",
           "SUB R4, R2, #3",
           "SUB R5, R3, R4",
           "ADD R2, R2",
           "MUL R7, R5, #6",
           "HALT"]

machine_code = []

for line_number, line in enumerate(program, start=1):
    if line.strip() == "":
        continue
    bin_instruction = assemble_instruction(line, line_number)
    if bin_instruction != None:
        hex_instruction = hex(int(bin_instruction, 2))[2:].zfill(4)
        machine_code.append("16'h" + hex_instruction)
    else:
        break

print("\n" + str(machine_code))
