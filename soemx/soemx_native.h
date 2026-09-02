#pragma once

#include "osal.h"
#include "soem/soem.h"

ecx_contextt *soemx_context_create(void);
void soemx_context_destroy(ecx_contextt *context);
int soemx_slave_count(ecx_contextt *context);
const char *soemx_slave_name(ecx_contextt *context, int slave);
unsigned int soemx_slave_manufacturer(ecx_contextt *context, int slave);
unsigned int soemx_slave_id(ecx_contextt *context, int slave);
unsigned short soemx_slave_state(ecx_contextt *context, int slave);
unsigned int soemx_slave_obits(ecx_contextt *context, int slave);
unsigned int soemx_slave_ibits(ecx_contextt *context, int slave);
