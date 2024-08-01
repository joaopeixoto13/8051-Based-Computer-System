#ifndef __CONSTRAST_FILTER__
#define __CONSTRAST_FILTER__

#include <stdint.h>

#include "accelerator.h"

void applyRedContrast(uint8_t redConst, data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE]);
void applyGreenContrast(uint8_t greenConst, data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE]);
void applyBlueContrast(uint8_t blueConst, data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE]);
void applyAllContrast(uint8_t redConst, uint8_t greenConst, uint8_t blueConst, data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE]);

#endif  // !__CONSTRAST_FILTER__
