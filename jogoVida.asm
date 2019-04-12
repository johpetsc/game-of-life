.data
	endereco: .word 0x1000
	branco: .word 0x20B2AA
	amarelo: .word 0x006400
	x: .word 1 #coordenada x-1
	y: .word 1 #coordenada y-1
	xmul: .word 4 # multiplicador para a linha
	ymul: .word 64 # multiplicador para a coluna
	matrizA: .space 0x400
	matrizB: .space 0x400
	newline: .asciz "\n"
.text
	

matA:	
	addi a1, zero, 0
	la t3, matrizA
	addi t5, zero, 256
	
loopA:
	beq a1, t5, matB
	addi a0, zero, 0
	sw a0, 0(t3)
	li a7, 1
	ecall
	la a0, newline
	li a7, 4
	ecall
	addi a1, a1, 1
	addi t3, t3, 4
	j loopA

matB:
	addi a1, zero, 0
	la t2, matrizB
	addi t5, zero, 256
	
loopB:
	beq a1, t5, init
	addi a0, zero, 0
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
	li s3, 0x1400 # carrega o endereco final (16x16x4=1024, hexadecimal = 400)
	lw s4, x
	lw s5, xmul
	mul s4, s4, s5
	lw s5, y
	lw s6, ymul
	mul s5, s5, s6
	add s4, s4, s5 #endereco da coordenada

	
tela:	#preenche a tela de branco
	beq s0, s3, estado
	sw s1, 0(s0)
	addi s0, s0, 4
	j tela

sleep:
	li a0, 1000
	li a7, 32
	ecall

estado:
	addi s0, s0, -1024
	la t3, matrizA
	add t3, t3, s4
	addi a0, zero, 1
	sw a0, 0(t3)
	sw a0, 64(t3)
	sw a0, 68(t3)
	sub t3, t3, s4
	addi t4, zero, 1
	addi t6, zero, 0
	addi t5, zero, 0
	addi t0, zero, 256
verifica:
	beq t4, t6, pixel
	beq t5, t0, fim
	lw t6, 0(t3)
	addi t3, t3, 4
	addi t5, t5, 1
	j verifica

pixel:	
	addi t5, t5, -1
	lw t6, xmul
	mul t6, t6, t5
	add s0, s0, t6
	sw s2, 0(s0)
	sub s0, s0, t6
	addi t5, t5, 1
	addi t6, zero, 0
	j verifica
fim:	
	#la t2, matrizB
	#lw a0, 460(t2)
	#li a7, 1
	#ecall
	
