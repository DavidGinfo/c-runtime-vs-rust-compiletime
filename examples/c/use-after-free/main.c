#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv) {
    int *buffer_ptr1 = malloc(sizeof(int));
    *buffer_ptr1 = 21;

    int *buffer_ptr2 =  buffer_ptr1;

    free(buffer_ptr1);

    int *buffer_ptr3 = malloc(sizeof(int));
    *buffer_ptr3 = 42;

    printf("%d", *buffer_ptr2);
}
