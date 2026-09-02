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

int soemx_slave_count(ecx_contextt *context) { return context ? context->slavecount : 0; }
const char *soemx_slave_name(ecx_contextt *context, int slave) { return context->slavelist[slave].name; }
unsigned int soemx_slave_manufacturer(ecx_contextt *context, int slave) { return context->slavelist[slave].eep_man; }
unsigned int soemx_slave_id(ecx_contextt *context, int slave) { return context->slavelist[slave].eep_id; }
unsigned short soemx_slave_state(ecx_contextt *context, int slave) { return context->slavelist[slave].state; }
unsigned int soemx_slave_obits(ecx_contextt *context, int slave) { return context->slavelist[slave].Obits; }
unsigned int soemx_slave_ibits(ecx_contextt *context, int slave) { return context->slavelist[slave].Ibits; }
long long soemx_dc_time(ecx_contextt *context) { return context ? (long long)context->DCtime : 0; }
