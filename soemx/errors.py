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

    def __init__(self, slave, error_code, error_register, b1=0, w1=0, w2=0):
        self.slave = slave
        self.error_code = error_code
        self.error_register = error_register
        self.b1 = b1
        self.w1 = w1
        self.w2 = w2

    def __repr__(self):
        return (f"Emergency(slave={self.slave}, error_code={self.error_code}, "
                f"error_register={self.error_register})")
