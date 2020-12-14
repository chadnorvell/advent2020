#include <stdio.h>
#include <stdlib.h>

#include "grid_infx.h"

char grid_infx_get(struct grid_infx grid, int x, int y) {
    if((y >= grid.size_y) || (x < 0) || (y < 0)) {
        printf("out of bounds!\n");
        exit(1);
    }

    return *((char *)grid.grid_data + (y * grid.size_x) + (x % grid.size_x));
}

int grid_infx_count_in_path(struct grid_infx grid, char char_to_count, int dx, int dy) {
    int pos_x = 0;
    int pos_y = 0;
    int count = 0;

    while(pos_y < grid.size_y) {
        if(grid_infx_get(grid, pos_x, pos_y) == char_to_count) {
            count++;
        }

        pos_x += dx;
        pos_y += dy;
    }

    return count;
}
