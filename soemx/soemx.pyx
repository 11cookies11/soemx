from libc.stdint cimport uint16_t

cdef extern from "soem/soem.h":
    ctypedef struct ecx_contextt:
        pass
    int ecx_init(ecx_contextt *context, const char *ifname)
    void ecx_close(ecx_contextt *context)
    int ecx_config_init(ecx_contextt *context)

cdef extern from "soemx_native.h":
    ecx_contextt *soemx_context_create()
    void soemx_context_destroy(ecx_contextt *context)


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
