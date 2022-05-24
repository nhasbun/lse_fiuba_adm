/*
 * api_utils.c
 *
 *  Created on: May 24, 2022
 *      Author: nhasbun
 */

#include "api_utils.h"

void zeros (uint32_t * vector, uint32_t longitud) {

	for (uint32_t i = 0; i < longitud; i++) {
		*vector = 0;
		vector++;
	}
}

void productoEscalar32(uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar) {

	for (uint32_t i = 0; i < longitud; i++) {
		*vectorOut = *vectorIn * escalar;
		vectorOut++;
		vectorIn++;
	}
}

void productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar) {
	productoEscalar32((uint32_t*) vectorIn, (uint32_t*) vectorOut, longitud, (uint32_t) escalar);
}
