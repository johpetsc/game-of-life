.data
	address: .word 0x1000 # initial bitmap address
	background: .word 0x2B7362 # background color
	yellow: .word 0x6C0C29
	ymul: .word 4 # multiplier for rows
	xmul: .word 64 # multiplier for columns
	matrixA: .space 0x400 # stores space for matrix A
	matrixB: .space 0x400 # stores space for matrix B
	newline: .asciz "\n"
	message: .asciz "\nEnter the initial bacteria coordinate (0 to stop):\n"
	comma: .asciz ", "

.text
	
matA:	# loads the address for matrix A
	addi a1, zero, 0
	la t3, matrixA
	addi t5, zero, 256
	
loopA:	# populates matrix A with 0s
	beq a1, t5, matB
	addi a0, zero, 0
	sw a0, 0(t3)
	addi a1, a1, 1
	addi t3, t3, 4
	j loopA

matB:	# loads the address for matrix B
	addi a1, zero, 0
	la t2, matrixB
	addi t5, zero, 256
	
loopB: # populates matrix B with 0s
	beq a1, t5, init
	addi a0, zero, 0
	sw a0, 0(t2)
	addi a1, a1, 1
	addi t2, t2, 4
	j loopB

init:
	lw s0, address # loads initial address
	lw s1, background 
	lw s2, yellow
	li s3, 0x1400 # loads final address (16x16x4=1024, hexadecimal = 400)

input:
	la a0, message
	li a7, 4
	ecall
	li a7, 5
	ecall
	beq a0, zero, stateA
	mv s4, a0
	addi s4, s4, -1
	lw t3, xmul
	mul s4, s4, t3
	li a7, 5
	ecall
	beq a0, zero, stateA
	mv t3, a0
	addi t3, t3, -1
	lw s6, ymul
	mul t3, t3, s6
	add s4, s4, t3 # address for the coordinate
	

state:	# creates initial state for the matrix
	la t3, matrixA
	add t3, t3, s4
	addi a0, zero, 1
	sw a0, 0(t3)
	sub t3, t3, s4
	j input

stateA:
	li a0, 1000
	li a7, 32
	ecall
	addi s5, zero, 0
	j screen

stateB:
	li a0, 1000
	li a7, 32
	ecall
	addi s5, zero, 1

screen:	# fills background screen
	beq s0, s3, sleep
	sw s1, 0(s0)
	addi s0, s0, 4
	j screen

sleep:	# prepares next state
	beq s5, zero, A
	la t3, matrixB
	j B
A:
	la t3, matrixA
B:
	addi s0, s0, -1024 # returns to the initial address of the bitmap
	addi t4, zero, 1
	addi t6, zero, 0
	addi t5, zero, 0
	addi t0, zero, 4
	addi s10, zero, 1
	addi s9, zero, 1 
	addi s8, zero, 16
		
scan: # goes through the entire matrix
	beq t4, t6, pixel # bacteria pixel
	beq t5, a1, end # end of matrix
	bgt s9, s8, sum # calculates the x, y matrix position

endsum:
	lw t6, 0(t3)
	j check

cont:
	addi t3, t3, 4
	addi t5, t5, 1
	addi s9, s9, 1
	j scan

sum:	#s10 = posicao x / s9 = posicao y
	addi s10, s10, 1
	addi s9, zero, 1
	j endsum

check: # check the next state of the pixel
	beq s5, zero, B1
	la t2, matrixA
	j A1
B1:
	la t2, matrixB
A1:
	mul s7, t5, t0
	add t2, t2, s7
	sw t6, 0(t2)
	addi s11, zero, 0
	bgt s10, t4, check1 # if on the first row, does not check upper row
	bgt s9, t4, check4 # if on the first column, does not check left column
	j check6 # if on first column and row, make the jump
	
check1: # x-1
	lw a0, -64(t3)
	add s11, s11, a0
	beq s9, t4, check3

check2: # x-1, y-1
	lw a0, -68(t3)
	add s11, s11, a0
	beq s9, s8, check4

check3: # x-1, y+1
	lw a0, -60(t3)
	add s11, s11, a0
	beq s9, t4, check6
	
check4: # y-1
	lw a0, -4(t3)
	add s11, s11, a0
	beq s10, s8, check8

check5: # x+1, y-1
	lw a0, 60(t3)
	add s11, s11, a0

check6: # x+1
	lw a0, 64(t3)
	add s11, s11, a0
	beq s9, s8, tests
	
check7: # x+1, y+1
	lw a0, 68(t3)
	add s11, s11, a0
	
check8: # y+1
	lw a0, 4(t3)
	add s11, s11, a0
	j tests

tests:	# tests what happens to the pixel
	addi a2, zero, 0
	beq s11, a1, death # 0 neighbors, state 0
	addi a2, a2, 1
	beq s11, a2, death # 1 neighbors, state 0
	addi a2, a2, 1
	beq s11, a2, cont # 2 neighbors, state does not change(0 or 1)
	addi a2, a2, 1
	beq s11, a2, life # 3 neighbors, state 1
	bgt s11, a2, death # 3+ neighbors, state 0
	
death:	# state 0
	addi a2, zero, 0
	sw a2, 0(t2)
	j cont

life:	# state 1
	addi a2, zero, 1
	sw a2, 0(t2)
	j cont
	
pixel:	# fills pixel
	addi t5, t5, -1
	lw t6, ymul
	mul t6, t6, t5
	add s0, s0, t6
	sw s2, 0(s0)
	sub s0, s0, t6
	addi t5, t5, 1
	addi t6, zero, 0
	j scan
end:	
	beq s5, zero, stateB
	j stateA
	
