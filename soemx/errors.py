class SoemxError(Exception):
    """Base class for soemx errors."""


class SdoError(SoemxError): pass
class SdoInfoError(SoemxError): pass
class MailboxError(SoemxError): pass
class PacketError(SoemxError): pass
class ConfigMapError(SoemxError): pass
class EepromError(SoemxError): pass
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
