opcodes = {
    "ADD" : "00",
    "SUB" : "01",
    "AND" : "10",
    "OR" : "11"
}

registers = {
    "R0" : "00",
    "R1" : "01",
    "R2" : "10",
    "R3" : "11"
}

file = open("program.asm", "r")
program = file.readlines()
file.close()

init_lines = []
instruction_lines = []
machine_code = []

for line in program:
    line = line.strip()
    if (line.startswith("INIT")):
        init_lines.append(line)
    elif (line != ""):
        instruction_lines.append(line)

for instruction in instruction_lines:
    if (instruction == "HALT"):
        binary_instruction = "11111111"
    else:
        instruction = instruction.replace(",", "")
        pieces = instruction.split()
        binary_instruction = opcodes[pieces[0]] + registers[pieces[1]] + registers[pieces[2]] + registers[pieces[3]]
    machine_code.append(binary_instruction)

instruction_file = open("program.svh", "w")

instruction_file.write("case(address)\n")

for i in range(len(machine_code)):
    address = bin(i)[2:].zfill(4)
    instruction_file.write("\t4'b" + address + " : instruction = 8'b" + machine_code[i] + ";\n")

instruction_file.write("\tdefault : instruction = 8'b11111111;\n")
instruction_file.write("endcase\n")

instruction_file.close()

init_file = open("preloadRegisters.svh", "w")


if (len(init_lines) > 0):
    init_file.write("preload_enable = 1;\n")

    for init in init_lines:
        init = init.replace(",", "")
        pieces = init.split()
        preload_address = registers[pieces[1]]
        preload_data = bin(int(pieces[2]))[2:].zfill(4)
        init_file.write("preload_address = 2'b" + preload_address + ";\n")
        init_file.write("preload_data = 4'b" + preload_data + ";\n")
        init_file.write("#10;\n\n")

init_file.write("preload_enable = 0;\n")
init_file.close()
    
