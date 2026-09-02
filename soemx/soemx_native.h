#pragma once

#include "osal.h"
#include "soem/soem.h"

ecx_contextt *soemx_context_create(void);
void soemx_context_destroy(ecx_contextt *context);
ecx_redportt *soemx_redport_create(void);
void soemx_redport_destroy(ecx_redportt *redport);
int soemx_init_redundant(ecx_contextt *context, ecx_redportt *redport,
                         const char *ifname, const char *ifname2);
int soemx_slave_count(ecx_contextt *context);
unsigned short soemx_expected_wkc(ecx_contextt *context);
unsigned short soemx_group_expected_wkc(ecx_contextt *context, unsigned char group);
unsigned short soemx_master_state(ecx_contextt *context);
void soemx_set_master_state(ecx_contextt *context, unsigned short state);
const char *soemx_slave_name(ecx_contextt *context, int slave);
unsigned int soemx_slave_manufacturer(ecx_contextt *context, int slave);
unsigned int soemx_slave_id(ecx_contextt *context, int slave);
unsigned int soemx_slave_revision(ecx_contextt *context, int slave);
unsigned int soemx_slave_serial(ecx_contextt *context, int slave);
unsigned short soemx_slave_config_address(ecx_contextt *context, int slave);
unsigned short soemx_slave_alias_address(ecx_contextt *context, int slave);
unsigned short soemx_slave_mbx_out_address(ecx_contextt *context, int slave);
unsigned short soemx_slave_mbx_out_size(ecx_contextt *context, int slave);
unsigned short soemx_slave_mbx_in_address(ecx_contextt *context, int slave);
unsigned short soemx_slave_mbx_in_size(ecx_contextt *context, int slave);
unsigned short soemx_slave_state(ecx_contextt *context, int slave);
unsigned short soemx_slave_al_status(ecx_contextt *context, int slave);
int soemx_slave_has_dc(ecx_contextt *context, int slave);
int soemx_slave_is_lost(ecx_contextt *context, int slave);
unsigned int soemx_slave_obits(ecx_contextt *context, int slave);
unsigned int soemx_slave_ibits(ecx_contextt *context, int slave);
unsigned char *soemx_slave_outputs(ecx_contextt *context, int slave);
unsigned char *soemx_slave_inputs(ecx_contextt *context, int slave);
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
int soemx_eoe_set_ip(ecx_contextt *context, unsigned short slave, unsigned char port,
                     const unsigned char *ip, const unsigned char *subnet,
                     const unsigned char *gateway, int timeout);
int soemx_eoe_get_ip(ecx_contextt *context, unsigned short slave, unsigned char port,
                     unsigned char *ip, unsigned char *subnet,
                     unsigned char *gateway, int timeout);
int soemx_read_register(ecx_contextt *context, unsigned short slave,
                        unsigned short address, void *buffer, int size, int timeout);
int soemx_write_register(ecx_contextt *context, unsigned short slave,
                         unsigned short address, const void *buffer, int size, int timeout);
unsigned long long soemx_read_eeprom_ap(ecx_contextt *context, unsigned short address,
                                         unsigned short word, int timeout);
int soemx_write_eeprom_ap(ecx_contextt *context, unsigned short address,
                          unsigned short word, unsigned short data, int timeout);
unsigned long long soemx_read_eeprom_fp(ecx_contextt *context, unsigned short config_address,
                                        unsigned short word, int timeout);
int soemx_write_eeprom_fp(ecx_contextt *context, unsigned short config_address,
                          unsigned short word, unsigned short data, int timeout);
int soemx_amend_mailbox(ecx_contextt *context, unsigned short slave, int mailbox,
                        unsigned short start_address, unsigned short size);
int soemx_pop_error(ecx_contextt *context, unsigned short *slave,
                    unsigned short *index, unsigned char *subindex,
                    int *type, int *abort_code, unsigned char *error_reg,
                    unsigned char *b1, unsigned short *w1, unsigned short *w2);
