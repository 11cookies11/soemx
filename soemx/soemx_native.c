#include "soemx_native.h"
#include <stdlib.h>

ecx_contextt *soemx_context_create(void)
{
    return (ecx_contextt *)calloc(1, sizeof(ecx_contextt));
}

void soemx_context_destroy(ecx_contextt *context)
{
    free(context);
}
