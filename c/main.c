#include <regex.h>
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "queue_char.h"
#include "grid_infx.h"

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

    fclose(fileptr);
    return;
}

long day1_1_naive(long *nums, int n, long sum) {
    int result = -1;

    for(int i=0; i < n; ++i) {
        for(int j=0; j < n; ++j) {
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

struct password_policy {
    int min;
    int max;
    char character;
    char password[32];
};

struct password_policy load_password_easy(char line[FILE_BUFFER_LINE_LENGTH]) {
    struct password_policy policy;
    sscanf(line, "%d-%d %c: %s", &policy.min, &policy.max, &policy.character, policy.password);
    return policy;
}

struct password_policy load_password_hard(char line[FILE_BUFFER_LINE_LENGTH]) {
    int max_matches = 1;
    int max_groups = 5;
    regex_t regex;
    regmatch_t groups[max_groups];
    int re_status;

    char *regex_str = "([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)";
    struct password_policy policy;

    re_status = regcomp(&regex, regex_str, REG_EXTENDED);

    if(re_status) {
        printf("failed to compile regex\n");
        exit(1);
    }

    re_status = regexec(&regex, line, max_groups, groups, 0);

    if(re_status) {
        printf("regex failed to match\n");
        exit(1);
    }

    regfree(&regex);

    for(int j=0; j < max_groups; j++) {
        if(groups[j].rm_so == (size_t)-1) {
            printf("found fewer regex groups than expected\n");
            exit(1);
        }

        char line_copy[strlen(line) + 1];
        strcpy(line_copy, line);

        // truncate off the end of the line beyond this group
        line_copy[groups[j].rm_eo] = '\0';

        // get a pointer to the part of the line at the beginning of this group
        char *match_ptr = line_copy + groups[j].rm_so;

        switch(j) {
            // case 0 is the entire string
            case 1:
                policy.min = strtol(match_ptr, NULL, 10);
                break;
            case 2:
                policy.max = strtol(match_ptr, NULL, 10);
                break;
            case 3:
                policy.character = *(char *)match_ptr;
                break;
            case 4:
                strncpy(policy.password, match_ptr, 32);
                break;
        }
    }

    // final confirmation that this was parsed and stored correctly
    char reconstructed[FILE_BUFFER_LINE_LENGTH];
    sprintf(reconstructed, "%d-%d %c: %s", policy.min, policy.max, policy.character, policy.password);
    // printf("%s\n");

    for(int i=0; i < strlen(reconstructed); i++) {
        if(line[i] != reconstructed[i]) {
            printf("password parsing failed! %s\n", reconstructed);
            exit(1);
        }
    }

    return policy;
}

long day2_1(struct password_policy *policies, int len) {
    int valid_passwords = 0;
    struct password_policy *current_policy = policies;

    for(int i=0; i < len; i++) {
        int char_count = 0;

        for(int j=0; j < strlen(current_policy->password); j++) {
            if(current_policy->password[j] == current_policy->character) {
                char_count++;
            }
        }

        if((char_count >= current_policy->min) && (char_count <= current_policy->max)) {
            valid_passwords++;
        }

        current_policy++;
    }

    return valid_passwords;
}

void run_day2_1() {
    char buffer[FILE_BUFFER_LINES][FILE_BUFFER_LINE_LENGTH];
    struct password_policy policies[1000];

    parse_file("../data/day2_1.txt", buffer);

    for(int i; i < 1000; ++i) {
        policies[i] = load_password_hard(buffer[i]);
    }

    long expected = 458;
    long result = day2_1(policies, 1000);

    printf("Day 2 Part 1 (hard) => expected: %ld // result: %ld :: %s\n", expected, result, EQUAL(expected, result));

    for(int i; i < 1000; i++) {
        policies[i] = load_password_easy(buffer[i]);
    }

    result = day2_1(policies, 1000);

    printf("Day 2 Part 1 (easy) => expected: %ld // result: %ld :: %s\n", expected, result, EQUAL(expected, result));
}

long day2_2(struct password_policy *policies, int len) {
    int valid_passwords = 0;
    struct password_policy *current_policy = policies;

    for(int i=0; i < len; i++) {
        char a = current_policy->password[current_policy->min - 1];
        char b = current_policy->password[current_policy->max - 1];

        if((a == current_policy->character) != (b == current_policy->character)) {
            valid_passwords++;
        }

        current_policy++;
    }

    return valid_passwords;
}

void run_day2_2() {
    char buffer[FILE_BUFFER_LINES][FILE_BUFFER_LINE_LENGTH];
    struct password_policy policies[1000];

    parse_file("../data/day2_1.txt", buffer);

    for(int i; i < 1000; ++i) {
        policies[i] = load_password_easy(buffer[i]);
    }

    long expected = 342;
    long result = day2_2(policies, 1000);
    printf("Day 2 Part 2 (easy) => expected: %ld // result: %ld :: %s\n", expected, result, EQUAL(expected, result));
}

void run_day3_1() {
    const int size_y = 323;
    const int size_x = 31;
    char grid_data[size_y][size_x];

    char buffer[FILE_BUFFER_LINES][FILE_BUFFER_LINE_LENGTH];
    parse_file("../data/day3_1.txt", buffer);

    for(int y=0; y < size_y; y++) {
        strncpy(grid_data[y], buffer[y], size_x);
    }

    struct grid_infx grid = { size_x, size_y, (char **)grid_data };
    long result = grid_infx_count_in_path(grid, '#', 3, 1);
    long expected = 272;

    printf("Day 3 Part 1 => expected: %ld // result: %ld :: %s\n", expected, result, EQUAL(expected, result));
}

void run_day3_2() {
    const int size_y = 323;
    const int size_x = 31;
    char grid_data[size_y][size_x];

    char buffer[FILE_BUFFER_LINES][FILE_BUFFER_LINE_LENGTH];
    parse_file("../data/day3_1.txt", buffer);

    for(int y=0; y < size_y; y++) {
        strncpy(grid_data[y], buffer[y], size_x);
    }

    struct grid_infx grid = { size_x, size_y, (char **)grid_data };

    long result = grid_infx_count_in_path(grid, '#', 1, 1);
    result *= grid_infx_count_in_path(grid, '#', 3, 1);
    result *= grid_infx_count_in_path(grid, '#', 5, 1);
    result *= grid_infx_count_in_path(grid, '#', 7, 1);
    result *= grid_infx_count_in_path(grid, '#', 1, 2);

    long expected = 3898725600;

    printf("Day 3 Part 2 => expected: %ld // result: %ld :: %s\n", expected, result, EQUAL(expected, result));
}

int hash_passport_field(char *field) {
    int hash = 0;

    for(int i=0; i < strlen(field); i++) {
        hash += (int)field[i];
    }

    return hash;
}

void run_day4_1() {
    char buffer[FILE_BUFFER_LINES][FILE_BUFFER_LINE_LENGTH];
    parse_file("../data/day4_1.txt", buffer);

    int valid = 0;
    // re-use the poor man's set idea
    bool set[INT16_MAX] = { false };
    char items[3];
    struct queue_char queue = queue_char_new(items, 3);
    bool collecting = true;
    int this_hash = 0;
    char this_char;

    const int actual_lines = 1070;

    // the extremely poor man's hash function
    int byr_hash = 'b' + 'y' + 'r';
    int iyr_hash = 'i' + 'y' + 'r';
    int eyr_hash = 'e' + 'y' + 'r';
    int hgt_hash = 'h' + 'g' + 't';
    int hcl_hash = 'h' + 'c' + 'l';
    int ecl_hash = 'e' + 'c' + 'l';
    int pid_hash = 'p' + 'i' + 'd';
    int cid_hash = 'c' + 'i' + 'd';

    for(int i=0; i < actual_lines; i++) {
        // blank line; check to see if all required fields are present and
        // reset the set
        if(buffer[i][0] == '\0') {
           if(
               set[byr_hash] &&
               set[iyr_hash] &&
               set[eyr_hash] &&
               set[hgt_hash] &&
               set[hcl_hash] &&
               set[ecl_hash] &&
               set[pid_hash]
           ) {
               valid++;
           }

           for(int j=0; j < INT16_MAX; j++) {
               set[j] = false;
           }
        } else {
            for(int k=0; k < strlen(buffer[i]); k++) {
                this_char = buffer[i][k];

                switch(this_char) {
                    // flush the queue and set the appropriate hash position
                    // stop enqueuing for now
                    case ':':
                        this_hash += (int)queue_char_dequeue(&queue);
                        this_hash += (int)queue_char_dequeue(&queue);
                        this_hash += (int)queue_char_dequeue(&queue);
                        set[this_hash] = true;
                        collecting = false;
                        this_hash = 0;
                        break;

                    // start of a field; start enqueuing again
                    case ' ':
                        collecting = true;
                        break;

                    // if we're in a field, enqueue those chars; else ignore
                    default:
                        if(collecting) {
                            queue_char_enqueue(&queue, this_char);
                        }
                }
            }

            // a new line will come soon; start enqueuing again
            collecting = true;
        }
    }

    int expected = 213;
    printf("Day 4 Part 1 => expected: %d // result: %d :: %s\n", expected, valid, EQUAL(expected, valid));
}

int main(void) {
    run_day1_1();
    run_day1_2();
    run_day2_1();
    run_day2_2();
    run_day3_1();
    run_day3_2();
    run_day4_1();
}
