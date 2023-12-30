import subprocess
import os
import re

# List of special test cases
directories = ['NaN', 'Inf','Zero','OverFlow','UnderFlow']

output_dir = 'output/SpecialOutput'
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Path to the Part1.asm file
asm_file_path = r'./Part1.asm'
# Run the Part1.asm file with all special test cases
# delete all file in output_dir
files = os.listdir(output_dir)
for file in files:
    os.remove(os.path.join(output_dir,file))
for directory in directories:
    #Read the asm file
    with open(asm_file_path, 'r', encoding='utf-8') as file:
        filedata = file.read()
    with open(os.path.join(output_dir,f'{directory}.txt'), 'a', encoding='utf-8') as f:
        files = os.listdir(f'input/{directory}')

        # Print the list of files
        for file in files:
            print(file)
            # Replace the filename line
            # run all file in directory
            filedata = re.sub(r'filename: .asciiz ".*"', f'filename: .asciiz "input/{directory}/{file}"', filedata)

            # Write the asm file
            with open(asm_file_path, 'w', encoding='utf-8') as file:
                file.write(filedata)
        
            # Run the asm file
            command = f'java -jar Mars4_5.jar {asm_file_path}'
            process = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            
            f.write(process.stdout.decode())
            f.write('-----------------------------------------------\n')
            if process.stderr:
                f.write(f'Error of {directory}:\n')
                f.write(process.stderr.decode())
    