#include "../ISS/include/ISS.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void print_usage(const char *progName) {
    fprintf(stderr, "Usage: %s [left|right|index <n>]\n", progName);
}

int main(int argc, char **argv) {
    if (!iss_init()) {
        fprintf(stderr, "Failed to initialize ISS (event tap). Check accessibility and input monitoring permissions.\n");
        return 1;
    }

    unsigned int targetIndex = 0;
    ISSSpaceInfo info;
    bool success = false;

    if (argc > 1) {
        if (!strcmp(argv[1], "right") || !strcmp(argv[1], "r") || !strcmp(argv[1], "1")) {
            if (iss_get_space_info(&info) && info.spaceCount > 0) {
                if (info.currentIndex + 1 >= info.spaceCount) {
                    success = iss_switch_to_index(info, 0);
                } else {
                    success = iss_switch(ISSDirectionRight);
                }
            }
        } else if (!strcmp(argv[1], "left") || !strcmp(argv[1], "l") || !strcmp(argv[1], "0")) {
            if (iss_get_space_info(&info) && info.spaceCount > 0) {
                if (info.currentIndex == 0) {
                    success = iss_switch_to_index(info, info.spaceCount - 1);
                } else {
                    success = iss_switch(ISSDirectionLeft);
                }
            }
        } else if (!strcmp(argv[1], "index") || !strcmp(argv[1], "i")) {
            if (argc < 3) {
                print_usage(argv[0]);
                iss_destroy();
                return 1;
            }
            char *endPtr = NULL;
            long parsed = strtol(argv[2], &endPtr, 10);
            if (endPtr == argv[2] || parsed < 1) {
                fprintf(stderr, "Index must be a positive integer.\n");
                iss_destroy();
                return 1;
            }
            targetIndex = (unsigned int)(parsed - 1); // convert to zero-based
            if (iss_get_space_info(&info)) {
                iss_switch_to_index(info, targetIndex);
            }
        } else {
            print_usage(argv[0]);
            iss_destroy();
            return 1;
        }
    }

    if (!success) {
        fprintf(stderr, "Switch request failed. Check space bounds or permissions.\n");
        iss_destroy();
        return 1;
    }

    iss_destroy();
    return 0;
}
