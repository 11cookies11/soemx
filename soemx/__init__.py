"""Python interface for SOEM, under active development."""

from ._soemx import Master

NONE_STATE = 0x00
INIT_STATE = 0x01
PREOP_STATE = 0x02
BOOT_STATE = 0x03
SAFEOP_STATE = 0x04
OP_STATE = 0x08
STATE_ACK = 0x10
STATE_ERROR = 0x10

__version__ = "0.1.0.dev0"

__all__ = ["Master", "__version__", "NONE_STATE", "INIT_STATE",
           "PREOP_STATE", "BOOT_STATE", "SAFEOP_STATE", "OP_STATE",
           "STATE_ACK", "STATE_ERROR"]
