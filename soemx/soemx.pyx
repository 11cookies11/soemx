from libc.stdint cimport uint16_t, uint32_t, uint64_t, int32_t
from libc.string cimport strlen
import warnings
from .errors import Emergency

cdef extern from "soem/soem.h":
    ctypedef struct ec_adaptert:
        char name[128]
        char desc[128]
        ec_adaptert *next
    ctypedef struct ecx_contextt:
        pass
    ctypedef struct ecx_redportt:
        pass
    int ecx_init(ecx_contextt *context, const char *ifname)
    void ecx_close(ecx_contextt *context)
    int ecx_config_init(ecx_contextt *context)
    int ecx_config_map_group(ecx_contextt *context, void *pIOmap, unsigned char group)
    int ecx_recover_slave(ecx_contextt *context, uint16_t slave, int timeout)
    int ecx_reconfig_slave(ecx_contextt *context, uint16_t slave, int timeout)
    uint32_t ecx_readeeprom(ecx_contextt *context, uint16_t slave, uint16_t address, int timeout)
    int ecx_writeeeprom(ecx_contextt *context, uint16_t slave, uint16_t address,
                        uint16_t data, int timeout)
    int ecx_eeprom2master(ecx_contextt *context, uint16_t slave)
    int ecx_eeprom2pdi(ecx_contextt *context, uint16_t slave)
    unsigned char ecx_configdc(ecx_contextt *context)
    void ecx_dcsync0(ecx_contextt *context, uint16_t slave, unsigned char act,
                     uint32_t cycltime, int32_t cyclshift)
    void ecx_dcsync01(ecx_contextt *context, uint16_t slave, unsigned char act,
                      uint32_t cycltime0, uint32_t cycltime1, int32_t cyclshift)
    ec_adaptert *ec_find_adapters()
    void ec_free_adapters(ec_adaptert *adapter)
    int ecx_readstate(ecx_contextt *context)
    int ecx_writestate(ecx_contextt *context, uint16_t slave)
    uint16_t ecx_statecheck(ecx_contextt *context, uint16_t slave, uint16_t reqstate, int timeout)
    int ecx_send_processdata(ecx_contextt *context) noexcept nogil
    int ecx_receive_processdata(ecx_contextt *context, int timeout) noexcept nogil
    int ecx_send_processdata_group(ecx_contextt *context, unsigned char group) noexcept nogil
    int ecx_receive_processdata_group(ecx_contextt *context, unsigned char group,
                                      int timeout) noexcept nogil
    int ecx_SDOread(ecx_contextt *context, uint16_t slave, uint16_t index,
                    unsigned char subindex, unsigned char CA, int *psize,
                    void *p, int timeout) noexcept nogil
    int ecx_SDOwrite(ecx_contextt *context, uint16_t slave, uint16_t index,
                     unsigned char subindex, unsigned char CA, int psize,
                     const void *p, int timeout) noexcept nogil
    int ecx_FOEread(ecx_contextt *context, uint16_t slave, char *filename,
                    uint32_t password, int *psize, void *p, int timeout) noexcept nogil
    int ecx_FOEwrite(ecx_contextt *context, uint16_t slave, char *filename,
                     uint32_t password, int psize, void *p, int timeout) noexcept nogil
    int ecx_SoEread(ecx_contextt *context, uint16_t slave, unsigned char drive,
                    unsigned char flags, uint16_t idn, int *psize, void *p,
                    int timeout) noexcept nogil
    int ecx_SoEwrite(ecx_contextt *context, uint16_t slave, unsigned char drive,
                     unsigned char flags, uint16_t idn, int psize, void *p,
                     int timeout) noexcept nogil
    int ecx_RxPDO(ecx_contextt *context, uint16_t slave, uint16_t pdo_number,
                  int psize, const void *p) noexcept nogil
    int ecx_TxPDO(ecx_contextt *context, uint16_t slave, uint16_t pdo_number,
                  int *psize, void *p, int timeout) noexcept nogil
    int ecx_readPDOmap(ecx_contextt *context, uint16_t slave,
                       uint32_t *output_size, uint32_t *input_size)
    int ecx_readPDOmapCA(ecx_contextt *context, uint16_t slave, int thread,
                         uint32_t *output_size, uint32_t *input_size)
    int ecx_readIDNmap(ecx_contextt *context, uint16_t slave,
                       uint32_t *output_size, uint32_t *input_size)
    int ecx_EOEsend(ecx_contextt *context, uint16_t slave, unsigned char port,
                    int psize, void *p, int timeout) noexcept nogil
    int ecx_EOErecv(ecx_contextt *context, uint16_t slave, unsigned char port,
                    int *psize, void *p, int timeout) noexcept nogil
    int ecx_mbxempty(ecx_contextt *context, uint16_t slave, int timeout) noexcept nogil
    int ecx_iserror(ecx_contextt *context)

