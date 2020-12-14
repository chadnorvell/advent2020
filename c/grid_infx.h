struct grid_infx {
    int size_x;
    int size_y;
    char **grid_data;
};

char grid_infx_get(struct grid_infx grid, int x, int y);
int grid_infx_count_in_path(struct grid_infx grid, char char_to_count, int dx, int dy);
