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
		vectorOut = vectorOut + 1;
		vectorIn++;
	}
}

void productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar) {

	for (uint32_t i = 0; i < longitud; i++) {
		*vectorOut = *vectorIn * escalar;
		vectorOut++;
		vectorIn++;
	}
}

void productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar) {

	uint32_t res = 0;  // 16bit x 16bit multiplication delivers max a 32 bit number
	const uint32_t max_number = 0xFFF;  // Max 12 bit number (4095 decimal number)

	for (uint32_t i = 0; i < longitud; i++) {
		res = *vectorIn * escalar;
		if (res > max_number) res = max_number;
		*vectorOut = (uint16_t) res;

		vectorOut++;
		vectorIn++;
	}
}

void filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn) {

	const uint8_t window_size = 10;

	for (uint8_t i = 0; i < longitudVectorIn; i++) {

		uint32_t sum = 0;

		for (uint8_t j = 0; j < window_size; j++) {

			uint8_t adjusted_index;

			// if remaining elements are less than windows size
			// we cycle through vectorIn starting from beginning
			if (j + i < longitudVectorIn) adjusted_index = i + j;
			else adjusted_index = i + j - longitudVectorIn;

			sum += (uint32_t) *(vectorIn + adjusted_index);
		}

		*vectorOut = sum / window_size;
		vectorOut++;
	}
}

void pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud) {

	for (; longitud > 0; longitud--) {
		*vectorOut = (int16_t) (*vectorIn >> 16);
		vectorOut++;
		vectorIn++;
	}

}

int32_t max (int32_t * vectorIn, uint32_t longitud) {

	int32_t max_number = 0x80000000;  // smaller 32bit signed number

	for (; longitud > 0; longitud--) {

		if (*vectorIn > max_number) max_number = *vectorIn;
		vectorIn++;
	}

	return max_number;
}

void downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N) {

	uint16_t element_count = 0;

	for (; longitud > 0; longitud--) {

		element_count++;

		if (element_count < N) {
			*vectorOut = *vectorIn;
			vectorOut++;

		} else {
			element_count = 0;
		}

		vectorIn++;
	}
}

void invertir (uint16_t * vector, uint32_t longitud) {

	uint16_t * last_element = vector + longitud - 1;
	uint32_t iterations = longitud / 2;

	for (; iterations > 0; iterations--) {

		uint16_t temp = *(last_element);
		*(last_element) = *(vector);
		*(vector) = temp;

		vector++;
		last_element--;
	}
}

void corr (int16_t *vectorX, int16_t * vectorY, int32_t * vectorCorr, uint32_t longitud) {

	/**
	 * Following this diagrams was pretty helpful:
	 * - https://www.allaboutcircuits.com/technical-articles/understanding-correlation/
	 */

	for (uint32_t i = 0; i < longitud; i++) {

		int16_t sum = 0;

		for (uint32_t j = 0; j < longitud - i; j++) {

			int16_t first_item = *(vectorX + j);
			int16_t second_item = *(vectorY + j);
			sum += first_item * second_item;
		}

		*(vectorCorr + i) = sum;
		vectorX += 1;
	}
}


