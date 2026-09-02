class SoemxError(Exception):
    """Base class for soemx errors."""


class SdoError(SoemxError):
    def __init__(self, slave_pos=None, index=None, subindex=None,
                 abort_code=None, desc=""):
        self.slave_pos = slave_pos
        self.index = index
        self.subindex = subindex
        self.abort_code = abort_code
        self.desc = desc
        super().__init__(desc)


class SdoInfoError(SoemxError):
    def __init__(self, message=""):
        self.message = message
        super().__init__(message)


class MailboxError(SoemxError):
    def __init__(self, slave_pos=None, error_code=None, desc=""):
        self.slave_pos = slave_pos
        self.error_code = error_code
        self.desc = desc
        super().__init__(desc)


class PacketError(SoemxError):
    def __init__(self, slave_pos=None, error_code=None, message="", desc=""):
        self.slave_pos = slave_pos
        self.error_code = error_code
        self.message = message
        self.desc = desc
        super().__init__(message or desc)


class ConfigMapError(SoemxError):
    def __init__(self, error_list=None):
        self.error_list = [] if error_list is None else list(error_list)
        super().__init__(self.error_list)


class EepromError(SoemxError):
    def __init__(self, message=""):
        self.message = message
        super().__init__(message)


class WkcError(SoemxError): pass
class NetworkInterfaceNotOpenError(SoemxError): pass


class Emergency(SoemxError):
    """Emergency mailbox notification compatible with PySOEM."""

    def __init__(self, slave, error_code, error_reg, b1=0, w1=0, w2=0):
        self.slave_pos = slave
        self.slave = slave
        self.error_code = error_code
        self.error_reg = error_reg
        self.error_register = error_reg
        self.b1 = b1
        self.w1 = w1
        self.w2 = w2

    def __repr__(self):
        return (f"Emergency(slave_pos={self.slave_pos}, error_code={self.error_code}, "
                f"error_reg={self.error_reg})")

    def __str__(self):
        payload = bytes([self.b1]) + self.w1.to_bytes(2, "little") + self.w2.to_bytes(2, "little")
        return (f"Slave {self.slave_pos}: {self.error_code:04x}, "
                f"{self.error_reg:02x}, ({','.join(f'{x:02x}' for x in payload)})")
