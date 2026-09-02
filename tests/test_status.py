from soemx.status import al_status_code_to_string
from soemx import ECT_COEDET_SDO, ECT_REG_SM0, ECT_REG_SM1
from soemx import Emergency
from soemx import (INIT_STATE, PREOP_STATE, SAFEOP_STATE, OP_STATE,
                   al_status_code_to_string as exported_status)
from soemx.errors import (SoemxError, SdoError, SdoInfoError, MailboxError,
                          PacketError, ConfigMapError, EepromError)
from soemx.adapters import Adapter, _decode


def test_known_al_status():
    assert al_status_code_to_string(0x0000) == "No error"


def test_unknown_al_status():
    assert "0x1234" in al_status_code_to_string(0x1234)


def test_common_pysoem_constants():
    assert ECT_COEDET_SDO == 0x01
    assert ECT_REG_SM0 == 0x0800
    assert ECT_REG_SM1 == 0x0808


def test_emergency_notification_fields():
    notification = Emergency(1, 0x1000, 0x01, 2, 3, 4)
    assert notification.slave_pos == 1
    assert notification.slave == 1
    assert notification.error_code == 0x1000
    assert notification.error_reg == 0x01
    assert notification.error_register == 0x01
    assert (notification.b1, notification.w1, notification.w2) == (2, 3, 4)


def test_package_exports_protocol_state_constants():
    assert (INIT_STATE, PREOP_STATE, SAFEOP_STATE, OP_STATE) == (1, 2, 4, 8)
    assert exported_status(0x0000) == "No error"


def test_operation_errors_share_soemx_base():
    assert issubclass(SdoError, SoemxError)


def test_emergency_string_contains_payload():
    text = str(Emergency(2, 0x1234, 0x05, 0x06, 0x0708, 0x090A))
    assert "Slave 2" in text
    assert "06,08,07,0a,09" in text


def test_error_objects_preserve_diagnostic_fields():
    sdo = SdoError(1, 0x6040, 2, 0x06090030, "invalid value")
    assert (sdo.slave_pos, sdo.index, sdo.subindex, sdo.abort_code,
            sdo.desc) == (1, 0x6040, 2, 0x06090030, "invalid value")
    assert MailboxError(1, 7, "mailbox timeout").error_code == 7
    assert PacketError(1, 2, "bad packet").message == "bad packet"
    assert ConfigMapError([sdo]).error_list == [sdo]
    assert SdoInfoError("info").message == "info"
    assert EepromError("eeprom").message == "eeprom"


def test_adapter_object_has_text_attributes():
    adapter = Adapter("eth0", "Ethernet adapter")
    assert (adapter.name, adapter.desc) == ("eth0", "Ethernet adapter")
    assert _decode(b"eth0\0ignored") == "eth0"
