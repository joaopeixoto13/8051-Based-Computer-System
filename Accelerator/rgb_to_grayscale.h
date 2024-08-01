#ifndef _RGB_TO_GRAY_H_
#define _RGB_TO_GRAY_H_

#include <stdint.h>

#include "accelerator.h"

/** @brief Function to convert a RGB image to grayscale
 *  @param pixel is the 2 bytes with the RGB values: 5 bits Red + 6 bits Green + 5 bits Blue
 *  @return float corresponding the grayscale pixel value
*/
void applyGrayscale(data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE]);

#endif /*_RGB_TO_GRAY*/
