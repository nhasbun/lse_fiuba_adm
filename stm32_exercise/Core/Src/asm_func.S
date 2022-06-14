.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12
.global asm_filtroVentana10
.global asm_pack32to16
.global asm_max
.global asm_downsampleM
.global asm_invertir
.global asm_corr
.global asm_corr_simd


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_zeros (uint32_t *vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vector
@   r1: longitud
@
.thumb_func
    asm_zeros:
        @ Registros usados
        @   r2: valor cero
        mov r2, 0           @ constante cero
    .asm_zeros_loop:
        str r2, [r0], 4     @ sizeof(uint32_t) == 4, *vector++ = r2
        subs r1, 1          @ --longitud
        bne .asm_zeros_loop
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut uint32_t longitud, uint32_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: longitud
@   r3: escalar
@
.thumb_func
	asm_productoEscalar32:
	push {r4}
	.asm_productoEscalar32_loop:
		ldr r4, [r0], 4  @ load value
		mul r4, r3  @ multiplication ignoring overflows
		str r4, [r1], 4  @ storage
		subs r2, 1  @ decresing loop index
		bne .asm_productoEscalar32_loop  @ jmp if loop index r2 > 0 (checking z flag)

		pop {r4}
		bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: longitud
@   r3: escalar
@
.thumb_func
	asm_productoEscalar16:
	push {r4}
	.asm_productoEscalar16_loop:
		@ Nota personal:
		@ la indicación h de halfword no es necesaria
		@ al tener arquitectura little endian, los valores relevantes
		@ en nuestro caso no se solapan

		@ Ej: Al trabajar con 16bits pero con registros de 32b la memoria
		@ se guarda en este sentido [primeros 8 bits][segundos 8 bits][terceros 8 bits][cuartos 8 bits]
		@ luego, lo que suceda con el tercer y cuarto grupo de 8 bits no nos interesa :)

		ldrh r4, [r0], 2
		mul r4, r3
		strh r4, [r1], 2
		subs r2, 1
		bne .asm_productoEscalar16_loop

		pop {r4}
		bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: longitud
@   r3: escalar
@
.thumb_func
	asm_productoEscalar12:
		push {r4, r5}
		mov r5, 0x0FFF  @ max 4095 value
	.asm_productoEscalar12_loop:
		ldrh r4, [r0], 2
		mul r4, r3
		cmp r5, r4  @ setting status register flags for r5 - r4
		bpl .asm_productoEscalar12_capped  @ if result is positive
		mov r4, r5  @ capping when value is negative (r4 bigger than r5=4095)
	.asm_productoEscalar12_capped:
		strh r4, [r1], 2
		subs r2, 1
		bne .asm_productoEscalar12_loop

		pop {r4, r5}
		bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: longitudVectorIn
@
.thumb_func
	asm_filtroVentana10:
		push {r5-r7}
		mov r3, 10  @ filter windows size stored in r3
		mov r4, 0  @ main array start element index (number go from 0 to longitudVIN - 1)

	.asm_filtroVentana10_element_loop:
		mov r5, 0  @ temp sum storage
		mov r6, 0  @ window element index

		.asm_filtroVentana10_window_loop:
			add r7, r6, r4  @ current element position (start index + window index)
			cmp r2, r7  @ checking if window + start index surpasses original array
			it le
			suble r7, r2  @ if element index is bigger than existing array we use first items again
			lsl r7, 1  @ adjusting offset for uint16 numbers
			ldrh r7, [r0, r7]
			add r5, r7
			add r6, 1
			cmp r3, r6
			bne .asm_filtroVentana10_window_loop

		udiv r5, r3  @ extracting average of sum
		strh r5, [r1], 2  @ storing result and updating pointer for next filter step
		add r4, 1  @ starting element loop with respective window loop in next element
		cmp r4, r2
		bne .asm_filtroVentana10_element_loop

		pop {r5-r7}
		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: longitud
