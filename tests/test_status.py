from soemx.status import al_status_code_to_string


def test_known_al_status():
    assert al_status_code_to_string(0x0000) == "No error"


def test_unknown_al_status():
    assert "0x1234" in al_status_code_to_string(0x1234)
