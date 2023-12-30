.data
    	filename: .asciiz "input/testcaseRanDom/testcase_39.bin"
    	buffer: .word 0 # Định danh một buffer để đọc dữ liệu từ file
    	file_descriptor: .word 0 # Lưu trữ file descriptor
    	dividedNumber: .asciiz "The value of the dividend: "
        divideNumber: .asciiz "The value of the divisor: "
        result: .asciiz "The result of the division: "
        breakLine: .asciiz "\n"
    .text
    .globl main
main:
    # Mở file
    la $t2,buffer
    li $v0, 13         # Syscall 13: Open file
    la $a0, filename   # Đưa địa chỉ của filename vào $a0
    li $a1, 0          # Chế độ đọc, sử dụng 0
    li $a2, 2
    syscall            # Thực hiện syscall để mở file
    
    # Lưu file descriptor vào file_descriptor
    move $s0, $v0      # Lưu kết quả trả về vào $s0
    
    # Đọc file
    
    # đọc số chia
    li $v0, 14         # Syscall 14: Read from file
    move $a0, $s0      # Sử dụng file descriptor đã mở
    la $a1, 0($t2)     # Địa chỉ của buffer để lưu dữ liệu đọc được
    li $a2, 4       	# Đọc tối đa 4 bytes
    syscall            # Thực hiện syscall để đọc file
    lw $s1,0($t2)

    # đọc số bị chia
    li $v0, 14         #...
    move $a0, $s0      
    la $a1, 4($t2)     
    li $a2, 4       	
    syscall            
    lw $s2,4($t2)
    
    # in ra số bị chia
    li $v0,4
    la $a0,dividedNumber
    syscall
    move $s3,$s1
    jal convert
    add $s1,$zero,$s3
    li $v0, 35
    move $a0,$s1
    syscall
    # xuong dong
    li $v0,4
    la $a0,breakLine
    syscall
    mtc1 $s1, $f12
    # In giá trị float
    li $v0, 2
    syscall
    
    # xuong dong
    li $v0,4
    la $a0,breakLine
    syscall
    
    # in ra số chia
    li $v0,4
    la $a0,divideNumber
    syscall
    move $s3,$s2
    jal convert
    add $s2,$zero,$s3
    li $v0, 35
    move $a0,$s2
    syscall
    # xuong dong
    li $v0,4
    la $a0,breakLine
    syscall
    mtc1 $s2, $f12
    # In giá trị float
    li $v0, 2
    syscall
    
    # xuong dong
    li $v0,4
    la $a0,breakLine
    syscall
    
    jal checkNAN # kiểm tra các trường hợp đặc biệt
    handle:
    # tính phần dấu
    jal calculate_Sign
    
    # tính phần mũ
    jal calculate_Exponent
    
    # tính phần phân số
    jal calculate_Fraction
    
    endProgram:
    li $v0,4
    la $a0,result
    syscall
    li $v0,35
    move $a0,$s4
    syscall
    # xuong dong
    li $v0,4
    la $a0,breakLine
    syscall
    mtc1 $s4, $f12
    # In giá trị float của kết quả
    li $v0, 2
    syscall
 
    # Đóng file
    li $v0, 16         # Syscall 16: Close file
    move $a0, $s0      # Sử dụng file descriptor đã mở
    syscall            # Thực hiện syscall để đóng file
    
    # Kết thúc chương trình
    li $v0, 10         # Syscall 10: Exit
    syscall            # Thực hiện syscall để kết thúc chương trình
convert: # chuyển IEEE 754 thành số thực
	srl $t5,$s3,24
	sll $t6,$s3,24
	andi $t7,$s3,0x00FF0000
	srl $t7,$t7,8
	andi $t8,$s3,0x0000FF00
	sll $t8,$t8,8
	or $t5,$t5,$t6
	or $t5,$t5,$t7
	or $t5,$t5,$t8
	move $s3,$t5
	jr $ra
