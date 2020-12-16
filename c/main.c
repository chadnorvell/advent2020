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

int hash_passport_field(char *field, int size) {
    int hash = 0;

    for(int i=0; i < size; i++) {
        hash += (int)field[i];
    }

    return hash;
}

bool validate_passport_field_data(char *field, char *data, int data_size) {
    // we want to avoid unsafe situations, but we need
    // at least this much in the data buffer
    if(data_size < 7) {
        return false;
    }

    if((strncmp(field, "byr", 3) == 0) && strnlen(data, 4)) {
        long year = strtol(data, NULL, 10);
        return (year >= 1920) && (year <= 2002);
    }

    if((strncmp(field, "iyr", 3) == 0) && strnlen(data, 4)) {
        long year = strtol(data, NULL, 10);
        return (year >= 2010) && (year <= 2020);
    }

    if((strncmp(field, "eyr", 3) == 0) && strnlen(data, 4)) {
        long year = strtol(data, NULL, 10);
        return (year >= 2020) && (year <= 2030);
    }

    if(strncmp(field, "hgt", 3) == 0) {
        char *units;
        long height = strtol(data, &units, 10);

        if(strncmp(units, "in", 2) == 0) {
            return (height >= 59) && (height <= 76);
        } else if (strncmp(units, "cm", 2) == 0) {
            return (height >= 150) && (height <= 193);
        } else {
            return false;
        }
    }

    if(strncmp(field, "hcl", 3) == 0) {
        bool is_valid = true;

        printf("%s  ", data);

        for(int i=0; i < 7; i++) {
            if(data[i] == '\0') {
                break;
            }

            if(i == 0) {
                is_valid = data[i] == '#';

                if(!is_valid) {
                    break;
                }
            } else {
                is_valid =
                    (((int)data[i] >= 48) && ((int)data[i] <= 57))
                    || (((int)data[i] >= 97) && ((int)data[i] <= 102))
                    && is_valid;
            }
        }

        return is_valid;
    }

    if(strncmp(field, "ecl", 3) == 0) {
        return
            (strncmp(data, "amb", 3) == 0) ||
            (strncmp(data, "blu", 3) == 0) ||
            (strncmp(data, "brn", 3) == 0) ||
            (strncmp(data, "gry", 3) == 0) ||
            (strncmp(data, "grn", 3) == 0) ||
            (strncmp(data, "hzl", 3) == 0) ||
            (strncmp(data, "oth", 3) == 0);
    }

    if((strncmp(field, "pid", 3) == 0) && strnlen(data, 9)) {
        long pid = strtol(data, NULL, 10);
        return (pid > 0) && (pid <= 999999999);
    }

    return false;
}

struct day4_results {
    int present;
    int valid;
};

struct day4_results day4() {
    char buffer[FILE_BUFFER_LINES][FILE_BUFFER_LINE_LENGTH];
    parse_file("../data/day4_1.txt", buffer);

    const int actual_lines = 1070;
    const int field_name_size = 3;
    const int data_size = 32;

    int present = 0;
    int valid = 0;

    // re-use the poor man's set idea
    bool present_set[INT16_MAX] = { false };
    bool valid_set[INT16_MAX] = { false };

    char field_items[field_name_size];
    char data_items[data_size];
    char field_name_buffer[field_name_size];
    char data_buffer[data_size];

    struct queue_char field_queue = queue_char_new(field_items, field_name_size);
    struct queue_char data_queue = queue_char_new(data_items, data_size);

    bool collecting_field = true;
    int this_hash = 0;
    char this_char;

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
        // blank line; check to see if all required fields are present and valid,
        // then reset the sets
        if(buffer[i][0] == '\0') {
           if(
               present_set[byr_hash] &&
               present_set[iyr_hash] &&
               present_set[eyr_hash] &&
               present_set[hgt_hash] &&
               present_set[hcl_hash] &&
               present_set[ecl_hash] &&
               present_set[pid_hash]
           ) {
               present++;
           }

           if(
               valid_set[byr_hash] &&
               valid_set[iyr_hash] &&
               valid_set[eyr_hash] &&
               valid_set[hgt_hash] &&
               valid_set[hcl_hash] &&
               valid_set[ecl_hash] &&
               valid_set[pid_hash]
           ) {
               valid++;
           }

           for(int j=0; j < INT16_MAX; j++) {
               present_set[j] = false;
               valid_set[j] = false;
           }
        } else {
            for(int k=0; k < strlen(buffer[i]); k++) {
                this_char = buffer[i][k];

                switch(this_char) {
                    // flush the field name queue and set the appropriate hash position
                    case ':':
                        queue_char_flush(&field_queue, field_name_buffer, field_name_size);
                        this_hash = hash_passport_field(field_name_buffer, field_name_size);
                        present_set[this_hash] = true;
                        collecting_field = false;
                        break;

                    // start of a field; flush the data queue
                    // start enqueuing the field name again
                    case ' ':
                        queue_char_flush(&data_queue, data_buffer, data_size);
                        valid_set[this_hash] = validate_passport_field_data(field_name_buffer, data_buffer, data_size);
                        collecting_field = true;
                        break;

                    // enqueue to appropriate queue
                    default:
                        if(collecting_field) {
                            queue_char_enqueue(&field_queue, this_char);
                        } else {
                            queue_char_enqueue(&data_queue, this_char);
                        }
                }
            }

            // a new line will come soon; flush the data queue
            // start enqueuing the field again
            queue_char_flush(&data_queue, data_buffer, data_size);
            valid_set[this_hash] = validate_passport_field_data(field_name_buffer, data_buffer, data_size);
            collecting_field = true;
        }
    }

    struct day4_results results = { present, valid };
    return results;
}

void run_day4_1() {
    struct day4_results results = day4();
    int expected = 213;
    printf("Day 4 Part 1 => expected: %d // result: %d :: %s\n", expected, results.present, EQUAL(expected, results.present));
}

void run_day4_2() {
    struct day4_results results = day4();
    int expected = 147;
    printf("Day 4 Part 2 => expected: %d // result: %d :: %s\n", expected, results.valid, EQUAL(expected, results.valid));
}

int main(void) {
    run_day1_1();
    run_day1_2();
    run_day2_1();
    run_day2_2();
    run_day3_1();
    run_day3_2();
    run_day4_1();
    run_day4_2();
}
