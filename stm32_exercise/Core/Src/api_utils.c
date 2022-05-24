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


