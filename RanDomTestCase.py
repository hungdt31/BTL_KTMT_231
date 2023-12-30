import random
import os
import struct
# dùng để random testcase
# Số lượng file test case bạn muốn tạo
num_files = 40
# random commands with two bit 0 and 1
def generate_command():
    shift = random.randint(7, 31)
    number = random.randint(-1<<shift, 1<<shift)  # Generate a random number up to 2^31
    return struct.pack('!f',number)  # Convert the number to a 32-bit binary format
# Thư mục để lưu các file test case
output_dir = 'input/testcaseRanDom'
# Tạo thư mục nếu chưa tồn tại
if not os.path.exists(output_dir):
    os.makedirs(output_dir)
# Tạo các file test case
for i in range(num_files):
    with open(os.path.join(output_dir, f'testcase_{i}.bin'), 'wb') as f:  # Mở tệp ở chế độ ghi nhị phân 'wb'
        for j in range(2):
            binary_number = generate_command()
            f.write(binary_number)  # Write the binary number to the file
print("#######################################################")
