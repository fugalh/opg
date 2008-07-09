#include "opts.h"
#include <stdio.h>

int main(int argc, char **argv)
{
    struct options opts = {};
    parse_options(&argc, argv, &opts);
    printf("f %d\nb %s\nz %d\nq %f\n", opts.f, opts.b, opts.z, opts.q);
}
