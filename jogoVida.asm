.data
	endereco: .word 0x2000
	branco: .word 0x20B2AA
	amarelo: .word 0x006400
	x: .word 3 #coordenada x-1
	y: .word 7 #coordenada y-1
	xmul: .word 4 # multiplicador para a linha
	ymul: .word 64 # multiplicador para a coluna
	.align 2
	matrizA: .space 0x400
	.align 2
	matrizB: .space 0x400
	newline: .asciz "\n"
.text
	

matA:	
	addi a0, zero, 1
	addi a1, zero, 0
	la t1, matrizA
	addi t5, zero, 256
	
loopA:
	beq a1, t5, matB
	addi a0, zero, 0
	sw a0, 0(t1)
	li a7, 1
	ecall
	la a0, newline
	li a7, 4
	ecall
	addi a1, a1, 1
	addi t1, t1, 4
	j loopA
matB:
	addi a0, zero, 1
	addi a1, zero, 0
	la t2, matrizB
	addi t5, zero, 256
	
loopB:
	beq a1, t5, init
	addi a0, zero, 1
	sw a0, 0(t2)
	li a7, 1
	ecall
	la a0, newline
	li a7, 4
	ecall
	addi a1, a1, 1
	addi t2, t2, 4
	j loopB
	
init:
	lw s0, endereco # carrega o endereco inicial
	lw s1, branco 
	lw s2, amarelo
	li s3, 0x2400 # carrega o endereco final (16x16x4=1024, hexadecimal = 400)
	lw s4, x
	lw s5, xmul
	mul s4, s4, s5
	lw s5, y
	lw s6, ymul
	mul s5, s5, s6
	add s4, s4, s5 #endereco da coordenada
	
tela:	#preenche a tela de branco
	beq s0, s3, pixel
	sw s1, 0(s0)
	addi s0, s0, 4
	j tela
	
pixel: #adiciona um pixel a coordenada
	addi s0, s0, -1024
	add s0, s0, s4
	sw s2, 0(s0)
	sw s2, 64(s0)
	sw s2, 68(s0)
	
sleep:
	li a0, 1000
	li a7, 32
	ecall
	
fim:	
	#la t2, matrizB
	#lw a0, 1020(t2)
	#li a7, 1
	#ecall
	
