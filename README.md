# soemx

Python bindings for the [Simple Open EtherCAT Master (SOEM)](https://github.com/OpenEtherCATsociety/SOEM), implemented with Cython.

The project is intended to provide a complete, Python-friendly API for EtherCAT master operations, including EoE (Ethernet over EtherCAT), which is not currently exposed by PySOEM.

## Current API

The Cython extension currently provides:

- `Master.open()` / `close()` and context-manager support
- slave discovery, state control, AL diagnostics and EEPROM access
- mapped process data through `Master.io_map`, `Slave.inputs` and `Slave.outputs`
- cyclic and grouped process-data exchange, one-shot `exchange_processdata()` /
  `exchange_processdata_group()`, direct `rxpdo()` / `txpdo()` access
- actual PDO map length through `Master.mapped_size`, plus writable memory views
- SDO / CoE, SDO information discovery, FoE and SoE
- configurable default SDO read/write timeouts through `Master`
- EoE frame send/receive and raw mailbox transport
- distributed clocks, DC sync0, overlap/packed mapping and queued errors
- parsed slave mailbox parameters (`mailbox_out_address`, `mailbox_out_size`,
  `mailbox_in_address`, `mailbox_in_size`) for diagnostics
- mailbox layout updates through `Slave.amend_mbx()` before mailbox use

PySOEM is used as a practical API reference, but `soemx` is free to improve the
interface where a clearer or safer design is possible. Raw byte-oriented methods
are used where Python cannot know a device's object data type. In addition to
normal slave-indexed EEPROM access, the master exposes direct AP and FP EEPROM
operations for diagnostics.

EoE channels accept any bytes-like frame buffer and expose IPv4 configuration
through `set_ip()` / `get_ip()`. Emergency mailbox notifications are delivered
as structured `Emergency` objects through Master-level or per-slave callbacks.

## Build and runtime

Build the extension on Windows with Visual Studio and Cython:

```powershell
python setup.py build_ext --inplace
python -m pytest -q
```

The Windows backend links against Npcap/WinPcap's `wpcap.dll` and `Packet.dll`.
These DLLs are required when opening a network adapter, but pure Python modules
and the test suite can be used without EtherCAT hardware or the packet runtime.

Physical EtherCAT, PDO, mailbox and EoE behavior still requires a compatible
network adapter and at least one EtherCAT slave.

SOEM is included under `vendor/SOEM` for development and is licensed separately. See its `LICENSE.md`.
