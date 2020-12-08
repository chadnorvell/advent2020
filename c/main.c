#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define EQUAL(X, Y) ((X) == (Y) ? "OK" : "FAIL")

#define FILE_BUFFER_LINES 2500
#define FILE_BUFFER_LINE_LENGTH 256

void parse_file(char *filename, char buffer[FILE_BUFFER_LINES][FILE_BUFFER_LINE_LENGTH]) {
    char line[FILE_BUFFER_LINE_LENGTH];
    int idx = 0;
    FILE *fileptr = NULL;
    fileptr = fopen(filename, "r");

    if(!fileptr) {
        printf("failed to open file! %s", filename);
        exit(1);
    }

    while(fgets(line, sizeof(line), fileptr)) {
        // replace final newline with string terminator
        line[strlen(line) - 1] = '\0';
        strncpy(buffer[idx], line, sizeof(line));
        idx++;
    }

    return;
}

long day1_1_naive(long *nums, int n, long sum) {
    int result = -1;

    for(int i=0; i < n; ++i) {
        for(int j=0; j < n; ++j) {
            // works because there are no duplicates in the input data
            if((i != j) && (nums[i] + nums[j] == sum)) {
                result = nums[i] * nums[j];
                i = j = n;
                break;
            }
        }
    }

    return result;
}

long day1_1_fast(long *nums, int n, long sum, long skip) {
    // The O(n) solution using a poor man's set: an array where the value of
    // set[m] indicates whether the number is present in the input array, with
    // O(1) access.

    // this works for the provided input data
    bool set[INT16_MAX];

    // initialize to false
    for(int i=0; i < INT16_MAX; i++) {
        set[i] = false;
    }

    // set to true the values of the indicies that are present in the input
    for(int i=0; i < n; i++) {
        set[nums[i]] = true;
    }

    // do the actual thing
    for(int i=0; i < n; i++) {
        long complement = sum - nums[i];

        if ((nums[i] != skip) && (complement > 0) && (set[complement])) {
            return nums[i] * complement;
        }
    }

    return -1;
}

void run_day1_1() {
    char buffer[FILE_BUFFER_LINES][FILE_BUFFER_LINE_LENGTH];
    long nums[200];

    parse_file("../data/day1_1.txt", buffer);

    for(int i; i < 200; ++i) {
        nums[i] = strtol(buffer[i], NULL, 10);
    }

    long expected = 471019;
    long result_naive = day1_1_naive(nums, 200, 2020);

    printf("Day 1 Part 1 (naive) => expected: %ld // result: %ld :: %s\n", expected, result_naive, EQUAL(expected, result_naive));

    long result_fast = day1_1_fast(nums, 200, 2020, -1);

    printf("Day 1 Part 1 (fast) => expected: %ld // result: %ld :: %s\n", expected, result_fast, EQUAL(expected, result_fast));
}

long day1_2_naive(long *nums, int n, long sum) {
    int result = -1;

    for(int i=0; i < n; ++i) {
        for(int j=0; j < n; ++j) {
            for(int k=0; k < n; ++k) {
                // works because there are no duplicates in the input data
                if((i != j) && (j != k) && (k != i) && (nums[i] + nums[j] + nums[k] == sum)) {
                    result = nums[i] * nums[j] * nums[k];
                    i = j = k = n;
                    break;
                }
            }
        }
    }

    return result;
}

long day1_2_fast(long *nums, int n, long sum) {
    int result = -1;

    for(int i=0; i < n; ++i) {
        long complement = sum - nums[i];
        long inner_result = day1_1_fast(nums, n, complement, nums[i]);

        if(inner_result > 0) {
            result = inner_result * nums[i];
            break;
        }
    }

    return result;
}

void run_day1_2() {
    char buffer[FILE_BUFFER_LINES][FILE_BUFFER_LINE_LENGTH];
    long nums[200];

    parse_file("../data/day1_1.txt", buffer);

    for(int i; i < 200; ++i) {
        nums[i] = strtol(buffer[i], NULL, 10);
    }

    long expected = 103927824;
    long result_naive = day1_2_naive(nums, 200, 2020);

    printf("Day 1 Part 2 (naive) => expected: %ld // result: %ld :: %s\n", expected, result_naive, EQUAL(expected, result_naive));

    long result_fast = day1_2_fast(nums, 200, 2020);

    printf("Day 1 Part 2 (fast) => expected: %ld // result: %ld :: %s\n", expected, result_fast, EQUAL(expected, result_fast));
}

int main(void) {
    run_day1_1();
    run_day1_2();
}
