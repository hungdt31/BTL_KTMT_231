import subprocess
import os
import re
# Số lượng file test case bạn muốn tạo
num_files = 40
output_dir = 'output/outputRanDom'
if not os.path.exists(output_dir):
    os.makedirs(output_dir)
# Path to the Part1.asm file
asm_file_path = r'./Part1.asm'

# Run the Part1.asm file with all test cases
for i in range(num_files):
    # Read the asm file
    with open(asm_file_path, 'r', encoding='utf-8') as file:
        filedata = file.read()

    # Replace the filename line
    filedata = re.sub(r'filename: .asciiz ".*"', f'filename: .asciiz "input/testcaseRanDom/testcase_{i}.bin"', filedata)

    # Write the asm file
    with open(asm_file_path, 'w', encoding='utf-8') as file:
        file.write(filedata)

    # Run the asm file
    command = f'java -jar Mars4_5.jar {asm_file_path}'
    process = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    with open(os.path.join(output_dir,f'output_{i}.txt'), 'w', encoding='utf-8') as f:
        f.write(f'Output of testcase_{i}:\n')
        f.write(process.stdout.decode())
        if process.stderr:
            f.write(f'Error of testcase_{i}:\n')
            f.write(process.stderr.decode())