@
.thumb_func
asm_pack32to16:
	.asm_pack32to16_loop:

		cmp r2, 0  @ checking if longitud > 0
		ble .asm_pack32to16_exit

		ldr r3, [r0], 4
		lsr r3, 16
		strh r3, [r1], 2

		sub r2, 1  @ decrementing longitud

		b .asm_pack32to16_loop

	.asm_pack32to16_exit:
		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   int32_t asm_max (int32_t * vectorIn, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: longitud
@
.thumb_func
asm_max:

	mov r2, 0  @ 2 steps loading 32 bit number
	movt r2, 0x8000  @ minimal possible 32 bit 2 complements value

	.asm_max_loop:

		cmp r1, 0  @ checking if longitud > 0
		ble .asm_max_exit

		ldr r3, [r0], 4  @ dereferencing pointer

		cmp r3, r2  @ comparing actual value to previous max value
		it gt  @ if greater then we update max value
		movgt r2, r3

		sub r1, 1
		b .asm_max_loop

	.asm_max_exit:
		mov r0, r2
		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: N (samples are eliminated every N elements)
@
.thumb_func
asm_downsampleM:

	push {r4-r5}
	mov r4, 0  @ stored element counter

	.asm_downsample_loop:

		 cmp r2, 0  @ checking if longitud > 0
		 ble .asm_downsample_exit

		 add r4, 1
		 ldr r5, [r0], 4  @ storing vectorIN values in r5

		 cmp r4, r3
		 ite lt  @ if element counter - N is negative
		 strlt r5, [r1], 4
		 movge r4, 0

		 sub r2, 1  @ decrementing remaining elements
		 b .asm_downsample_loop

	.asm_downsample_exit:
		pop {r4 - r5}
		bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_invertir (uint16_t * vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vector
@   r1: longitud
@
.thumb_func
asm_invertir:

	push {r4 - r6}
	sub r2, r1, 1
	lsl r2, 1
	add r2, r0  @ last element pointer at r2
	lsr r3, r1, 1  @ iterations number at r3

	.asm_invertir_loop:

		cmp r3, 0
		ble .asm_invertir_exit

		ldrh r5, [r0]  @ temp variable for *vector
		ldrh r6, [r2]  @ temp variable for *last_element

		strh r6, [r0], 2  @ storing what vector had on last_element
		strh r5, [r2], -2  @ storing what last element had on vector slot

		sub r3, 1
		b .asm_invertir_loop

	.asm_invertir_exit:

		pop {r4 - r6}
		bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_corr (int16_t *vectorX, int16_t * vectorY, int32_t * vectorCorr, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vectorX
@   r1: *vectorY
@   r2: *vectorCorr
@   r3: longitud
@
.thumb_func
asm_corr:

	 push {r4 - r11}
	 mov r4, 0  @ foreach element counter i
	 @   r5, 0  @ foreach overlapping element counter j
	 @   r6, 0  @ temp sum holder

	 .asm_corr_loop:
	 @ foreach element loop

	 	cmp r4, r3
	 	bge .asm_corr_exit

	 	mov r5, 0
	 	mov r6, 0
	 	sub r7, r3, r4  @ longitud - i (overlapping elements)

	 	.asm_corr_loop_overlapping:

	 		cmp r5, r7
	 		bge .asm_corr_exit_overlapping_loop

	 		lsl r8, r5, 1  @ address offset for memory lookup

	 		ldrsh r9, [r0, r8]  @ vector x + j pointer  ** using signed halfword
	 		ldrsh r10, [r1, r8]  @ vector y + j pointer

	 		mul r11, r9, r10
	 		add r6, r11

	 		add r5, 1  @ increasing j
	 		b .asm_corr_loop_overlapping

 	.asm_corr_exit_overlapping_loop:

 		str r6, [r2], 4
 		add r0, 2  @ increasing vector x pointer
 		add r4, #1  @ increasing i
 		b .asm_corr_loop

	.asm_corr_exit:

		pop {r4 -r11}
		bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_corr_simd (int16_t *vectorX, int16_t * vectorY, int32_t * vectorCorr, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vectorX
@   r1: *vectorY
@   r2: *vectorCorr
@   r3: longitud
@
.thumb_func
asm_corr_simd:

	 push {r4 - r11}
	 mov r4, 0  @ foreach element counter i
	 @   r5, 0  @ foreach overlapping element counter j
	 @   r6, 0  @ temp sum holder

	 .asm_corr_simd_loop:
	 @ foreach element loop

	 	cmp r4, r3
	 	bge .asm_corr_simd_exit

	 	mov r5, 0
	 	mov r6, 0
	 	sub r7, r3, r4  @ longitud - i (overlapping elements)

	 	.asm_corr_simd_loop_overlapping:

	 		cmp r5, r7
	 		bge .asm_corr_simd_exit_overlapping_loop

	 		lsl r8, r5, 1  @ address offset for memory lookup

	 		add r11, r5, 1
	 		cmp r11, r7  @ special case for only 1 overlapping element
	 		beq .asm_corr_regular_branch

	 		.asm_corr_simd_branch:

		 		ldr r9, [r0, r8]  @ vector x + j pointer
		 		ldr r10, [r1, r8]  @ vector y + j pointer

		 		smuad r9, r9, r10  @ simd result storage at r9
		 		b .asm_corr_simd_branch_continue

		 	.asm_corr_regular_branch:

		 		ldrsh r9, [r0, r8]  @ vector x + j pointer  ** using signed halfword
	 			ldrsh r10, [r1, r8]  @ vector y + j pointer

	 			mul r9, r10

	 		.asm_corr_simd_branch_continue:

 			add r6, r9
	 		add r5, 2  @ increasing j by 2 since simd instruction are extracting 2 elements at once
	 		b .asm_corr_simd_loop_overlapping

 	.asm_corr_simd_exit_overlapping_loop:

 		str r6, [r2], 4
 		add r0, 2  @ increasing vector x pointer
 		add r4, 1  @ increasing i by 1
 		b .asm_corr_simd_loop

	.asm_corr_simd_exit:

		pop {r4 -r11}
		bx lr






