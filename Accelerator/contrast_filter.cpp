#include <stdint.h>

#include "contrast_filter.h"
#include "accelerator.h"

#define UNROLL_FACTOR 2

static void findRedLimits(uint8_t *min, uint8_t *max, data_t vecIn[IMG_ARR_SIZE])
{
	#pragma HLS INLINE OFF
	*min = 0x1F;
	*max = 0;

	for (uint16_t i = 0; i < IMG_ARR_SIZE; i++) {
	#pragma HLS UNROLL FACTOR=UNROLL_FACTOR

		uint16_t pixel = vecIn[i];
		uint8_t red = (pixel >> 11) & 0x001F;

		if (red < *min) {
			*min = red;
		}

		if (red > *max) {
			*max = red;
		}
	}
}

static void findGreenLimits(uint8_t *min, uint8_t *max, data_t vecIn[IMG_ARR_SIZE])
{
	#pragma HLS INLINE OFF
	*min = 0x3F;
	*max = 0;

	for (uint16_t i = 0; i < IMG_ARR_SIZE; i++) {
	#pragma HLS UNROLL FACTOR=UNROLL_FACTOR

		uint16_t pixel = vecIn[i];
		uint8_t green = (pixel >> 5) & 0x003F;

		if (green < *min) {
			*min = green;
		}

		if (green > *max) {
			*max = green;
		}
	}
}

static void findBlueLimits(uint8_t *min, uint8_t *max, data_t vecIn[IMG_ARR_SIZE])
{
	#pragma HLS INLINE OFF
	*min = 0x1F;
	*max = 0;

	for (uint16_t i = 0; i < IMG_ARR_SIZE; i++) {
	#pragma HLS UNROLL FACTOR=UNROLL_FACTOR

		uint16_t pixel = vecIn[i];
		uint8_t blue = pixel & 0x001F;

		if (blue < *min) {
			*min = blue;
		}

		if (blue > *max) {
			*max = blue;
		}
	}
}

static void findAllLimits(uint8_t min[3], uint8_t max[3], data_t vecIn[IMG_ARR_SIZE])
{
	#pragma HLS INLINE OFF
	min[0] = 0x1F;
	min[1] = 0x3F;
	min[2] = 0x1F;

	max[0] = 0;
	max[1] = 0;
	max[2] = 0;

	for (uint16_t i = 0; i < IMG_ARR_SIZE; i++) {
	#pragma HLS UNROLL FACTOR=UNROLL_FACTOR

		uint16_t pixel = vecIn[i];

		uint8_t red = (pixel >> 11) & 0x001F;
		uint8_t green = (pixel >> 5) & 0x003F;
		uint8_t blue = pixel & 0x001F;

		if (red < min[0]) {
			min[0] = red;
		}

		if (red > max[0]) {
			max[0] = red;
		}

		if (green < min[1]) {
			min[1] = green;
		}

		if (green > max[1]) {
			max[1] = green;
		}

		if (blue < min[2]) {
			min[2] = blue;
		}

		if (blue > max[2]) {
			max[2] = blue;
		}
	}
}

void applyRedContrast(uint8_t redConst, data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE])
{
	#pragma HLS INLINE OFF
	uint8_t min, max;
	findRedLimits(&min, &max, vecIn);

	for (uint16_t i = 0; i < IMG_ARR_SIZE; i++) {
	#pragma HLS UNROLL FACTOR=UNROLL_FACTOR

		uint16_t pixel = vecIn[i];

		uint16_t red = (pixel >> 11) & 0x001F;
		red = redConst * (red - min) / (max - min);

		if (red > 0x001F) {
			red = 0x001F;
		}

		// rrrrr00000000000 | 0000 0ppp pppp pppp
		pixel = (red << 11) | (pixel & 0x07FF);

		vecOut[i] = pixel;
	}

}

void applyGreenContrast(uint8_t greenConst, data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE])
{
	#pragma HLS INLINE OFF
	uint8_t min, max;
	findGreenLimits(&min, &max, vecIn);

	for (uint16_t i = 0; i < IMG_ARR_SIZE; i++) {
	#pragma HLS UNROLL FACTOR=UNROLL_FACTOR

		uint16_t pixel = vecIn[i];

		uint16_t green = (pixel >> 5) & 0x003F;
		green = greenConst * (green - min) / (max - min);

		if (green > 0x003F) {
			green = 0x003F;
		}

		// 00000gggggg00000 | pppp p000 000p pppp
		pixel = (green << 5) | (pixel & 0xF81F);

		vecOut[i] = pixel;
	}
}

void applyBlueContrast(uint8_t blueConst, data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE])
{
	#pragma HLS INLINE OFF
	uint8_t min, max;
	findBlueLimits(&min, &max, vecIn);

	for (uint16_t i = 0; i < IMG_ARR_SIZE; i++) {
	#pragma HLS UNROLL FACTOR=UNROLL_FACTOR

		uint16_t pixel = vecIn[i];

		uint16_t blue = pixel & 0x001F;
		blue = blueConst * (blue - min) / (max - min);

		if (blue > 0x001F) {
			blue = 0x001F;
		}

		// 00000000000bbbbb | pppp pppp ppp0 0000
		pixel = blue | (pixel & 0xFFE0);

		vecOut[i] = pixel;
	}
}

void applyAllContrast(uint8_t redConst, uint8_t greenConst, uint8_t blueConst, data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE])
{
	#pragma HLS INLINE OFF
	uint8_t min[3], max[3];
	findAllLimits(min, max, vecIn);

	for (uint16_t i = 0; i < IMG_ARR_SIZE; i++) {
	#pragma HLS UNROLL FACTOR=UNROLL_FACTOR

		uint16_t pixel = vecIn[i];

		uint16_t red = (pixel >> 11) & 0x001F;
		red = redConst * (red - min[0]) / (max[0] - min[0]);

		if (red > 0x001F) {
			red = 0x001F;
		}

		uint16_t green = (pixel >> 5) & 0x003F;
		green = greenConst * (green - min[1]) / (max[1] - min[1]);

		if (green > 0x003F) {
			green = 0x003F;
		}

		uint16_t blue = pixel & 0x001F;
		blue = blueConst * (blue - min[2]) / (max[2] - min[2]);

		if (blue > 0x001F) {
			blue = 0x001F;
		}

		// rrrrr00000000000 | 00000gggggg00000 | 00000000000bbbbb
		pixel = (red << 11) | (green << 5) | blue;

		vecOut[i] = pixel;
	}
}
