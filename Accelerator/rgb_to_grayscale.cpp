#include "rgb_to_grayscale.h"

/**
 * 2 bytes pixel:
 * |------------2nd byte----------|-------------1st byte----------|
 *  X | X | X | X | X | X | X | X | X | X | X | X | X | X | X | X |
 * |_____RED VALUE____|______GREEN VALUE______|_____BLUE VALUE____|
 *
*/
 
void applyGrayscale(data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE])
{
	#pragma HLS inline off

 	for (int i = 0; i < IMG_ARR_SIZE; i++)
	{
		#pragma HLS unroll factor=2
 		uint8_t gray = ((vecIn[i]>>11 & 31) + (vecIn[i]>>5 & 63) + (vecIn[i] & 31)) / 3;
 		uint8_t red_blue = (gray > 31) ? 31 : gray;
 		uint8_t green = (gray > 31) ? 63 : gray * 2;
 		vecOut[i] = (red_blue << 11) | (green << 5) | red_blue;
	}
}
