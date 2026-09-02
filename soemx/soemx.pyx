from libc.stdint cimport uint16_t, uint32_t, int32_t
from libc.string cimport strlen

cdef extern from "soem/soem.h":
    ctypedef struct ecx_contextt:
        pass
    int ecx_init(ecx_contextt *context, const char *ifname)
    void ecx_close(ecx_contextt *context)
    int ecx_config_init(ecx_contextt *context)
    int ecx_config_map_group(ecx_contextt *context, void *pIOmap, unsigned char group)
    uint32_t ecx_readeeprom(ecx_contextt *context, uint16_t slave, uint16_t address, int timeout)
    int ecx_writeeeprom(ecx_contextt *context, uint16_t slave, uint16_t address,
                        uint16_t data, int timeout)
    unsigned char ecx_configdc(ecx_contextt *context)
    void ecx_dcsync0(ecx_contextt *context, uint16_t slave, unsigned char act,
                     uint32_t cycltime, int32_t cyclshift)
    int ecx_readstate(ecx_contextt *context)
    int ecx_writestate(ecx_contextt *context, uint16_t slave)
    uint16_t ecx_statecheck(ecx_contextt *context, uint16_t slave, uint16_t reqstate, int timeout)
    int ecx_send_processdata(ecx_contextt *context) noexcept nogil
    int ecx_receive_processdata(ecx_contextt *context, int timeout) noexcept nogil
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
    int ecx_EOEsend(ecx_contextt *context, uint16_t slave, unsigned char port,
                    int psize, void *p, int timeout) noexcept nogil
    int ecx_EOErecv(ecx_contextt *context, uint16_t slave, unsigned char port,
                    int *psize, void *p, int timeout) noexcept nogil

cdef extern from "soemx_native.h":
    ecx_contextt *soemx_context_create()
    void soemx_context_destroy(ecx_contextt *context)
    int soemx_slave_count(ecx_contextt *context)
    const char *soemx_slave_name(ecx_contextt *context, int slave)
    unsigned int soemx_slave_manufacturer(ecx_contextt *context, int slave)
    unsigned int soemx_slave_id(ecx_contextt *context, int slave)
    unsigned short soemx_slave_state(ecx_contextt *context, int slave)
    unsigned int soemx_slave_obits(ecx_contextt *context, int slave)
    unsigned int soemx_slave_ibits(ecx_contextt *context, int slave)
    long long soemx_dc_time(ecx_contextt *context)


cdef class Master:
    cdef ecx_contextt *_context
    cdef bint _open
    cdef object _io_map

    def __cinit__(self):
        self._context = soemx_context_create()
        if self._context == NULL:
            raise MemoryError("unable to allocate SOEM context")

    def __dealloc__(self):
        if self._context != NULL:
            if self._open:
                ecx_close(self._context)
            soemx_context_destroy(self._context)
            self._context = NULL

    def open(self, interface: str):
        if self._open:
            raise RuntimeError("master is already open")
        encoded = interface.encode("utf-8")
        if ecx_init(self._context, encoded) <= 0:
            raise OSError(f"failed to open EtherCAT interface: {interface}")
        self._open = True

    def close(self):
        if self._open:
            ecx_close(self._context)
            self._open = False

    def config_init(self) -> int:
        if not self._open:
            raise RuntimeError("master is not open")
        return ecx_config_init(self._context)

    def config_map(self, size: int = 65536, group: int = 0) -> int:
        """Map slave PDOs into an IO buffer and return mapped byte count."""
        if not self._open:
            raise RuntimeError("master is not open")
        if size <= 0 or group < 0 or group > 255:
            raise ValueError("invalid IO map size or group")
        self._io_map = bytearray(size)
        cdef char *io_ptr = self._io_map
        return ecx_config_map_group(self._context, <void *>io_ptr, <unsigned char>group)

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

    @property
    def io_map(self):
        """Return a copy of the current process-data IO map."""
        if self._io_map is None:
            raise RuntimeError("PDO map has not been configured")
        return bytes(self._io_map)

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

    def slave(self, index: int):
        if index < 1 or index > self.slave_count:
            raise IndexError("slave index out of range")
        return Slave(self, index)

    def eoe(self, slave: int, port: int = 0):
        """Return an EoE channel for a configured slave and mailbox port."""
        if not self._open:
            raise RuntimeError("master is not open")
        if slave < 1 or slave > 65535:
            raise ValueError("slave must be between 1 and 65535")
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

    def send(self, data: bytes, timeout: int = 20000) -> int:
        """Send one Ethernet frame through EoE; return SOEM's result code."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not isinstance(data, bytes):
            raise TypeError("data must be bytes")
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
    def state(self):
        return soemx_slave_state(self._master._context, self._index)

    @property
    def output_bits(self):
        return soemx_slave_obits(self._master._context, self._index)

    @property
    def input_bits(self):
        return soemx_slave_ibits(self._master._context, self._index)

    def eoe(self, port: int = 0):
        return self._master.eoe(self._index, port)

    def sdo_read(self, index: int, subindex: int = 0, size: int = 1024,
                 complete_access: bool = False, timeout: int = 20_000) -> bytes:
        """Read an SDO and return its raw bytes."""
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
        cdef unsigned char ca = <unsigned char>complete_access
        cdef int result
        with nogil:
            result = ecx_SDOread(self._master._context, self._index,
                                 sdo_index, sdo_subindex, ca, &actual_size,
                                 <void *>buffer_ptr, timeout_ms)
        if result <= 0:
            raise RuntimeError("SDO read failed")
        return bytes(buffer[:actual_size])

    def sdo_write(self, index: int, data: bytes, subindex: int = 0,
                  complete_access: bool = False, timeout: int = 20_000) -> int:
        """Write raw bytes to an SDO and return SOEM's result code."""
        if not self._master._open:
            raise RuntimeError("master is not open")
        if not isinstance(data, bytes) or not data:
            raise TypeError("data must be non-empty bytes")
        if not 0 <= index <= 0xffff or not 0 <= subindex <= 0xff:
            raise ValueError("invalid SDO index or subindex")
        if timeout <= 0:
            raise ValueError("timeout must be positive")
        cdef const char *data_ptr = data
        cdef int data_size = len(data)
        cdef int timeout_ms = timeout
        cdef uint16_t sdo_index = <uint16_t>index
        cdef unsigned char sdo_subindex = <unsigned char>subindex
        cdef unsigned char ca = <unsigned char>complete_access
        cdef int result
        with nogil:
            result = ecx_SDOwrite(self._master._context, self._index,
                                  sdo_index, sdo_subindex, ca, data_size,
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
        if not isinstance(data, bytes) or not data:
            raise TypeError("data must be non-empty bytes")
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