cdef extern from "soemx_native.h":
    ecx_contextt *soemx_context_create()
    void soemx_context_destroy(ecx_contextt *context)
    unsigned short soemx_expected_wkc(ecx_contextt *context)
    unsigned short soemx_group_expected_wkc(ecx_contextt *context, unsigned char group)
    unsigned short soemx_master_state(ecx_contextt *context)
    void soemx_set_master_state(ecx_contextt *context, unsigned short state)
    ecx_redportt *soemx_redport_create()
    void soemx_redport_destroy(ecx_redportt *redport)
    int soemx_init_redundant(ecx_contextt *context, ecx_redportt *redport,
                             const char *ifname, const char *ifname2)
    int soemx_slave_count(ecx_contextt *context)
    const char *soemx_slave_name(ecx_contextt *context, int slave)
    unsigned int soemx_slave_manufacturer(ecx_contextt *context, int slave)
    unsigned int soemx_slave_id(ecx_contextt *context, int slave)
    unsigned int soemx_slave_revision(ecx_contextt *context, int slave)
    unsigned int soemx_slave_serial(ecx_contextt *context, int slave)
    unsigned short soemx_slave_config_address(ecx_contextt *context, int slave)
    unsigned short soemx_slave_alias_address(ecx_contextt *context, int slave)
    unsigned short soemx_slave_mbx_out_address(ecx_contextt *context, int slave)
    unsigned short soemx_slave_mbx_out_size(ecx_contextt *context, int slave)
    unsigned short soemx_slave_mbx_in_address(ecx_contextt *context, int slave)
    unsigned short soemx_slave_mbx_in_size(ecx_contextt *context, int slave)
    unsigned short soemx_slave_state(ecx_contextt *context, int slave)
    unsigned short soemx_slave_al_status(ecx_contextt *context, int slave)
    int soemx_slave_has_dc(ecx_contextt *context, int slave)
    int soemx_slave_is_lost(ecx_contextt *context, int slave)
    unsigned int soemx_slave_obits(ecx_contextt *context, int slave)
    unsigned int soemx_slave_ibits(ecx_contextt *context, int slave)
    unsigned char *soemx_slave_outputs(ecx_contextt *context, int slave)
    unsigned char *soemx_slave_inputs(ecx_contextt *context, int slave)
    long long soemx_dc_time(ecx_contextt *context)
    int soemx_mailbox_receive(ecx_contextt *context, unsigned short slave,
                              int timeout, void *buffer, int capacity) noexcept nogil
    int soemx_mailbox_send(ecx_contextt *context, unsigned short slave,
                           const void *buffer, int size, int timeout) noexcept nogil
    int soemx_read_od_entry(ecx_contextt *context, unsigned short slave, int entry,
                            unsigned short *index, unsigned short *datatype,
                            unsigned char *object_code, unsigned char *max_sub,
                            char *name, int name_capacity)
    int soemx_read_oe_entry(ecx_contextt *context, unsigned short slave, int object,
                            int entry, unsigned char *value_info,
                            unsigned short *datatype, unsigned short *bit_length,
                            unsigned short *access, char *name, int name_capacity)
    void soemx_set_overlapped(ecx_contextt *context, int enabled)
    void soemx_set_packed(ecx_contextt *context, int enabled)
    void soemx_set_manual_state_change(ecx_contextt *context, int enabled)
    int soemx_get_manual_state_change(ecx_contextt *context)
    int soemx_eoe_set_ip(ecx_contextt *context, unsigned short slave, unsigned char port,
                         const unsigned char *ip, const unsigned char *subnet,
                         const unsigned char *gateway, int timeout) noexcept nogil
    int soemx_eoe_get_ip(ecx_contextt *context, unsigned short slave, unsigned char port,
                         unsigned char *ip, unsigned char *subnet,
                         unsigned char *gateway, int timeout) noexcept nogil
    int soemx_read_register(ecx_contextt *context, unsigned short slave,
                            unsigned short address, void *buffer, int size, int timeout) noexcept nogil
    int soemx_write_register(ecx_contextt *context, unsigned short slave,
                            unsigned short address, const void *buffer, int size, int timeout) noexcept nogil
    unsigned long long soemx_read_eeprom_ap(ecx_contextt *context, unsigned short address,
                                            unsigned short word, int timeout) noexcept nogil
    int soemx_write_eeprom_ap(ecx_contextt *context, unsigned short address,
                              unsigned short word, unsigned short data, int timeout) noexcept nogil
    unsigned long long soemx_read_eeprom_fp(ecx_contextt *context, unsigned short config_address,
                                            unsigned short word, int timeout) noexcept nogil
    int soemx_write_eeprom_fp(ecx_contextt *context, unsigned short config_address,
                              unsigned short word, unsigned short data, int timeout) noexcept nogil
    int soemx_amend_mailbox(ecx_contextt *context, unsigned short slave, int mailbox,
                            unsigned short start_address, unsigned short size) noexcept nogil
    int soemx_pop_error(ecx_contextt *context, unsigned short *slave,
                        unsigned short *index, unsigned char *subindex,
                        int *type, int *abort_code, unsigned char *error_reg,
                        unsigned char *b1, unsigned short *w1, unsigned short *w2)


