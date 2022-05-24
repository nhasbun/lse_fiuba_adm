# Preguntas Orientadoras

1. **Describa brevemente los diferentes perfiles de familias de
   microprocesadores/microcontroladores de ARM. Explique alguna de sus diferencias
   características**

ARM entrega soluciones en base a 3 perfiles de uso principales. El primero es el perfil A, que busca entregar procesadores para uso en sistemas operativos de propósito general con alta capacidad de procesamiento. Esto comprende máquinas Linux, Teléfonos Android, Linux Embebido y otros usos.

El segundo es el perfil R, que si bien siguen manteniendo un requerimiento de alta/media capacidad de procesamiento tienen un claro foco en aplicaciones en tiempo real. Son utilizados en la industria de la medicina, automotriz, aeronáutica, etc.

El tercer perfil M está orientado al uso en dispositivos embebidos. Buscan entregar una solución de bajo costo y bajo consumo para equipos electrónicos que deban manejar rutinas relativamente sencillas y repetitivas.

## Cortex M

1. **Describa brevemente las diferencias entre las familias de procesadores Cortex M0, M3 y M4**

Cortex M0 presenta una solución mínima de bajo costo para aplicaciones sencillas
y que presenta un bajo consumo. Presentan una arquitectura de comunicación interna 
de tipo Von Neumann y en general carecen de funcionalidades avanzadas como pueden
ser protecciones a memoria, co-procesadores, etc.

Cortex M3 presentan mayor performance y capacidades extra de protección a 
memoria. Presentan además un set de instrucciones más extenso que permiten 
operaciones más avanzadas y eficientes como es la división por hardware. Con 
arquitectura interna de tipo Harvard la comunicación interna es más rápida.

Cortex M4 es muy parecido a M3 presenta un set de instrucciones aún más amplio
y co-procesadores más poderosos (co-procesador para procesamiento digital de 
señales DSP y un co-procesador operaciones de punto flotante FPU).

2. **¿Por qué se dice que el set de instrucciones Thumb permite mayor densidad de código?**

El set de instrucciones Thumb introdujo intrucciones de 16 bits a las instrucciones "tradicionales" ARM de 32 bits.
Estas instrucciones se integran bajo una instrucción especial que indica al procesador el cambio al **modo Thumb** o
al **modo ARM** según fuera requerido.

Esto permite que los programas generados en binario se almacenen ocupando sólo 2 bytes en modo Thumb versus los 4 bytes
necesarios para programas escritos en modo ARM haciendo un uso efectivo de la mitad de tamaño de programa requerido. De
este modo el código binario generado queda con una mayor densidad produciendo los mismos resultados y ocupando menor
espacio en memoria de programa.

En la actualidad los procesadores Cortex funcionan bajo el modo Thumb-2 en donde conviven instrucciones de 16 bits y 
32 bits sin necesidad de agregar una instrucción especial para cambio de modo.

3. **¿Qué entiende por arquitectura load-store? ¿Qué tipo de instrucciones no posee este tipo de arquitectura?**

La arquitectura **load-store** hace referencia a la forma en la que trabajan las instrucciones de un procesador. 
En este tipo de arquitecturas existen instrucciones específicas para extraer o cargar elementos desde la memoria RAM y
todo el resto de operaciones se hacen entre registros.

Las instrucciones que no poseen este tipo de arquitecturas son instrucciones que realizan operaciones entre un registro
y un elemento en memoria. La arquitectura más conocida que ocupa este modelo es la arquitectura x86.

4. **¿Cómo es el mapa de memoria de la familia?**

El mapa de memoria de los Cortex M presenta secciones bien definidas para el programa, RAM, periféricos y resto del sistema dentro de todo el espacio de 4GB de memoria que les otorga las direcciones de 32bits.

Estas direcciones quedan con un *offset* amigable que permite encontrarlas rápidamente. Por ejemplo, la memoria de programa inicia en la dirección **0x0000_0000** e inmediatamente luego de esta sección inicia la memoria RAM en la dirección **0x2000_0000** (esto corresponde a un direccionamiento disponible de 500MB para la memoria de programa).

7. **¿Qué se entiende por modelo de registros ortogonal? Dé un ejemplo**

Es un modelo donde todos los registros (o la mayoría) pueden ser utilizados de forma indistinta por las instrucciones. 
Las instrucciones no operan sobre registros específicos si no que existe un grupo de registros de propósito general en 
el cuál todas las instrucciones pueden operar.

Un ejemplo de esto se ve en los Cortex M3/M4 donde tenemos 13 registros (r0 - r12) de propósito general en donde pueden operar
las instrucciones de AND, ADD, MOV, etc. sobre cualquier registro. Ejemplo: ADD r1, r2, r12 MOV r1, r0 AND r11, r10, r9. 

18. **¿Qué funciones cumple la unidad de protección de memoria (MPU)?**

Permite definir y controlar el acceso a regiones de memoria asignadas a distintos programas. De este modo un programa no puede afectar el funcionamiento del resto del sistema, ya sea a propósito o por resultado de un *bug*.

17. **¿Qué es el systick? ¿Por qué puede afirmarse que su implementación favorece la portabilidad de los sistemas operativos embebidos?**

Es una interrupción constante generada por un timer en el procesador usualmente cada 1ms. Esto permite llevar medida del tiempo transcurrido pero también permite asociar tareas a esta interrupción de **systick**.

Con esto se construyen sistemas operativos embebidos que permiten gestionar cambios entre una y otra tarea en ejecución. Cada vez que ocurre esta interrupción se chequea si la tarea en ejecución debe continuar o se debe cambiar e iniciar otra tarea.

Esta unidad de **tick** es la base de los sistemas operativos embebidos. De este modo mientras la arquitectura del procesador soporte estas interrupciones, el sistema operativo embebido debería poder ser portado.

