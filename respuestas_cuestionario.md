# Preguntas Orientadoras

> Describa brevemente los diferentes perfiles de familias de
microprocesadores/microcontroladores de ARM. Explique alguna de sus diferencias
características

ARM entrega soluciones en base a 3 perfiles de uso principales. El primero es el perfil A, que busca entregar procesadores para uso en sistemas operativos de propósito general con alta capacidad de procesamiento. Esto comprende máquinas Linux, Teléfonos Android, Linux Embebido y otros usos.

El segundo es el perfil R, que si bien siguen manteniendo un requerimiento de alta/media capacidad de procesamiento tienen un claro foco en aplicaciones en tiempo real. Son utilizados en la industria de la medicina, automotriz, aeronáutica, etc.

El tercer perfil M está orientado al uso en dispositivos embebidos. Buscan entregar una solución de bajo costo y bajo consumo para equipos electrónicos que deban manejar rutinas relativamente sencillas y repetitivas.

> Describa brevemente las diferencias entre las familias de procesadores Cortex M0, M3 y
M4

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
