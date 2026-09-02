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

ecx_redportt *soemx_redport_create(void)
{
    return (ecx_redportt *)calloc(1, sizeof(ecx_redportt));
}

void soemx_redport_destroy(ecx_redportt *redport)
{
    free(redport);
}

int soemx_init_redundant(ecx_contextt *context, ecx_redportt *redport,
                         const char *ifname, const char *ifname2)
{
    return ecx_init_redundant(context, redport, ifname, (char *)ifname2);
}

int soemx_slave_count(ecx_contextt *context) { return context ? context->slavecount : 0; }
unsigned short soemx_expected_wkc(ecx_contextt *context) { return context ? context->grouplist[0].outputsWKC * 2 + context->grouplist[0].inputsWKC : 0; }
unsigned short soemx_group_expected_wkc(ecx_contextt *context, unsigned char group) { return context && group < EC_MAXGROUP ? context->grouplist[group].outputsWKC * 2 + context->grouplist[group].inputsWKC : 0; }
unsigned short soemx_master_state(ecx_contextt *context) { return context ? context->slavelist[0].state : 0; }
void soemx_set_master_state(ecx_contextt *context, unsigned short state) { if (context) context->slavelist[0].state = state; }
const char *soemx_slave_name(ecx_contextt *context, int slave) { return context->slavelist[slave].name; }
unsigned int soemx_slave_manufacturer(ecx_contextt *context, int slave) { return context->slavelist[slave].eep_man; }
unsigned int soemx_slave_id(ecx_contextt *context, int slave) { return context->slavelist[slave].eep_id; }
unsigned int soemx_slave_revision(ecx_contextt *context, int slave) { return context->slavelist[slave].eep_rev; }
unsigned int soemx_slave_serial(ecx_contextt *context, int slave) { return context->slavelist[slave].eep_ser; }
unsigned short soemx_slave_config_address(ecx_contextt *context, int slave) { return context->slavelist[slave].configadr; }
unsigned short soemx_slave_alias_address(ecx_contextt *context, int slave) { return context->slavelist[slave].aliasadr; }
unsigned short soemx_slave_mbx_out_address(ecx_contextt *context, int slave) { return context->slavelist[slave].mbx_wo; }
unsigned short soemx_slave_mbx_out_size(ecx_contextt *context, int slave) { return context->slavelist[slave].mbx_l; }
unsigned short soemx_slave_mbx_in_address(ecx_contextt *context, int slave) { return context->slavelist[slave].mbx_ro; }
unsigned short soemx_slave_mbx_in_size(ecx_contextt *context, int slave) { return context->slavelist[slave].mbx_rl; }
int soemx_slave_amend_mbx(ecx_contextt *context, int slave, int mailbox,
                          unsigned short address, unsigned short size) {
    if (mailbox == 0) {
        context->slavelist[slave].mbx_wo = address;
        context->slavelist[slave].mbx_l = size;
    } else if (mailbox == 1) {
        context->slavelist[slave].mbx_ro = address;
        context->slavelist[slave].mbx_rl = size;
    } else {
        return 0;
    }
    return 1;
}
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

int soemx_amend_mailbox(ecx_contextt *context, unsigned short slave, int mailbox,
                        unsigned short start_address, unsigned short size)
{
    if (!context || slave == 0 || slave >= EC_MAXSLAVE || size == 0 ||
        (mailbox != 0 && mailbox != 1))
        return 0;
    if (mailbox == 0) {
        context->slavelist[slave].mbx_wo = start_address;
        context->slavelist[slave].mbx_l = size;
    } else {
        context->slavelist[slave].mbx_ro = start_address;
        context->slavelist[slave].mbx_rl = size;
    }
    return 1;
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

int soemx_eoe_set_ip(ecx_contextt *context, unsigned short slave, unsigned char port,
                     const unsigned char *ip, const unsigned char *subnet,
                     const unsigned char *gateway, int timeout)
{
    eoe_param_t param;
    if (!context || !ip || !subnet || !gateway) return -1;
    memset(&param, 0, sizeof(param));
    param.ip_set = 1;
    param.subnet_set = 1;
    param.default_gateway_set = 1;
    memcpy(&param.ip.addr, ip, 4);
    memcpy(&param.subnet.addr, subnet, 4);
    memcpy(&param.default_gateway.addr, gateway, 4);
    return ecx_EOEsetIp(context, slave, port, &param, timeout);
}

int soemx_eoe_get_ip(ecx_contextt *context, unsigned short slave, unsigned char port,
                     unsigned char *ip, unsigned char *subnet,
                     unsigned char *gateway, int timeout)
{
    eoe_param_t param;
    if (!context || !ip || !subnet || !gateway) return -1;
    memset(&param, 0, sizeof(param));
    if (ecx_EOEgetIp(context, slave, port, &param, timeout) <= 0) return -1;
    memcpy(ip, &param.ip.addr, 4);
    memcpy(subnet, &param.subnet.addr, 4);
    memcpy(gateway, &param.default_gateway.addr, 4);
    return 1;
}

int soemx_read_register(ecx_contextt *context, unsigned short slave,
                        unsigned short address, void *buffer, int size, int timeout)
{
    if (!context || !buffer || size <= 0 || size > 0xffff || slave == 0) return -1;
    return ecx_FPRD(&context->port, context->slavelist[slave].configadr,
                    address, (uint16)size, buffer, timeout);
}

int soemx_write_register(ecx_contextt *context, unsigned short slave,
                         unsigned short address, const void *buffer, int size, int timeout)
{
    if (!context || !buffer || size <= 0 || size > 0xffff || slave == 0) return -1;
    return ecx_FPWR(&context->port, context->slavelist[slave].configadr,
                    address, (uint16)size, (void *)buffer, timeout);
}

unsigned long long soemx_read_eeprom_ap(ecx_contextt *context, unsigned short address,
                                        unsigned short word, int timeout)
{
    if (!context || timeout <= 0) return 0;
    return (unsigned long long)ecx_readeepromAP(context, address, word, timeout);
}

int soemx_write_eeprom_ap(ecx_contextt *context, unsigned short address,
                          unsigned short word, unsigned short data, int timeout)
{
    if (!context || timeout <= 0) return 0;
    return ecx_writeeepromAP(context, address, word, data, timeout);
}

unsigned long long soemx_read_eeprom_fp(ecx_contextt *context, unsigned short config_address,
                                        unsigned short word, int timeout)
{
    if (!context || timeout <= 0) return 0;
    return (unsigned long long)ecx_readeepromFP(context, config_address, word, timeout);
}

int soemx_write_eeprom_fp(ecx_contextt *context, unsigned short config_address,
                          unsigned short word, unsigned short data, int timeout)
{
    if (!context || timeout <= 0) return 0;
    return ecx_writeeepromFP(context, config_address, word, data, timeout);
}

int soemx_pop_error(ecx_contextt *context, unsigned short *slave,
                    unsigned short *index, unsigned char *subindex,
                    int *type, int *abort_code, unsigned char *error_reg,
                    unsigned char *b1, unsigned short *w1, unsigned short *w2)
{
    ec_errort error;
    if (!context || !slave || !index || !subindex || !type || !abort_code ||
        !error_reg || !b1 || !w1 || !w2) return 0;
    if (!ecx_poperror(context, &error)) return 0;
    *slave = error.Slave;
    *index = error.Index;
    *subindex = error.SubIdx;
    *type = (int)error.Etype;
    *abort_code = (int)error.AbortCode;
    *error_reg = error.ErrorReg;
    *b1 = error.b1;
    *w1 = error.w1;
    *w2 = error.w2;
    return 1;
}
