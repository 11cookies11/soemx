"""Python interface for SOEM, under active development."""

from .errors import (SoemxError, SdoError, SdoInfoError, MailboxError,
                     PacketError, ConfigMapError, EepromError, WkcError,
                     NetworkInterfaceNotOpenError)
from .status import al_status_code_to_string

NONE_STATE = 0x00
INIT_STATE = 0x01
PREOP_STATE = 0x02
BOOT_STATE = 0x03
SAFEOP_STATE = 0x04
OP_STATE = 0x08
STATE_ACK = 0x10
STATE_ERROR = 0x10

# Common EtherCAT register and CoE capability constants exposed by PySOEM.
ECT_REG_WD_DIV = 0x0400
ECT_REG_WD_TIME_PDI = 0x0410
ECT_REG_WD_TIME_PROCESSDATA = 0x0420
ECT_REG_SM0 = 0x0800
ECT_REG_SM1 = ECT_REG_SM0 + 0x08
ECT_COEDET_SDO = 0x01
ECT_COEDET_SDOINFO = 0x02
ECT_COEDET_PDOASSIGN = 0x04
ECT_COEDET_PDOCONFIG = 0x08
ECT_COEDET_UPLOAD = 0x10
ECT_COEDET_SDOCA = 0x20

__version__ = "0.1.0.dev0"


def __getattr__(name):
    if name in ("Master", "find_adapters"):
        from ._soemx import Master, find_adapters
        return Master if name == "Master" else find_adapters
    raise AttributeError(name)


def open(interface: str):
    """Open an EtherCAT master on *interface* and return it."""
    from ._soemx import Master
    master = Master()
    try:
        master.open(interface)
    except Exception:
        master.close()
        raise
    return master

__all__ = ["Master", "find_adapters", "open", "__version__", "al_status_code_to_string", "SoemxError", "SdoError", "SdoInfoError",
           "MailboxError", "PacketError", "ConfigMapError", "EepromError",
           "WkcError", "NetworkInterfaceNotOpenError", "NONE_STATE", "INIT_STATE",
           "PREOP_STATE", "BOOT_STATE", "SAFEOP_STATE", "OP_STATE",
           "STATE_ACK", "STATE_ERROR", "ECT_REG_WD_DIV", "ECT_REG_WD_TIME_PDI",
           "ECT_REG_WD_TIME_PROCESSDATA", "ECT_REG_SM0", "ECT_REG_SM1",
           "ECT_COEDET_SDO", "ECT_COEDET_SDOINFO", "ECT_COEDET_PDOASSIGN",
           "ECT_COEDET_PDOCONFIG", "ECT_COEDET_UPLOAD", "ECT_COEDET_SDOCA"]
