.data
	endereco: .word 0x1000 #endereco inicial bitmap
	fundo: .word 0x2B7362 #cor de fundo
	amarelo: .word 0x6C0C29
	ymul: .word 4 # multiplicador para a linha
	xmul: .word 64 # multiplicador para a coluna
	matrizA: .space 0x400 #armazena espaco para a matriz A
	matrizB: .space 0x400 
	newline: .asciz "\n"
	mensagem: .asciz "\nEntre a coordenada da bacteria(0 para parar):\n"
	virgula: .asciz ", "
.text
	
matA:	#carrega o endereco da matriz A
	addi a1, zero, 0
	la t3, matrizA
	addi t5, zero, 256
	
loopA:	#popula a matriz A com 0
	beq a1, t5, matB
	addi a0, zero, 0
	sw a0, 0(t3)
	addi a1, a1, 1
	addi t3, t3, 4
	j loopA

matB:	#carrega o endereco da matriz B
	addi a1, zero, 0
	la t2, matrizB
	addi t5, zero, 256
	
loopB: #popula a matriz B com 0
	beq a1, t5, init
	addi a0, zero, 0
	sw a0, 0(t2)
	addi a1, a1, 1
	addi t2, t2, 4
	j loopB

init:
	lw s0, endereco # carrega o endereco inicial
	lw s1, fundo 
	lw s2, amarelo
	li s3, 0x1400 # carrega o endereco final (16x16x4=1024, hexadecimal = 400)

entrada:
	la a0, mensagem
	li a7, 4
	ecall
	li a7, 5
	ecall
	beq a0, zero, estadoA
	mv s4, a0
	addi s4, s4, -1
	lw t3, xmul
	mul s4, s4, t3
	li a7, 5
	ecall
	beq a0, zero, estadoA
	mv t3, a0
	addi t3, t3, -1
	lw s6, ymul
	mul t3, t3, s6
	add s4, s4, t3 #endereco da coordenada
	

estado:	#constroi o estado inicial da matriz
	la t3, matrizA
	add t3, t3, s4
	addi a0, zero, 1
	sw a0, 0(t3)
	sub t3, t3, s4
	j entrada

estadoA:
	li a0, 1000
	li a7, 32
	ecall
	addi s5, zero, 0
	j tela

estadoB:
	li a0, 1000
	li a7, 32
	ecall
	addi s5, zero, 1

tela:	#preenche a tela de fundo
	beq s0, s3, sleep
	sw s1, 0(s0)
	addi s0, s0, 4
	j tela

sleep:	# prepara o proximo estado
	beq s5, zero, A
	la t3, matrizB
	j B
A:
	la t3, matrizA
B:
	addi s0, s0, -1024 #volta para o endereco inicial do bitmap
	addi t4, zero, 1
	addi t6, zero, 0
	addi t5, zero, 0
	addi t0, zero, 4
	addi s10, zero, 1 #x
	addi s9, zero, 1 #y
	addi s8, zero, 16
		
percorre: # percorre a matriz
	beq t4, t6, pixel # preenche o pixel da bacteria
	beq t5, a1, fim # termina a matriz
	bgt s9, s8, soma # calcula a posicao x, y da matriz
fimsoma:
	lw t6, 0(t3)
	j verifica
cont:
	addi t3, t3, 4
	addi t5, t5, 1
	addi s9, s9, 1
	j percorre

soma:	#s10 = posicao x / s9 = posicao y
	addi s10, s10, 1
	addi s9, zero, 1
	j fimsoma

verifica: #verifica o proximo estado do pixel
	beq s5, zero, B1
	la t2, matrizA
	j A1
B1:
	la t2, matrizB
A1:
	mul s7, t5, t0
	add t2, t2, s7
	sw t6, 0(t2)
	addi s11, zero, 0
	bgt s10, t4, verifica1 # se estiver na primeira linha, nao testa a linha de cima
	bgt s9, t4, verifica4 # se estiver na primeira coluna, nao testa a coluna da esquerda
	j verifica6 # se estiver na primeira coluna e linha, nao testa cima e esquerda
	
verifica1:# x-1
	lw a0, -64(t3)
	add s11, s11, a0
	beq s9, t4, verifica3

verifica2:# x-1, y-1
	lw a0, -68(t3)
	add s11, s11, a0
	beq s9, s8, verifica4

verifica3:# x-1, y+1
	lw a0, -60(t3)
	add s11, s11, a0
	beq s9, t4, verifica6
	
verifica4:# y-1
	lw a0, -4(t3)
	add s11, s11, a0
	beq s10, s8, verifica8

verifica5:# x+1, y-1
	lw a0, 60(t3)
	add s11, s11, a0

verifica6:# x+1
	lw a0, 64(t3)
	add s11, s11, a0
	beq s9, s8, teste
	
verifica7:# x+1, y+1
	lw a0, 68(t3)
	add s11, s11, a0
	
verifica8:# y+1
	lw a0, 4(t3)
	add s11, s11, a0
	j teste

teste:	# testa o que deve acontecer com o pixel
	addi a2, zero, 0
	beq s11, a1, morte # 0 vizinhos, estado 0
	addi a2, a2, 1
	beq s11, a2, morte # 1 vizinhos, estado 0
	addi a2, a2, 1
	beq s11, a2, cont # 2 vizinhos, estado nao muda(0 ou 1)
	addi a2, a2, 1
	beq s11, a2, vida # 3 vizinhos, estado 1
	bgt s11, a2, morte # 3+ vizinhos, estado 0
	
morte:	#estado 0
	addi a2, zero, 0
	sw a2, 0(t2)
	j cont

vida:	#estado 1
	addi a2, zero, 1
	sw a2, 0(t2)
	j cont
	
pixel:	#preenche o pixel
	addi t5, t5, -1
	lw t6, ymul
	mul t6, t6, t5
	add s0, s0, t6
	sw s2, 0(s0)
	sub s0, s0, t6
	addi t5, t5, 1
	addi t6, zero, 0
	j percorre
fim:	
	beq s5, zero, estadoB
	j estadoA
	