cdef class Master:
    cdef ecx_contextt *_context
    cdef ecx_redportt *_redport
    cdef bint _open
    cdef object _io_map
    cdef object _interface
    cdef object _interface2
    cdef int _mapped_size
    cdef object _setup_func
    cdef dict _slave_config_funcs
    cdef dict _slave_setup_funcs
    cdef list _emergency_callbacks
    cdef bint _in_op
    cdef bint _do_check_state

    def __cinit__(self):
        self._context = soemx_context_create()
        self._redport = soemx_redport_create()
        self._setup_func = None
        self._mapped_size = 0
        self._interface = None
        self._interface2 = None
        self._slave_config_funcs = {}
        self._slave_setup_funcs = {}
        self._emergency_callbacks = []
        self._in_op = False
        self._do_check_state = False
        if self._context == NULL or self._redport == NULL:
            raise MemoryError("unable to allocate SOEM context")

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.close()
        return False

    @property
    def opened(self):
        return bool(self._open)

    @property
    def is_open(self):
        return bool(self._open)

    @property
    def interface(self):
        return self._interface

    @property
    def redundant_interface(self):
        return self._interface2

    @property
    def context_initialized(self):
        return self._context != NULL

    def check_context_is_initialized(self):
        """Raise when the native SOEM context is unavailable."""
        if self._context == NULL:
            raise RuntimeError("SOEM context is not initialized")
        return True

    def __dealloc__(self):
        if self._context != NULL:
            if self._open:
                ecx_close(self._context)
            soemx_context_destroy(self._context)
            self._context = NULL
        if self._redport != NULL:
            soemx_redport_destroy(self._redport)
            self._redport = NULL

    def open(self, interface: str, interface2=None):
        if self._open:
            raise RuntimeError("master is already open")
        if not isinstance(interface, str) or not interface:
            raise ValueError("interface must be a non-empty string")
        encoded = interface.encode("utf-8")
        if interface2 is None:
            result = ecx_init(self._context, encoded)
        else:
            if not isinstance(interface2, str) or not interface2:
                raise ValueError("interface2 must be a non-empty string")
            encoded2 = interface2.encode("utf-8")
            result = soemx_init_redundant(self._context, self._redport,
                                          encoded, encoded2)
        if result <= 0:
            raise OSError(f"failed to open EtherCAT interface: {interface}")
        self._open = True
        self._interface = interface
        self._interface2 = interface2

    def close(self):
        if self._open:
            ecx_close(self._context)
            self._open = False
        self._io_map = None
        self._mapped_size = 0
        self._in_op = False
        self._do_check_state = False
        self._interface = None
        self._interface2 = None

    def config_init(self) -> int:
        if not self._open:
            raise RuntimeError("master is not open")
        self._slave_config_funcs.clear()
        self._slave_setup_funcs.clear()
        count = ecx_config_init(self._context)
        self._io_map = None
        self._mapped_size = 0
        self._in_op = False
        self._do_check_state = False
        return count

    @property
    def setup_func(self):
        """Default callback invoked for each slave before PDO mapping."""
        return self._setup_func

    @setup_func.setter
    def setup_func(self, callback):
        if callback is not None and not callable(callback):
            raise TypeError("setup_func must be callable or None")
        self._setup_func = callback

    def recover_slave(self, slave: int, timeout: int = 5_000_000) -> int:
        """Recover a slave that has lost communication."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count:
            raise IndexError("slave index out of range")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        return ecx_recover_slave(self._context, <uint16_t>slave, timeout)

    def reconfig_slave(self, slave: int, timeout: int = 5_000_000) -> int:
        """Reconfigure a slave that is no longer in its expected state."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count:
            raise IndexError("slave index out of range")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        return ecx_reconfig_slave(self._context, <uint16_t>slave, timeout)

    def config_map(self, size: int = 65536, group: int = 0) -> int:
        """Map slave PDOs into an IO buffer and return mapped byte count."""
        if not self._open:
            raise RuntimeError("master is not open")
        if size <= 0 or group < 0 or group > 255:
            raise ValueError("invalid IO map size or group")
        for index in range(1, self.slave_count + 1):
            callback = self._slave_config_funcs.get(index, self._setup_func)
            setup_callback = self._slave_setup_funcs.get(index)
            if callback is not None:
                callback(Slave(self, index))
            if setup_callback is not None:
                setup_callback(Slave(self, index))
        soemx_set_overlapped(self._context, 0)
        self._io_map = bytearray(size)
        cdef char *io_ptr = self._io_map
        self._mapped_size = ecx_config_map_group(self._context, <void *>io_ptr,
                                                 <unsigned char>group)
        return self._mapped_size

    def config_overlap_map(self, size: int = 65536, group: int = 0) -> int:
        """Configure an overlapped PDO map, matching PySOEM's API."""
        if not self._open:
            raise RuntimeError("master is not open")
        if size <= 0 or group < 0 or group > 255:
            raise ValueError("invalid IO map size or group")
        for index in range(1, self.slave_count + 1):
            callback = self._slave_config_funcs.get(index, self._setup_func)
            setup_callback = self._slave_setup_funcs.get(index)
            if callback is not None:
                callback(Slave(self, index))
            if setup_callback is not None:
                setup_callback(Slave(self, index))
        self._io_map = bytearray(size)
        soemx_set_overlapped(self._context, 1)
        cdef char *io_ptr = self._io_map
        self._mapped_size = ecx_config_map_group(self._context, <void *>io_ptr,
                                                 <unsigned char>group)
        return self._mapped_size

    @property
    def mapped_size(self):
        """Number of bytes actually assigned by the last PDO mapping."""
        return self._mapped_size

    def set_packed_map(self, enabled: bool = True):
        """Enable or disable byte-packed PDO mapping before config_map()."""
        if not self._open:
            raise RuntimeError("master is not open")
        soemx_set_packed(self._context, 1 if enabled else 0)

    @property
    def manual_state_change(self):
        """Whether SOEM leaves state transitions under application control."""
        return bool(soemx_get_manual_state_change(self._context))

    @manual_state_change.setter
    def manual_state_change(self, enabled: bool):
        if not self._open:
            raise RuntimeError("master is not open")
        soemx_set_manual_state_change(self._context, 1 if enabled else 0)

    def read_eeprom(self, slave: int, address: int, timeout: int = 20_000) -> int:
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count or not 0 <= address <= 0xffff:
            raise ValueError("invalid slave or EEPROM address")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        return ecx_readeeprom(self._context, <uint16_t>slave, <uint16_t>address, timeout)

    def write_eeprom(self, slave: int, address: int, data: int,
                     timeout: int = 20_000) -> int:
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count or not 0 <= address <= 0xffff:
            raise ValueError("invalid slave or EEPROM address")
        if not 0 <= data <= 0xffff or timeout <= 0:
            raise ValueError("invalid EEPROM data or timeout")
        return ecx_writeeeprom(self._context, <uint16_t>slave, <uint16_t>address,
                               <uint16_t>data, timeout)

    def read_eeprom_ap(self, address: int, word: int, timeout: int = 20_000) -> int:
        """Read an EEPROM word through an Auto-Increment address."""
        if not self._open:
            raise RuntimeError("master is not open")
        if not 0 <= address <= 0xffff or not 0 <= word <= 0xffff or timeout <= 0:
            raise ValueError("invalid EEPROM address, word, or timeout")
        return soemx_read_eeprom_ap(self._context, <uint16_t>address,
                                    <uint16_t>word, timeout)

    def write_eeprom_ap(self, address: int, word: int, data: int,
                        timeout: int = 20_000) -> int:
        if not self._open:
            raise RuntimeError("master is not open")
        if not 0 <= address <= 0xffff or not 0 <= word <= 0xffff or not 0 <= data <= 0xffff or timeout <= 0:
            raise ValueError("invalid EEPROM address, word, data, or timeout")
        return soemx_write_eeprom_ap(self._context, <uint16_t>address,
                                     <uint16_t>word, <uint16_t>data, timeout)

    def read_eeprom_fp(self, config_address: int, word: int,
                       timeout: int = 20_000) -> int:
        """Read an EEPROM word through a Configured Address."""
        if not self._open:
            raise RuntimeError("master is not open")
        if not 0 <= config_address <= 0xffff or not 0 <= word <= 0xffff or timeout <= 0:
            raise ValueError("invalid config address, word, or timeout")
        return soemx_read_eeprom_fp(self._context, <uint16_t>config_address,
                                    <uint16_t>word, timeout)

    def write_eeprom_fp(self, config_address: int, word: int, data: int,
                        timeout: int = 20_000) -> int:
        if not self._open:
            raise RuntimeError("master is not open")
        if not 0 <= config_address <= 0xffff or not 0 <= word <= 0xffff or not 0 <= data <= 0xffff or timeout <= 0:
            raise ValueError("invalid config address, word, data, or timeout")
        return soemx_write_eeprom_fp(self._context, <uint16_t>config_address,
                                     <uint16_t>word, <uint16_t>data, timeout)

    def eeprom_to_master(self, slave: int) -> int:
        """Give the EtherCAT master control of a slave's EEPROM."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count:
            raise IndexError("slave index out of range")
        return ecx_eeprom2master(self._context, <uint16_t>slave)

    def eeprom_to_pdi(self, slave: int) -> int:
        """Return a slave's EEPROM control to its PDI."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count:
            raise IndexError("slave index out of range")
        return ecx_eeprom2pdi(self._context, <uint16_t>slave)

    def config_dc(self) -> bool:
        if not self._open:
            raise RuntimeError("master is not open")
        return bool(ecx_configdc(self._context))

    @property
    def dc_time(self) -> int:
        return soemx_dc_time(self._context)

    def dc_sync0(self, slave: int, cycle_time: int, active: bool = True,
                 cycle_shift: int = 0):
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count or cycle_time <= 0:
            raise ValueError("invalid slave or cycle time")
        ecx_dcsync0(self._context, <uint16_t>slave, <unsigned char>active,
                    <uint32_t>cycle_time, <int32_t>cycle_shift)

    def dc_sync01(self, slave: int, cycle_time0: int, cycle_time1: int,
                  active: bool = True, cycle_shift: int = 0):
        """Configure dual-cycle distributed-clock synchronization."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count:
            raise ValueError("invalid slave")
        if cycle_time0 <= 0 or cycle_time1 <= 0:
            raise ValueError("cycle times must be positive")
        ecx_dcsync01(self._context, <uint16_t>slave, <unsigned char>active,
                     <uint32_t>cycle_time0, <uint32_t>cycle_time1,
                     <int32_t>cycle_shift)

    @property
    def io_map(self):
        """Return the mutable process-data IO map buffer."""
        if self._io_map is None:
            raise RuntimeError("PDO map has not been configured")
        return self._io_map

    def write_io_map(self, data: bytes, offset: int = 0):
        if self._io_map is None:
            raise RuntimeError("PDO map has not been configured")
        if offset < 0 or offset + len(data) > len(self._io_map):
            raise ValueError("IO map write is out of range")
        self._io_map[offset:offset + len(data)] = data

    def send_processdata(self) -> int:
        if not self._open or self._io_map is None:
            raise RuntimeError("master is not open or PDO map is not configured")
        return ecx_send_processdata(self._context)

    def send_overlap_processdata(self) -> int:
        """Send process data through the overlap-map compatible entry point."""
        return self.send_processdata()

    def receive_processdata(self, timeout: int = 2_000_000) -> int:
        if not self._open or self._io_map is None:
            raise RuntimeError("master is not open or PDO map is not configured")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        cdef int timeout_us = timeout
        cdef int result
        with nogil:
            result = ecx_receive_processdata(self._context, timeout_us)
        return result

    def exchange_processdata(self, timeout: int = 2_000_000) -> int:
        """Send the current IO map and wait for the received working counter."""
        self.send_processdata()
        return self.receive_processdata(timeout)

    def exchange_processdata_group(self, group: int = 0,
                                   timeout: int = 2_000_000) -> int:
        """Exchange process data for one SOEM group and return its WKC."""
        self.send_processdata_group(group)
        return self.receive_processdata_group(group, timeout)

    def send_processdata_group(self, group: int = 0) -> int:
        if not self._open or self._io_map is None:
            raise RuntimeError("master is not open or PDO map is not configured")
        if group < 0 or group > 255:
            raise ValueError("group must be between 0 and 255")
        cdef unsigned char group_id = <unsigned char>group
        cdef int result
        with nogil:
            result = ecx_send_processdata_group(self._context, group_id)
        return result

    def receive_processdata_group(self, group: int = 0,
                                  timeout: int = 2_000_000) -> int:
        if not self._open or self._io_map is None:
            raise RuntimeError("master is not open or PDO map is not configured")
        if group < 0 or group > 255 or timeout <= 0:
            raise ValueError("invalid group or timeout")
        cdef unsigned char group_id = <unsigned char>group
        cdef int timeout_us = timeout
        cdef int result
        with nogil:
            result = ecx_receive_processdata_group(self._context, group_id, timeout_us)
        return result

    def mailbox_receive(self, slave: int, size: int = 2048,
                        timeout: int = 20_000) -> bytes:
        """Receive a raw mailbox buffer copied out of SOEM's internal pool."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count or size <= 0 or timeout <= 0:
            raise ValueError("invalid slave, size, or timeout")
        buffer = bytearray(size)
        cdef char *buffer_ptr = buffer
        cdef int timeout_ms = timeout
        cdef unsigned short slave_id = <unsigned short>slave
        cdef int buffer_size = size
        cdef int result
        with nogil:
            result = soemx_mailbox_receive(self._context, slave_id,
                                           timeout_ms, <void *>buffer_ptr, buffer_size)
        if result <= 0:
            raise TimeoutError("mailbox receive failed or timed out")
        return bytes(buffer[:result])

    def mailbox_send(self, slave: int, data: bytes, timeout: int = 20_000) -> int:
        """Send a raw mailbox buffer."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count:
            raise ValueError("invalid slave")
        if not isinstance(data, (bytes, bytearray, memoryview)) or not data or len(data) > 1486:
            raise ValueError("data must be a non-empty bytes-like mailbox payload")
        data = bytes(data)
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        cdef const char *data_ptr = data
        cdef unsigned short slave_id = <unsigned short>slave
        cdef int data_size = len(data)
        cdef int timeout_ms = timeout
        cdef int result
        with nogil:
            result = soemx_mailbox_send(self._context, slave_id,
                                        <const void *>data_ptr, data_size,
                                        timeout_ms)
        if result <= 0:
            raise TimeoutError("mailbox send failed or timed out")
        return result

    def mailbox_empty(self, slave: int, timeout: int = 20_000) -> int:
        """Wait until a slave mailbox is ready for another request."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count:
            raise IndexError("slave index out of range")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        return ecx_mbxempty(self._context, <uint16_t>slave, timeout)

    def read_register(self, slave: int, address: int, size: int = 2,
                      timeout: int = 20_000) -> bytes:
        """Read raw bytes from an EtherCAT slave register address."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count or not 0 <= address <= 0xffff:
            raise ValueError("invalid slave or register address")
        if size <= 0 or size > 0xffff or timeout <= 0:
            raise ValueError("invalid register size or timeout")
        buffer = bytearray(size)
        cdef char *buffer_ptr = buffer
        cdef unsigned short slave_id = <unsigned short>slave
        cdef unsigned short register_address = <unsigned short>address
        cdef int register_size = size
        cdef int timeout_ms = timeout
        cdef int result
        with nogil:
            result = soemx_read_register(self._context, slave_id,
                                         register_address,
                                         <void *>buffer_ptr, register_size, timeout_ms)
        if result <= 0:
            raise RuntimeError("register read failed")
        return bytes(buffer)

    def write_register(self, slave: int, address: int, data: bytes,
                       timeout: int = 20_000) -> int:
        """Write raw bytes to an EtherCAT slave register address."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count or not 0 <= address <= 0xffff:
            raise ValueError("invalid slave or register address")
        if not isinstance(data, (bytes, bytearray, memoryview)) or not data or len(data) > 0xffff:
            raise ValueError("data must be a non-empty bytes-like register payload")
        data = bytes(data)
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        cdef const char *data_ptr = data
        cdef unsigned short slave_id = <unsigned short>slave
        cdef unsigned short register_address = <unsigned short>address
        cdef int data_size = len(data)
        cdef int timeout_ms = timeout
        cdef int result
        with nogil:
            result = soemx_write_register(self._context, slave_id,
                                          register_address,
                                          <const void *>data_ptr, data_size,
                                          timeout_ms)
        if result <= 0:
            raise RuntimeError("register write failed")
        return result

    def pop_error(self):
        """Pop the oldest SOEM error, or return ``None`` when empty."""
        cdef unsigned short slave = 0
        cdef unsigned short index = 0
        cdef unsigned char subindex = 0
        cdef int error_type = 0
        cdef int abort_code = 0
        cdef unsigned char error_reg = 0
        cdef unsigned char b1 = 0
        cdef unsigned short w1 = 0
        cdef unsigned short w2 = 0
        if not soemx_pop_error(self._context, &slave, &index, &subindex,
                               &error_type, &abort_code, &error_reg, &b1,
                               &w1, &w2):
            return None
        error = {"slave": slave, "index": index, "subindex": subindex,
                 "type": error_type, "abort_code": abort_code}
        if error_type == 1:
            notification = Emergency(slave, abort_code, error_reg, b1, w1, w2)
            for callback in self._emergency_callbacks:
                callback(notification)
        return error

    @property
    def error_pending(self):
        """Whether SOEM currently has at least one queued error."""
        return bool(ecx_iserror(self._context))

    def clear_errors(self):
        """Discard all queued SOEM errors and return the number removed."""
        count = 0
        callbacks = self._emergency_callbacks
        self._emergency_callbacks = []
        try:
            while self.pop_error() is not None:
                count += 1
        finally:
            self._emergency_callbacks = callbacks
        return count

    def add_emergency_callback(self, callback):
        """Register a callback invoked with queued emergency error mappings."""
        if not callable(callback):
            raise TypeError("callback must be callable")
        self._emergency_callbacks.append(callback)

    def remove_emergency_callback(self, callback):
        """Remove a previously registered emergency callback."""
        try:
            self._emergency_callbacks.remove(callback)
        except ValueError:
            return False
        return True

    def clear_emergency_callbacks(self):
        """Remove all registered emergency callbacks."""
        count = len(self._emergency_callbacks)
        self._emergency_callbacks = []
        return count

    def errors(self):
        """Return all currently queued SOEM errors in FIFO order."""
        result = []
        while True:
            error = self.pop_error()
            if error is None:
                return result
            result.append(error)

    def read_state(self) -> int:
        """Read the state of every configured slave; return slave count."""
        if not self._open:
            raise RuntimeError("master is not open")
        return ecx_readstate(self._context)

    def write_state(self, slave: int = 0) -> int:
        """Request a state change. ``slave=0`` addresses all slaves."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 0 or slave > self.slave_count:
            raise IndexError("slave index out of range")
        return ecx_writestate(self._context, <uint16_t>slave)

    def state_check(self, state: int, slave: int = 0, timeout: int = 2_000_000) -> int:
        """Wait for a slave (or all slaves) to reach ``state``."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 0 or slave > self.slave_count:
            raise IndexError("slave index out of range")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        return ecx_statecheck(self._context, <uint16_t>slave,
                              <uint16_t>state, timeout)

    @property
    def slave_count(self) -> int:
        return soemx_slave_count(self._context)

    @property
    def expected_wkc(self):
        return soemx_expected_wkc(self._context)

    def expected_wkc_for_group(self, group: int = 0):
        """Return the expected working counter for a SOEM group."""
        if not 0 <= group <= 255:
            raise ValueError("group must be between 0 and 255")
        return soemx_group_expected_wkc(self._context, <unsigned char>group)

    @property
    def state(self):
        return soemx_master_state(self._context)

    @state.setter
    def state(self, value: int):
        if not 0 <= value <= 0xffff:
            raise ValueError("invalid state")
        soemx_set_master_state(self._context, <unsigned short>value)

    @property
    def in_op(self):
        return bool(self._in_op)

    @in_op.setter
    def in_op(self, value):
        self._in_op = bool(value)

    @property
    def do_check_state(self):
        return bool(self._do_check_state)

    @do_check_state.setter
    def do_check_state(self, value):
        self._do_check_state = bool(value)

    def slave(self, index: int):
        if index < 1 or index > self.slave_count:
            raise IndexError("slave index out of range")
        return Slave(self, index)

    @property
    def slaves(self):
        """Return configured slaves as a zero-based Python list."""
        return [Slave(self, index) for index in range(1, self.slave_count + 1)]

    def eoe(self, slave: int, port: int = 0):
        """Return an EoE channel for a configured slave and mailbox port."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > self.slave_count:
            raise IndexError("slave index out of range")
        if port < 0 or port > 15:
            raise ValueError("port must be between 0 and 15")
        return Eoe(self, slave, port)


cdef class Eoe:
    cdef Master _master
    cdef uint16_t _slave
    cdef unsigned char _port

    def __cinit__(self, Master master, int slave, int port):
        self._master = master
        self._slave = <uint16_t>slave
        self._port = <unsigned char>port

    @property
    def slave(self):
        return self._slave

    @property
    def port(self):
        return self._port

    def send(self, data: bytes, timeout: int = 20000) -> int:
        """Send one Ethernet frame through EoE; return SOEM's result code."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not isinstance(data, (bytes, bytearray, memoryview)):
            raise TypeError("data must be a bytes-like object")
        data = bytes(data)
        if len(data) == 0:
            raise ValueError("data must not be empty")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        cdef const char *data_ptr = data
        cdef int data_size = len(data)
        cdef int timeout_ms = timeout
        cdef int result
        with nogil:
            result = ecx_EOEsend(self._master._context, self._slave, self._port,
                                 data_size, <void *>data_ptr, timeout_ms)
        if result <= 0:
            raise TimeoutError("EoE frame send failed or timed out")
        return result

    def set_ip(self, ip: bytes, subnet: bytes = b"\xff\xff\xff\x00",
               gateway: bytes = b"\x00\x00\x00\x00", timeout: int = 20000) -> int:
        """Set the EoE IPv4, subnet mask and default gateway (4-byte values)."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        for value, name in ((ip, "ip"), (subnet, "subnet"), (gateway, "gateway")):
            if not isinstance(value, (bytes, bytearray, memoryview)) or len(value) != 4:
                raise ValueError(f"{name} must contain exactly four bytes")
        ip = bytes(ip)
        subnet = bytes(subnet)
        gateway = bytes(gateway)
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        cdef const unsigned char *ip_ptr = ip
        cdef const unsigned char *subnet_ptr = subnet
        cdef const unsigned char *gateway_ptr = gateway
        cdef int timeout_ms = timeout
        cdef int result
        with nogil:
            result = soemx_eoe_set_ip(self._master._context, self._slave, self._port,
                                      ip_ptr, subnet_ptr, gateway_ptr, timeout_ms)
        if result <= 0:
            raise RuntimeError("EoE IP configuration failed")
        return result

    def get_ip(self, timeout: int = 20000):
        """Read EoE IPv4, subnet mask and default gateway as 4-byte values."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        cdef unsigned char ip[4]
        cdef unsigned char subnet[4]
        cdef unsigned char gateway[4]
        cdef int timeout_ms = timeout
        cdef int result
        with nogil:
            result = soemx_eoe_get_ip(self._master._context, self._slave, self._port,
                                      ip, subnet, gateway, timeout_ms)
        if result <= 0:
            raise RuntimeError("EoE IP query failed")
        return bytes(ip), bytes(subnet), bytes(gateway)

    def receive(self, max_size: int = 1600, timeout: int = 20000) -> bytes:
        """Receive one reassembled Ethernet frame through EoE."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if max_size <= 0:
            raise ValueError("max_size must be positive")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        buffer = bytearray(max_size)
        cdef int size = max_size
        cdef char *buffer_ptr = buffer
        cdef int timeout_ms = timeout
        cdef int result
        with nogil:
            result = ecx_EOErecv(self._master._context, self._slave, self._port,
                                 &size, <void *>buffer_ptr, timeout_ms)
        if result <= 0:
            raise TimeoutError("EoE frame receive failed or timed out")
        return bytes(buffer[:size])


cdef class Slave:
    cdef Master _master
    cdef int _index

    def __cinit__(self, Master master, int index):
        self._master = master
        self._index = index

    @property
    def config_func(self):
        return self._master._slave_config_funcs.get(self._index)

    @config_func.setter
    def config_func(self, callback):
        if callback is not None and not callable(callback):
            raise TypeError("config_func must be callable or None")
        if callback is None:
            self._master._slave_config_funcs.pop(self._index, None)
        else:
            self._master._slave_config_funcs[self._index] = callback

    @property
    def setup_func(self):
        return self._master._slave_setup_funcs.get(self._index)

    @setup_func.setter
    def setup_func(self, callback):
        if callback is not None and not callable(callback):
            raise TypeError("setup_func must be callable or None")
        if callback is None:
            self._master._slave_setup_funcs.pop(self._index, None)
        else:
            self._master._slave_setup_funcs[self._index] = callback

    @property
    def index(self):
        return self._index

    @property
    def name(self):
        return soemx_slave_name(self._master._context, self._index).decode("utf-8", errors="replace")

    @property
    def manufacturer(self):
        return soemx_slave_manufacturer(self._master._context, self._index)

    @property
    def id(self):
        return soemx_slave_id(self._master._context, self._index)

    @property
    def revision(self):
        return soemx_slave_revision(self._master._context, self._index)

    @property
    def serial(self):
        return soemx_slave_serial(self._master._context, self._index)

    @property
    def config_address(self):
        return soemx_slave_config_address(self._master._context, self._index)

    @property
    def alias_address(self):
        return soemx_slave_alias_address(self._master._context, self._index)

    @property
    def mailbox_out_address(self):
        return soemx_slave_mbx_out_address(self._master._context, self._index)

    @property
    def mailbox_out_size(self):
        return soemx_slave_mbx_out_size(self._master._context, self._index)

    @property
    def mailbox_in_address(self):
        return soemx_slave_mbx_in_address(self._master._context, self._index)

    @property
    def mailbox_in_size(self):
        return soemx_slave_mbx_in_size(self._master._context, self._index)

    # PySOEM-compatible field names.
    @property
    def eep_man(self):
        return self.manufacturer

    @property
    def eep_id(self):
        return self.id

    @property
    def eep_rev(self):
        return self.revision

    @property
    def eep_ser(self):
        return self.serial

    @property
    def configadr(self):
        return self.config_address

    @property
    def aliasadr(self):
        return self.alias_address

    @property
    def state(self):
        return soemx_slave_state(self._master._context, self._index)

    @property
    def al_status_code(self):
        return soemx_slave_al_status(self._master._context, self._index)

    @property
    def has_dc(self):
        return bool(soemx_slave_has_dc(self._master._context, self._index))

    @property
    def is_lost(self):
        return bool(soemx_slave_is_lost(self._master._context, self._index))

    @property
    def al_status(self):
        return self.al_status_code

    @property
    def islost(self):
        return self.is_lost

    @property
    def hasdc(self):
        return self.has_dc

    @property
    def man(self):
        return self.manufacturer

    @property
    def rev(self):
        return self.revision

    def eeprom_read(self, word_address: int, timeout: int = 20_000):
        value = self._master.read_eeprom(self._index, word_address, timeout)
        return int(value).to_bytes(4, "little")

    def eeprom_write(self, word_address: int, data: bytes,
                     timeout: int = 20_000) -> int:
        if not isinstance(data, bytes) or len(data) != 2:
            raise ValueError("EEPROM write data must contain exactly two bytes")
        return self._master.write_eeprom(self._index, word_address,
                                         int.from_bytes(data, "little"), timeout)

    def recover(self, timeout: int = 500) -> int:
        return self._master.recover_slave(self._index, timeout)

    def reconfig(self, timeout: int = 500) -> int:
        return self._master.reconfig_slave(self._index, timeout)

    def state_check(self, state: int, timeout: int = 2_000_000) -> int:
        return self._master.state_check(state, self._index, timeout)

    def write_state(self) -> int:
        return self._master.write_state(self._index)

    def mbx_receive(self, size: int = 2048, timeout: int = 20_000) -> bytes:
        """Receive one raw mailbox frame from this slave."""
        return self._master.mailbox_receive(self._index, size, timeout)

    def dc_sync(self, active: bool, sync0_cycle_time: int,
                sync0_shift_time: int = 0, sync1_cycle_time=None):
        if sync1_cycle_time is None:
            return self._master.dc_sync0(self._index, sync0_cycle_time,
                                         active, sync0_shift_time)
        return self._master.dc_sync01(self._index, sync0_cycle_time,
                                      sync1_cycle_time, active,
                                      sync0_shift_time)

    def amend_mbx(self, mailbox, start_address: int, size: int):
        """Override the configured mailbox address and size."""
        if mailbox == "out":
            sm_address = 0x0800
            direction = 0
        elif mailbox == "in":
            sm_address = 0x0808
            direction = 1
        else:
            raise AttributeError("mailbox must be 'out' or 'in'")
        if not 0 <= start_address <= 0xFFFF or not 1 <= size <= 0xFFFF:
            raise ValueError("invalid mailbox address or size")
        sm = bytearray(self._master.read_register(self._index, sm_address, 8, 4000))
        sm[0:4] = int(start_address).to_bytes(4, "little")
        sm[4:6] = int(size).to_bytes(2, "little")
        self._master.write_register(self._index, sm_address, bytes(sm), 4000)
        return bool(soemx_amend_mailbox(self._master._context, self._index,
                                        direction, start_address, size))

    def _watchdog_register(self, wd_type):
        if wd_type == "pdi":
            return 0x0410
        if wd_type == "processdata":
            return 0x0420
        raise AttributeError("watchdog type must be 'pdi' or 'processdata'")

    def _get_watchdog_divider_ns(self):
        divider = int.from_bytes(
            self._master.read_register(self._index, 0x0400, 2, 4000),
            "little")
        return 40 * (divider + 2)

    def get_max_watchdog_time(self):
        """Return the maximum configurable watchdog time in milliseconds."""
        return 0xFFFF * self._get_watchdog_divider_ns() / 1_000_000.0

    def get_watchdog(self, wd_type):
        """Read a PDI or process-data watchdog time in milliseconds."""
        register = self._watchdog_register(wd_type)
        value = int.from_bytes(
            self._master.read_register(self._index, register, 2, 4000),
            "little")
        return value * self._get_watchdog_divider_ns() / 1_000_000.0

    def set_watchdog(self, wd_type, wd_time_ms):
        """Set a PDI or process-data watchdog time in milliseconds."""
        register = self._watchdog_register(wd_type)
        requested = float(wd_time_ms)
        if requested < 0:
            raise AttributeError("watchdog time must not be negative")
        maximum = self.get_max_watchdog_time()
        if requested > maximum:
            raise AttributeError("watchdog time exceeds the slave limit")
        divider_ns = self._get_watchdog_divider_ns()
        register_value = int((requested * 1_000_000.0) / divider_ns)
        self._master.write_register(self._index, register,
                                    register_value.to_bytes(2, "little"),
                                    4000)
        actual = register_value * divider_ns / 1_000_000.0
        if actual != requested:
            warnings.warn("watchdog time rounded to the nearest register value")

    @property
    def output_bits(self):
        return soemx_slave_obits(self._master._context, self._index)

    @property
    def input_bits(self):
        return soemx_slave_ibits(self._master._context, self._index)

    @property
    def obits(self):
        return self.output_bits

    @property
    def ibits(self):
        return self.input_bits

    @property
    def outputs(self):
        """Writable memoryview onto this slave's mapped output bytes."""
        cdef unsigned int bits = soemx_slave_obits(self._master._context, self._index)
        cdef unsigned int size = (bits + 7) // 8
        cdef unsigned char *pointer = soemx_slave_outputs(self._master._context, self._index)
        if size == 0 or pointer == NULL:
            return memoryview(bytearray())
        return <unsigned char[:size]>pointer

    @property
    def inputs(self):
        """Read-only-by-convention memoryview onto mapped input bytes."""
        cdef unsigned int bits = soemx_slave_ibits(self._master._context, self._index)
        cdef unsigned int size = (bits + 7) // 8
        cdef unsigned char *pointer = soemx_slave_inputs(self._master._context, self._index)
        if size == 0 or pointer == NULL:
            return memoryview(bytearray())
        return <unsigned char[:size]>pointer

    @property
    def output(self):
        return self.outputs

    @property
    def input(self):
        return self.inputs

    @property
    def output_size(self):
        return (self.output_bits + 7) // 8

    @property
    def input_size(self):
        return (self.input_bits + 7) // 8

    def eoe(self, port: int = 0):
        return self._master.eoe(self._index, port)

    def rxpdo(self, pdo_number: int, data: bytes) -> int:
        """Write one receive PDO directly to the slave."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not 0 <= pdo_number <= 0xffff:
            raise ValueError("invalid PDO number")
        if not isinstance(data, (bytes, bytearray, memoryview)) or not data:
            raise TypeError("data must be a non-empty bytes-like object")
        data = bytes(data)
        cdef const char *data_ptr = data
        cdef int data_size = len(data)
        cdef uint16_t pdo = <uint16_t>pdo_number
        cdef int result
        with nogil:
            result = ecx_RxPDO(self._master._context, self._index,
                               pdo, data_size,
                               <const void *>data_ptr)
        if result <= 0:
            raise RuntimeError("RxPDO write failed")
        return result

    def txpdo(self, pdo_number: int, size: int = 1024,
              timeout: int = 20_000) -> bytes:
        """Read one transmit PDO directly from the slave."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not 0 <= pdo_number <= 0xffff:
            raise ValueError("invalid PDO number")
        if size <= 0 or timeout <= 0:
            raise ValueError("size and timeout must be positive")
        buffer = bytearray(size)
        cdef char *buffer_ptr = buffer
        cdef int actual_size = size
        cdef int timeout_ms = timeout
        cdef uint16_t pdo = <uint16_t>pdo_number
        cdef int result
        with nogil:
            result = ecx_TxPDO(self._master._context, self._index,
                               pdo, &actual_size,
                               <void *>buffer_ptr, timeout_ms)
        if result <= 0:
            raise RuntimeError("TxPDO read failed")
        return bytes(buffer[:actual_size])

    def read_pdo_map(self, complete_access: bool = False, thread: int = 0):
        """Return PDO mapping sizes in bits, optionally using Complete Access."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        cdef uint32_t output_size = 0
        cdef uint32_t input_size = 0
        if complete_access:
            if thread < 0:
                raise ValueError("thread must be non-negative")
            result = ecx_readPDOmapCA(self._master._context, self._index,
                                      thread, &output_size, &input_size)
        else:
            result = ecx_readPDOmap(self._master._context, self._index,
                                    &output_size, &input_size)
        if result <= 0:
            raise RuntimeError("PDO map read failed")
        return {"outputs": output_size, "inputs": input_size}

    def sdo_read(self, index: int, subindex: int = 0, size: int = 1024,
                 ca: bool = False, timeout: int = 20_000, **kwargs) -> bytes:
        """Read an SDO and return its raw bytes."""
        if "complete_access" in kwargs:
            ca = kwargs.pop("complete_access")
        if kwargs:
            raise TypeError("unexpected keyword argument: %s" % next(iter(kwargs)))
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not 0 <= index <= 0xffff or not 0 <= subindex <= 0xff:
            raise ValueError("invalid SDO index or subindex")
        if size <= 0 or timeout <= 0:
            raise ValueError("size and timeout must be positive")
        buffer = bytearray(size)
        cdef int actual_size = size
        cdef char *buffer_ptr = buffer
        cdef int timeout_ms = timeout
        cdef uint16_t sdo_index = <uint16_t>index
        cdef unsigned char sdo_subindex = <unsigned char>subindex
        cdef unsigned char complete_access_flag = <unsigned char>ca
        cdef int result
        with nogil:
            result = ecx_SDOread(self._master._context, self._index,
                                 sdo_index, sdo_subindex, complete_access_flag, &actual_size,
                                 <void *>buffer_ptr, timeout_ms)
        if result <= 0:
            raise RuntimeError("SDO read failed")
        return bytes(buffer[:actual_size])

    def sdo_info(self):
        """Read the slave object dictionary as a list of dictionaries."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        cdef unsigned short index = 0
        cdef unsigned short datatype = 0
        cdef unsigned char object_code = 0
        cdef unsigned char max_sub = 0
        cdef char name[41]
        cdef int count = soemx_read_od_entry(self._master._context, self._index, -1,
                                             &index, &datatype, &object_code,
                                             &max_sub, name, 41)
        if count <= 0:
            raise RuntimeError("SDO info read failed")
        result = []
        for entry in range(count):
            soemx_read_od_entry(self._master._context, self._index, entry,
                                &index, &datatype, &object_code, &max_sub,
                                name, 41)
            result.append({"index": index, "data_type": datatype,
                           "object_code": object_code, "max_subindex": max_sub,
                           "name": bytes(name).split(b"\0", 1)[0]})
        return result

    def sdo_entries(self, object: int):
        """Read sub-entry metadata for an object dictionary entry."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if object < 0:
            raise ValueError("object must be non-negative")
        cdef unsigned char value_info = 0
        cdef unsigned short datatype = 0
        cdef unsigned short bit_length = 0
        cdef unsigned short access = 0
        cdef char name[41]
        cdef int count = soemx_read_oe_entry(self._master._context, self._index,
                                             object, -1, &value_info, &datatype,
                                             &bit_length, &access, name, 41)
        if count <= 0:
            raise RuntimeError("SDO entry info read failed")
        result = []
        for entry in range(count):
            soemx_read_oe_entry(self._master._context, self._index, object, entry,
                                &value_info, &datatype, &bit_length, &access,
                                name, 41)
            result.append({"subindex": entry, "value_info": value_info,
                           "data_type": datatype, "bit_length": bit_length,
                           "access": access,
                           "name": bytes(name).split(b"\0", 1)[0]})
        return result

    def sdo_write(self, index: int, subindex_or_data, data=None,
                  ca: bool = False, timeout: int = 20_000,
                  subindex=None, **kwargs) -> int:
        """Write raw bytes to an SDO and return SOEM's result code."""
        if "complete_access" in kwargs:
            ca = kwargs.pop("complete_access")
        if kwargs:
            raise TypeError("unexpected keyword argument: %s" % next(iter(kwargs)))
        if subindex is not None:
            if data is not None:
                raise TypeError("subindex specified twice")
            data = subindex_or_data
        elif data is None:
            data = subindex_or_data
            subindex = 0
        else:
            subindex = subindex_or_data
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not isinstance(data, (bytes, bytearray, memoryview)) or not data:
            raise TypeError("data must be a non-empty bytes-like object")
        data = bytes(data)
        if not 0 <= index <= 0xffff or not 0 <= subindex <= 0xff:
            raise ValueError("invalid SDO index or subindex")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        cdef const char *data_ptr = data
        cdef int data_size = len(data)
        cdef int timeout_ms = timeout
        cdef uint16_t sdo_index = <uint16_t>index
        cdef unsigned char sdo_subindex = <unsigned char>subindex
        cdef unsigned char complete_access_flag = <unsigned char>ca
        cdef int result
        with nogil:
            result = ecx_SDOwrite(self._master._context, self._index,
                                  sdo_index, sdo_subindex, complete_access_flag, data_size,
                                  <const void *>data_ptr, timeout_ms)
        if result <= 0:
            raise RuntimeError("SDO write failed")
        return result

    def foe_read(self, filename: str, password: int = 0, size: int = 1_048_576,
                 timeout: int = 20_000) -> bytes:
        """Read a file from the slave using FoE."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not isinstance(filename, str) or not filename:
            raise ValueError("filename must be a non-empty string")
        if password < 0 or password > 0xffffffff or size <= 0 or timeout <= 0:
            raise ValueError("invalid password, size, or timeout")
        name = filename.encode("utf-8")
        buffer = bytearray(size)
        cdef char *name_ptr = name
        cdef char *buffer_ptr = buffer
        cdef int actual_size = size
        cdef int timeout_ms = timeout
        cdef unsigned int file_password = password
        cdef int result
        with nogil:
            result = ecx_FOEread(self._master._context, self._index, name_ptr,
                                 file_password, &actual_size, <void *>buffer_ptr,
                                 timeout_ms)
        if result <= 0:
            raise RuntimeError("FoE read failed")
        return bytes(buffer[:actual_size])

    def foe_write(self, filename: str, data: bytes, password: int = 0,
                  timeout: int = 20_000) -> int:
        """Write a file to the slave using FoE."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not isinstance(filename, str) or not filename:
            raise ValueError("filename must be a non-empty string")
        if not isinstance(data, (bytes, bytearray, memoryview)) or not data:
            raise TypeError("data must be a non-empty bytes-like object")
        data = bytes(data)
        if password < 0 or password > 0xffffffff or timeout <= 0:
            raise ValueError("invalid password or timeout")
        name = filename.encode("utf-8")
        cdef char *name_ptr = name
        cdef const char *data_ptr = data
        cdef int data_size = len(data)
        cdef int timeout_ms = timeout
        cdef unsigned int file_password = password
        cdef int result
        with nogil:
            result = ecx_FOEwrite(self._master._context, self._index, name_ptr,
                                  file_password, data_size, <void *>data_ptr,
                                  timeout_ms)
        if result <= 0:
            raise RuntimeError("FoE write failed")
        return result

    def soe_read(self, idn: int, drive: int = 0, element_flags: int = 0x40,
                 size: int = 1024, timeout: int = 20_000) -> bytes:
        """Read a raw SoE IDN value."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not 0 <= idn <= 0xffff or not 0 <= drive <= 0xff:
            raise ValueError("invalid IDN or drive number")
        if size <= 0 or timeout <= 0:
            raise ValueError("size and timeout must be positive")
        buffer = bytearray(size)
        cdef char *buffer_ptr = buffer
        cdef int actual_size = size
        cdef int timeout_ms = timeout
        cdef unsigned char drive_no = <unsigned char>drive
        cdef unsigned char flags = <unsigned char>element_flags
        cdef uint16_t soe_idn = <uint16_t>idn
        cdef int result
        with nogil:
            result = ecx_SoEread(self._master._context, self._index, drive_no,
                                 flags, soe_idn, &actual_size,
                                 <void *>buffer_ptr, timeout_ms)
        if result <= 0:
            raise RuntimeError("SoE read failed")
        return bytes(buffer[:actual_size])

    def soe_idn_map(self):
        """Return mapped SoE output and input sizes in bits."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        cdef uint32_t output_size = 0
        cdef uint32_t input_size = 0
        if ecx_readIDNmap(self._master._context, self._index,
                          &output_size, &input_size) <= 0:
            raise RuntimeError("SoE IDN map read failed")
        return {"outputs": output_size, "inputs": input_size}

    def soe_write(self, idn: int, data: bytes, drive: int = 0,
                  element_flags: int = 0x40, timeout: int = 20_000) -> int:
        """Write a raw SoE IDN value."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not isinstance(data, (bytes, bytearray, memoryview)) or not data:
            raise TypeError("data must be a non-empty bytes-like object")
        data = bytes(data)
        if not 0 <= idn <= 0xffff or not 0 <= drive <= 0xff:
            raise ValueError("invalid IDN or drive number")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        cdef const char *data_ptr = data
        cdef int data_size = len(data)
        cdef int timeout_ms = timeout
        cdef unsigned char drive_no = <unsigned char>drive
        cdef unsigned char flags = <unsigned char>element_flags
        cdef uint16_t soe_idn = <uint16_t>idn
        cdef int result
        with nogil:
            result = ecx_SoEwrite(self._master._context, self._index, drive_no,
                                  flags, soe_idn, data_size,
                                  <void *>data_ptr, timeout_ms)
        if result <= 0:
            raise RuntimeError("SoE write failed")
        return result


def find_adapters():
    """Return available network adapters as ``[{name, desc}]`` dictionaries."""
    cdef ec_adaptert *node = ec_find_adapters()
    cdef ec_adaptert *current = node
    result = []
    while current != NULL:
        result.append({"name": bytes(current.name).split(b"\0", 1)[0],
                       "desc": bytes(current.desc).split(b"\0", 1)[0]})
        current = current.next
    if node != NULL:
        ec_free_adapters(node)
    return result
