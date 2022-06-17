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

8. **¿Qué ventajas presenta el uso de intrucciones de ejecución condicional (IT)? Dé un ejemplo**

Permite mantener el pipeline de trabajo de 3 etapas al mismo tiempo que se tienen ejecuciones condicionales.

Sin las instrucciones IT lo que se tiene son saltos según se cumpla o no cierta condición de tipo _if/else_. Al ejecutar
un salto el pipeline de trabajo del procesador debe vaciarse pues el contexto de los elementos que vienen en camino
(_instruction fetch_ y _instruction decode_) cambia. Volver a llenar el pipeline de trabajo para retomar la performance
esperada toma unos nuevos 3 ciclos de reloj (un ciclo para cada etapa).

Gracias a las intrucciones IT el salto no es necesario. Si la ejecución condicional no se acciona el procesador no hace
nada, pero el pipeline se mantiene pues al no haber saltos el camino de trabajo se mantiene en una sola línea por lo
que el pipeline se preserva. Esto permite además aumentar la densidad de código, dado que no hay que agregar pasos
especiales para ir y volver de saltos.

Ejemplo:

```
Para ejecución condicional,

instruction3 (IF)
instruction2 (ID)
conditional instruction1 (EX) -->

   En este punto, la ejecución condicional no afecta la entrada en el próximo ciclo de **instruction2**.

Para salto condicional,

instrucion3 (IF)
instrucion2 (ID)
conditional jump (EX) -->

   En este punto, el salto condicional afecta el pipeline de trabajo. El salto condicional puede vaciar las etapas
   ya preparadas en el pipeline y se gasta código de programa sólo para manejo de saltos, sin afectar ningún cálculo
   aún en los registros de propósito general.
```

14. **¿Qué es el CMSIS? ¿Qué función cumple? ¿Quién lo provee? ¿Qué ventajas aporta?**

Es una capa de abstracción entregada por ARM a los fabricantes finales de los microcontroladores para su configuración,
acceso a periféricos y acceso a software base como es el caso de los sistemas operativos de tiempo real.

Permite acelerar el tiempo de salida al mercado para los fabricantes a la vez que permite la reusabilidad de código
entre distintas versiones de microcontroladores. Un ejemplo de esto es el paquete de abstracción CMSIS-Core(M) que entrega
una interfaz unificada para programar todos los microcontroladores de la gama Cortex-M (un paquete similar CMSIS-Core(A)
existe para los procesadores de la gama Cortex-A).

17. **¿Qué es el systick? ¿Por qué puede afirmarse que su implementación favorece la portabilidad de los sistemas operativos embebidos?**

Es una interrupción constante generada por un timer en el procesador usualmente cada 1ms. Esto permite llevar medida del tiempo transcurrido pero también permite asociar tareas a esta interrupción de **systick**.

Con esto se construyen sistemas operativos embebidos que permiten gestionar cambios entre una y otra tarea en ejecución. Cada vez que ocurre esta interrupción se chequea si la tarea en ejecución debe continuar o se debe cambiar e iniciar otra tarea.

Esta unidad de **tick** es la base de los sistemas operativos embebidos. De este modo mientras la arquitectura del procesador soporte estas interrupciones, el sistema operativo embebido debería poder ser portado.

18. **¿Qué funciones cumple la unidad de protección de memoria (MPU)?**

Permite definir y controlar el acceso a regiones de memoria asignadas a distintos programas. De este modo un programa no puede afectar el funcionamiento del resto del sistema, ya sea a propósito o por resultado de un *bug*.

## ISA

2. **¿Para qué se utiliza el sufijo ‘s’? Dé un ejemplo**

Se utiliza para actualizar los flags condicionales de acuerdo al resultado de una
instrucción. Estos flags pueden ser: N resultado negativo, Z resultado es cero,
C sucedió un unsigned overflow o V sucedió un signed overflow.

Estos luego se utilizan para realizar operaciones condicionales del tipo igual,
no igual, mayor, menor, etc. Un ejemplo de esto se ve para la operación de resta:

```
subs r1, r2
bne .some_other_place
```

Acá el salto se ignora cuando r1 es igual a r2.

3. **¿Qué utilidad tiene la implementación de instrucciones de aritmética saturada? Dé un ejemplo con operaciones con datos de 8 bits.**

Estas instrucciones permiten establecer máximos y minimos para operaciones aritméticas. Tradicionalmente las operaciones
aritméticas dada la limitación de bits para representar números pueden sufrir errores en su cálculo al traspasar valores
máximos (_overflow_) o mínimos (_underflow_) dando la vuelta por el límite opuesto.

Un ejemplo de esto es un simple suma para un número entero sin signo de 8 bits:
* Tomando un valor máximo de 254 (representado por el número binario 1111_1110)
* Sumando un valor 2:
   * De forma tradicional toma un valor de 0 (o en binario 0000_0000)
   * Con aritmética saturada limitando su valor al máximo representable queda en 255.

4. **Describa brevemente la interfaz entre assembler y C ¿Cómo se reciben los argumentos de las funciones? ¿Cómo se devuelve el resultado? ¿Qué registros deben guardarse en la pila antes de ser modificados?**

La interfaz está definida en los documentos de ARM Prodecure Call Standard (APCS).

En particular las funciones reciben argumentos en los registros **r0** a **r3** y los valores
de retorno de las funciones se hacen en el registro **r0**.

Todos los otros registros desde **r4** a **r12** pertenecen al contexto de la función previa
que llama a la función actual. Esto significa en la práctica que antes de ser utilizados
sus valores deben respaldarse en la pila (haciendo uso de `push {rx}`). Del mismo modo, antes
de terminar la ejecución de la función actual el contexto para la función previa debe retornarse
sacando los elementos almacenados en la pila (haciendo uso de `pop {rx}`).

5. **¿Qué es una instrucción SIMD? ¿En qué se aplican y que ventajas reporta su uso? Dé un ejemplo**

Permite hacer múltiples cálculos a través de una sola instrucción.

Es útil en procesamiento de señales análogas continuas como puede ser el caso de audio, video, u otro tipo de señales discretizadas. Permite en una sola intrucción ejecutar hasta 4 cálculos acelerando de forma importante el procesamiento de datos.

Ejemplo:

La instrucción SMUAD permite hacer la suma del resultado de 2 multplicaciones de
números de 16 bits en una sola instrucción.

```
r1 = [a] [b]
r2 = [c] [d]

smuad r0, r1, r2

r0 = a*c + b*d
```

