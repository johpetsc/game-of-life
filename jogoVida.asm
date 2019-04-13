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
	addi t0, zero, 4
	addi s10, zero, 1 #x
	addi s9, zero, 1 #y
	addi s8, zero, 16

sleep:
	li a0, 1000
	li a7, 32
	ecall
		
percorre:
	beq t4, t6, pixel
	beq t5, a1, fim
	beq s9, s8, soma
	lw t6, 0(t3)
	j verifica
cont:
	addi t3, t3, 4
	addi t5, t5, 1
	addi s9, s9, 1
	j percorre

soma:
	addi s10, s10, 1
	addi s9, zero, 1
	j cont
	
verifica:
	la t2, matrizB
	mul s7, t5, t0
	add t2, t2, s7
	sw t6, 0(t2)
	addi s11, zero, 0
	bgt s10, t4, verifica1
	bgt s9, t4, verifica4
	j verifica6
	
verifica1:
	lw a0, -64(t3)
	add s11, s11, a0
	beq s9, t4, verifica3

verifica2:
	lw a0, -68(t3)
	add s11, s11, a0
	beq s9, s8, verifica4

verifica3:
	lw a0, -60(t3)
	add s11, s11, a0
	beq s9, t4, verifica6
	
verifica4:
	lw a0, -4(t3)
	add s11, s11, a0
	beq s10, s8, verifica8

verifica5:
	lw a0, 60(t3)
	add s11, s11, a0

verifica6:
	lw a0, 64(t3)
	add s11, s11, a0
	beq s9, s8, teste
	
verifica7:
	lw a0, 68(t3)
	add s11, s11, a0
	
verifica8:
	lw a0, 4(t3)
	add s11, s11, a0
	j teste

teste:	
	addi a2, zero, 0
	beq s11, a1, morte
	addi a2, a2, 1
	beq s11, a2, morte
	addi a2, a2, 1
	beq s11, a2, cont
	addi a2, a2, 1
	beq s11, a2, vida
	bgt s11, a2, morte
	
morte:	
	addi a2, zero, 0
	sw a2, 0(t2)
	j cont

vida:	
	addi a2, zero, 1
	sw a2, 0(t2)
	j cont
	
pixel:	
	addi t5, t5, -1
	lw t6, xmul
	mul t6, t6, t5
	add s0, s0, t6
	sw s2, 0(s0)
	sub s0, s0, t6
	addi t5, t5, 1
	addi t6, zero, 0
	j percorre
fim:	
	#la t2, matrizB
	#lw a0, 460(t2)
	#li a7, 1
	#ecall
	
