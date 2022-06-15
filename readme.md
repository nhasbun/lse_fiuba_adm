# Trabajos Arquitectura de Microprocesadores

_Nicolás Hasbún A._

Colección de trabajos prácticos realizados en el contexto de la Carrera de Especialización de Sistemas Embebidos de la Universidad de Buenos Aires.

* [Respuestas Cuestionario **Preguntas Orientadoras**](./respuestas_cuestionario.md)

## Notas Personales

* Para ARM v7 en assembler de debe retornar el contexto al devolver una función.
    * Esto significa preservar los registros que no se utilizan para pasar argumentos.
    * Se pasan argumentos con los registros r0, r1, r2, r3
    * Cualquier modificación en alguna función a otro registro de propósito general
      debe ser restaurada

* Contador de ciclos para performance de funciones `DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos;`
  * Reset counter with `DWT->CYCCNT = 0;`
  * Reading values with `volatile uint32_t cicles = DWT->CYCCNT;`

## Referencias:

- [Push and Pop in arm](https://stackoverflow.com/a/27095517/4855501)
- [Condition Codes 1: Condition Flags and Codes](https://is.gd/EPd61A)

