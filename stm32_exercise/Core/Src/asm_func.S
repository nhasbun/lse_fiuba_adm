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
		push {r5-r8}
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

		pop {r5-r8}
		bx lr













