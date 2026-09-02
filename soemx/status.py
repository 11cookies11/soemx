_AL_STATUS = {
    0x0000: "No error",
    0x0011: "Invalid requested state change",
    0x0012: "Unknown requested state",
    0x0013: "Bootstrap not supported",
    0x0014: "No valid firmware",
    0x0015: "Invalid mailbox configuration",
    0x0016: "Invalid mailbox configuration",
    0x0017: "Invalid sync manager configuration",
    0x0018: "No valid inputs available",
    0x0019: "No valid outputs available",
    0x001A: "Synchronization error",
    0x001B: "Watchdog timeout",
}


def al_status_code_to_string(code: int) -> str:
    """Return a readable description for an EtherCAT AL status code."""
    return _AL_STATUS.get(code, f"Unknown AL status code: 0x{code:04x}")
