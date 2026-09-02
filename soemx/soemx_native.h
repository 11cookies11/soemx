#pragma once

#include "osal.h"
#include "soem/soem.h"

ecx_contextt *soemx_context_create(void);
void soemx_context_destroy(ecx_contextt *context);
