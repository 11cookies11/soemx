#include "soemx_native.h"
#include <stdlib.h>
#include <string.h>

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
unsigned short soemx_slave_al_status(ecx_contextt *context, int slave) { return context->slavelist[slave].ALstatuscode; }
int soemx_slave_has_dc(ecx_contextt *context, int slave) { return context->slavelist[slave].hasdc ? 1 : 0; }
int soemx_slave_is_lost(ecx_contextt *context, int slave) { return context->slavelist[slave].islost ? 1 : 0; }
unsigned int soemx_slave_obits(ecx_contextt *context, int slave) { return context->slavelist[slave].Obits; }
unsigned int soemx_slave_ibits(ecx_contextt *context, int slave) { return context->slavelist[slave].Ibits; }
unsigned char *soemx_slave_outputs(ecx_contextt *context, int slave) { return context->slavelist[slave].outputs; }
unsigned char *soemx_slave_inputs(ecx_contextt *context, int slave) { return context->slavelist[slave].inputs; }
long long soemx_dc_time(ecx_contextt *context) { return context ? (long long)context->DCtime : 0; }

int soemx_mailbox_receive(ecx_contextt *context, unsigned short slave,
                          int timeout, void *buffer, int capacity)
{
    ec_mbxbuft *mailbox = NULL;
    int result;
    if (!context || !buffer || capacity <= 0) return -1;
    result = ecx_mbxreceive(context, slave, &mailbox, timeout);
    if (result <= 0 || !mailbox) return result;
    if (result > capacity) result = capacity;
    memcpy(buffer, mailbox, (size_t)result);
    ecx_dropmbx(context, mailbox);
    return result;
}

int soemx_mailbox_send(ecx_contextt *context, unsigned short slave,
                       const void *buffer, int size, int timeout)
{
    ec_mbxbuft mailbox;
    if (!context || !buffer || size <= 0 || size > EC_MAXMBX) return -1;
    memset(mailbox, 0, sizeof(mailbox));
    memcpy(mailbox, buffer, (size_t)size);
    return ecx_mbxsend(context, slave, &mailbox, timeout);
}

int soemx_read_od_entry(ecx_contextt *context, unsigned short slave, int entry,
                        unsigned short *index, unsigned short *datatype,
                        unsigned char *object_code, unsigned char *max_sub,
                        char *name, int name_capacity)
{
    ec_ODlistt od;
    int count;
    if (!context || !index || !datatype || !object_code || !max_sub || !name) return -1;
    memset(&od, 0, sizeof(od));
    count = ecx_readODlist(context, slave, &od);
    if (count <= 0) return count;
    if (entry < 0) return count;
    if (entry >= count || entry >= EC_MAXODLIST) return -1;
    *index = od.Index[entry];
    *datatype = od.DataType[entry];
    *object_code = od.ObjectCode[entry];
    *max_sub = od.MaxSub[entry];
    strncpy_s(name, (size_t)name_capacity, od.Name[entry], _TRUNCATE);
    return count;
}

int soemx_read_oe_entry(ecx_contextt *context, unsigned short slave, int object,
                        int entry, unsigned char *value_info,
                        unsigned short *datatype, unsigned short *bit_length,
                        unsigned short *access, char *name, int name_capacity)
{
    ec_ODlistt od;
    ec_OElistt oe;
    int result;
    if (!context || !value_info || !datatype || !bit_length || !access || !name) return -1;
    memset(&od, 0, sizeof(od));
    memset(&oe, 0, sizeof(oe));
    if (ecx_readODlist(context, slave, &od) <= 0 || object < 0 || object >= od.Entries) return -1;
    result = ecx_readOEsingle(context, (uint16)object, (uint8)entry, &od, &oe);
    if (result <= 0 || entry < 0 || entry >= oe.Entries) return result;
    *value_info = oe.ValueInfo[entry];
    *datatype = oe.DataType[entry];
    *bit_length = oe.BitLength[entry];
    *access = oe.ObjAccess[entry];
    strncpy_s(name, (size_t)name_capacity, oe.Name[entry], _TRUNCATE);
    return oe.Entries;
}

void soemx_set_overlapped(ecx_contextt *context, int enabled)
{
    if (context) context->overlappedMode = enabled ? TRUE : FALSE;
}

void soemx_set_packed(ecx_contextt *context, int enabled)
{
    if (context) context->packedMode = enabled ? TRUE : FALSE;
}

void soemx_set_manual_state_change(ecx_contextt *context, int enabled)
{
    if (context) context->manualstatechange = enabled ? 1 : 0;
}

int soemx_get_manual_state_change(ecx_contextt *context)
{
    return context ? context->manualstatechange : 0;
}

int soemx_pop_error(ecx_contextt *context, unsigned short *slave,
                    unsigned short *index, unsigned char *subindex,
                    int *type, int *abort_code)
{
    ec_errort error;
    if (!context || !slave || !index || !subindex || !type || !abort_code) return 0;
    if (!ecx_poperror(context, &error)) return 0;
    *slave = error.Slave;
    *index = error.Index;
    *subindex = error.SubIdx;
    *type = (int)error.Etype;
    *abort_code = (int)error.AbortCode;
    return 1;
}
