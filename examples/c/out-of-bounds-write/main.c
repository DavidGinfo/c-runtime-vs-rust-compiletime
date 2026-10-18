#include <stdio.h>

void write_arr_at_index(int *arr, int index) {
    arr[index] = 99; 
}

int main() {
    int var = 5;
    int array[2] = {2, 2};

    write_arr_at_index(array, 2); 

    printf("%d", var);
}
