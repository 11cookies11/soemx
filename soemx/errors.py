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
