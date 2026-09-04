import soemx


def test_release_version_and_public_exports():
    assert soemx.__version__ == "0.1.1"
    expected = {
        "Master", "find_adapters", "open", "Adapter", "SoemxError",
        "SdoError", "MailboxError", "PacketError", "Emergency",
    }
    assert expected.issubset(set(soemx.__all__))


def test_adapter_repr_is_diagnostic_and_stable():
    adapter = soemx.Adapter("eth0", "Test adapter")
    assert repr(adapter) == "Adapter(name='eth0', desc='Test adapter')"


def test_emergency_accepts_zero_payload_defaults():
    notification = soemx.Emergency(1, 0x1000, 0x02)
    assert notification.b1 == notification.w1 == notification.w2 == 0
    assert "Slave 1" in str(notification)
