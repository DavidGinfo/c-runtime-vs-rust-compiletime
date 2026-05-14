#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define BUFFER_SIZE 512

int main(int argc, char **argv) {
    char *bufferPtr1 = (char *) malloc(BUFFER_SIZE);
    
    free(bufferPtr1);

    char *bufferPtr2 = (char *) malloc(BUFFER_SIZE);

    strncpy(bufferPtr2, "blubb", BUFFER_SIZE);

    printf("%s", bufferPtr1);
}
