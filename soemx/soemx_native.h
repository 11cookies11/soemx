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
long long soemx_dc_time(ecx_contextt *context);
int soemx_mailbox_receive(ecx_contextt *context, unsigned short slave,
                          int timeout, void *buffer, int capacity);
int soemx_mailbox_send(ecx_contextt *context, unsigned short slave,
                       const void *buffer, int size, int timeout);
int soemx_read_od_entry(ecx_contextt *context, unsigned short slave, int entry,
                        unsigned short *index, unsigned short *datatype,
                        unsigned char *object_code, unsigned char *max_sub,
                        char *name, int name_capacity);
int soemx_read_oe_entry(ecx_contextt *context, unsigned short slave, int object,
                        int entry, unsigned char *value_info,
                        unsigned short *datatype, unsigned short *bit_length,
                        unsigned short *access, char *name, int name_capacity);
void soemx_set_overlapped(ecx_contextt *context, int enabled);
void soemx_set_packed(ecx_contextt *context, int enabled);
void soemx_set_manual_state_change(ecx_contextt *context, int enabled);
int soemx_get_manual_state_change(ecx_contextt *context);
int soemx_pop_error(ecx_contextt *context, unsigned short *slave,
                    unsigned short *index, unsigned char *subindex,
                    int *type, int *abort_code);
