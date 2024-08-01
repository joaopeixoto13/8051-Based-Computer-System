#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define BASE_ADDRESS 0x43c00000
#define HIGH_ADDRESS 0x43c0ffff
#define MAP_SIZE 0xffff

/**
 * @brief Convert a string of 32 bits to an integer
 * @param str: string of 32 bits
 * @return: integer
 */
unsigned int str_to_int(char *str)
{
    unsigned int result = 0;
    int i;
    for (i = 0; i < 32; i++) {
        result = result << 1;
        if (str[i] == '1') {
            result = result | 1;
        }
        else if (str[i] != '0') {
            printf("Invalid character %c\n", str[i]);
            exit(-1);
        }
    }
    return result;
}

/**
 * @brief Main function
 * @param argc 
 * @param argv 
 * @return int 
 * @details Usage: ./loader [file]
 *          [file] is a text file containing 32 bits strings
 *          Each string is written to the memory via the AXI bus
 *          Each string contains a 16 bits address and a 16 bits data
 */

int main(int argc, char **argv)
{

    /* Check arguments */
    printf("Start Loading\n");
    if (argc != 2) {
        printf("Usage: %s [file]\n", argv[0]);
        return -1;
    }

    /* Open file */
    FILE *file = fopen(argv[1], "r");
    if (file == NULL) {
        printf("Can't open file %s\n", argv[1]);
        return -1;
    }

    /* Open memory */
    int fd = open("/dev/mem", O_RDWR);
    if (fd < 0) {
        printf("Can't open /dev/mem\n");
        printf("Try with sudo\n");
        return -1;
    }

    /* Map memory */
    void *map_base = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, BASE_ADDRESS);
    if (map_base == NULL) {
        printf("Can't mmap\n");
        return -1;
    }

    /* Write memory */
    printf("Start Writing\n");
    volatile unsigned int *virt_addr = (volatile unsigned int *)map_base;
    char str[35];

    virt_addr[0] = 1; // Write enable

    while (fgets(str, 35, file) != NULL) {
        unsigned int data = str_to_int(str);
        virt_addr[1] = data;
        printf("Write %08x\n", data);
    }
    
    virt_addr[0] = 0; // Write disable
    printf("End Writing\n");
    
    /* Close */
    fclose(file);
    munmap(map_base, MAP_SIZE);
    close(fd);
    return 0;
}