from libc.stdint cimport uint16_t
from libc.string cimport strlen

cdef extern from "soem/soem.h":
    ctypedef struct ecx_contextt:
        pass
    int ecx_init(ecx_contextt *context, const char *ifname)
    void ecx_close(ecx_contextt *context)
    int ecx_config_init(ecx_contextt *context)
    int ecx_readstate(ecx_contextt *context)
    int ecx_writestate(ecx_contextt *context, uint16_t slave)
    uint16_t ecx_statecheck(ecx_contextt *context, uint16_t slave, uint16_t reqstate, int timeout)
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


cdef class Master:
    cdef ecx_contextt *_context
    cdef bint _open

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