checkNAN:
	addi $t4,$zero,0x7FC00000
	seq $t5, $s1, $zero    # $t5 = 1 if $s1 == 0, else $t5 = 0
    	seq $t6, $s2, $zero    # $t6 = 1 if $s2 == 0, else $t6 = 0
    	and $t7, $t5, $t6      # $t7 = 1 nếu cả $s1 and $s2 = 0
	beqz $t7, checkInf     # Nếu $t7 == 0 (not both $s1 and $s2 = 0), go to checkInf
	NAN:
	move $s4,$t4
    	j endProgram
checkInf:
	addi $t7,$zero,0x7F800000
	andi $s5,$s1,0x7FFFFFFF 
	andi $s6,$s2,0x7FFFFFFF 
	seq $s5,$s5,$t7
	seq $s6,$s6,$t7
	and $s7,$s5,$s6
	bnez $s7,NAN # nếu $s7 = 1 (cả hai đều infinity thì go to NaN)
	bnez $s5,setResultInf # nếu số chia là infinity thì xét result = +- infinity
	bnez $s6,setZero # nếu số bị chia là infinity thì result = 0
    	beqz $t6, handle  # If $s2 != 0, go to handle
    	# nếu số bị chia bằng 0 xét result = +- infinity
    	srl $t8,$s1,31
    	beqz $t8,setPosInf
    	j setNegInf
setResultInf:
	xor $s3,$s1,$s2
	srl $s3,$s3,31
    	beqz $s3,setPosInf
    	j setNegInf
setNegInf:
	addi $s4,$zero,0xFF800000
	j endProgram
setPosInf:
	addi $s4,$zero,0x7F800000
	j endProgram
setZero:
	xor $s3,$s1,$s2
	srl $s3,$s3,31
    	beqz $s3,setPosZero
    	j setNegZero
setNegZero:
	addi $s4,$zero,0x80000000
    	j endProgram
setPosZero:
	move $s4,$zero
    	j endProgram
calculate_Sign:
	andi $t5,$s1,0x80000000
        andi $t6,$s2,0x80000000
        xor $t7,$t5,$t6
        move $s4,$t7
        jr $ra
calculate_Exponent:
	andi $t5,$s1,0x7F800000
	andi $t6,$s2,0x7F800000
	srl $t5,$t5,23
	srl $t6,$t6,23
	sub $a1,$t5,$t6
	addi $a1,$a1,127
	jr $ra
shiftSign:
	bge $t5,$t6,out
	sll $t5,$t5,1
	addi $t7,$t7,1
	j shiftSign
overFlow:
	sgt $t0,$a1,255
	beqz $t0,checkUnderFlow
	srl $s4,$s4,31
	bnez $s4,setNegInf
	beqz $s4,setPosInf
	jr $ra
underFlow:
	move $s4,$zero
	j endProgram	
calculate_Fraction:
	# lưu trữ $ra trong stack
    	addi $sp, $sp, -4   # điều chỉnh con trỏ stack
    	sw $ra, ($sp)       # lưu trữ địa chỉ trả về trong stack
	add $t4,$zero,$zero
	add $t7,$zero,$zero
	
	andi $t5,$s1,0x007FFFFF
	andi $t6,$s2,0x007FFFFF
	ori $t5,$t5,0x00800000
	ori $t6,$t6,0x00800000
	
	# thay đổi phần phân số của số bị chia >= số chia
	# phần phân số tăng bao nhiêu thì phần mũ giảm bấy nhiêu
	jal shiftSign
	out:
	sub $a1,$a1,$t7
	
	jal overFlow # xét tràn số trên
	checkUnderFlow:
	blt  $a1,$zero,underFlow # xét tràn số dưới
	
	add $t0,$zero,24 # thực hiện chia hai phần định trị
	add $s5,$zero,$zero
	loop:
	sll $s5,$s5,1
	blt $t5,$t6,continue
	addi $s5,$s5,1
     	sub $t5, $t5, $t6
    	continue:
    	sll $t5,$t5,1
        addi $t0, $t0, -1
        bnez $t0, loop
	exit:
	sll $a1,$a1,23
	or $s4,$s4,$a1
    	andi $s5,$s5,0x007FFFFF
	or $s4,$s4,$s5
	
	# lấy địa chỉ $ra từ stack và trả lại
    	lw $ra, ($sp)       # Restore $ra from the stack
    	addi $sp, $sp, 4    # Restore stack pointer
    	jr $ra              # trả về hàm
	
