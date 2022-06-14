/*
 * api_utils.h
 *
 *  Created on: May 24, 2022
 *      Author: nhasbun
 */

#ifndef INC_API_UTILS_H_
#define INC_API_UTILS_H_

#include <stdint.h>

/**
 * Manually fill array with zeros.
 */
void zeros (uint32_t * vector, uint32_t longitud);

/**
 * Scalar multiplication of array (32 bits numbers)
 */
void productoEscalar32(uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar);

/**
 * Scalar multiplication of array (16 bits numbers)
 */
void productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);

/**
 * Scalar multiplication of array (16 bits numbers, saturated at 12 bits)
 */
void productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);

/**
 * 10 elements moving windows average filter
 */
void filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);

/**
 * Change bit depth of incoming signal vector from 32 to 16bits
 */
void pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);

/**
 * Find max number in array
 */
int32_t max (int32_t * vectorIn, uint32_t longitud);

/**
 * Downsampling signal. Discarding 1 of N samples.
 */
void downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N);


#endif /* INC_API_UTILS_H_ */
