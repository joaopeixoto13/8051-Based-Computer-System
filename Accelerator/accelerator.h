#include <stdint.h>

#define IMG_WIDTH		80
#define IMG_HEIGHT		60
#define IMG_ARR_SIZE    (IMG_WIDTH * IMG_HEIGHT)

#define RED_CONST		60
#define GREEN_CONST		100
#define BLUE_CONST		60

// One pixel
typedef uint16_t data_t;

// Top function
void accelerator(uint8_t sfr, data_t vecIn[IMG_ARR_SIZE], data_t vecOut[IMG_ARR_SIZE]);
