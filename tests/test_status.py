from soemx.status import al_status_code_to_string
from soemx import ECT_COEDET_SDO, ECT_REG_SM0, ECT_REG_SM1
from soemx import Emergency
from soemx import (INIT_STATE, PREOP_STATE, SAFEOP_STATE, OP_STATE,
                   al_status_code_to_string as exported_status)
from soemx.errors import SoemxError, SdoError


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
