from soemx.status import al_status_code_to_string
from soemx import ECT_COEDET_SDO, ECT_REG_SM0, ECT_REG_SM1


def test_known_al_status():
    assert al_status_code_to_string(0x0000) == "No error"


def test_unknown_al_status():
    assert "0x1234" in al_status_code_to_string(0x1234)


def test_common_pysoem_constants():
    assert ECT_COEDET_SDO == 0x01
    assert ECT_REG_SM0 == 0x0800
    assert ECT_REG_SM1 == 0x0808
