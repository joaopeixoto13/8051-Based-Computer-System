#include <stdint.h>

#include "accelerator.h"
#include "contrast_filter.h"
#include "rgb_to_grayscale.h"

void accelerator(uint8_t sfr, uint16_t vecIn[IMG_ARR_SIZE], uint16_t vecOut[IMG_ARR_SIZE])
{
    switch ((sfr >> 1) & 7) // xxxx_XXXx bits de selecao do filtro: 3-1
    {
        case 0:
            applyGrayscale(vecIn, vecOut);
            break;

        case 1:
            applyRedContrast(RED_CONST, vecIn, vecOut);
            break;

        case 2:
        	applyGreenContrast(GREEN_CONST, vecIn, vecOut);
            break;

        case 3:
        	applyBlueContrast(BLUE_CONST, vecIn, vecOut);
            break;

        case 4:
        	applyAllContrast(RED_CONST, GREEN_CONST, BLUE_CONST, vecIn, vecOut);
            break;

        default:
            break;
    }
}
