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
#endif /* INC_API_UTILS_H_ */
