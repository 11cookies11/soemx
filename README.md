# soemx

[![CI](https://github.com/11cookies11/soemx/actions/workflows/ci.yml/badge.svg)](https://github.com/11cookies11/soemx/actions/workflows/ci.yml)
[![PyPI](https://img.shields.io/pypi/v/soemx.svg)](https://pypi.org/project/soemx/)
[![Python](https://img.shields.io/pypi/pyversions/soemx.svg)](https://pypi.org/project/soemx/)

`soemx` 是一个面向个人项目和工业自动化实验的 SOEM Python 封装，使用
Cython 将 SOEM 2.x 的 EtherCAT Master 能力暴露给 Python，并额外提供 EoE
（Ethernet over EtherCAT）接口。

项目仍在积极开发中，API 可能发生变化。没有 EtherCAT 硬件时，可以运行构建
和单元测试；真实的 PDO、Mailbox 和 EoE 通信需要兼容的网卡和从站设备。

Python bindings for the [Simple Open EtherCAT Master (SOEM)](https://github.com/OpenEtherCATsociety/SOEM), implemented with Cython.

The project is intended to provide a complete, Python-friendly API for EtherCAT master operations, including EoE (Ethernet over EtherCAT), which is not currently exposed by PySOEM.

## Installation

```powershell
python -m pip install soemx
```

当前 PyPI 提供 `0.1.0` 正式版本。没有对应平台 wheel 时，pip 会从源码构建扩展，
因此 Linux 需要 C 编译器、Cython 和 `libpcap-dev`；Windows 需要 Visual Studio
C++ 构建工具以及运行时使用的 Npcap（WinPcap API 兼容模式）。

## Current API

The Cython extension currently provides:

- `Master.open()` / `close()` and context-manager support, including optional redundancy
- `find_adapters()` returning `Adapter` objects with `name` and `desc` attributes
- slave discovery, state control, AL diagnostics and EEPROM access
- mapped process data through `Master.io_map`, `Slave.inputs` and `Slave.outputs`
- cyclic and grouped process-data exchange, one-shot `exchange_processdata()` /
  `exchange_processdata_group()`, direct `rxpdo()` / `txpdo()` access
- actual PDO map length through `Master.mapped_size`, plus writable memory views
- SDO / CoE, SDO information discovery, FoE and SoE
- configurable default SDO read/write timeouts through `Master`
- consistent GIL release for blocking native operations through
  `Master.always_release_gil` and `Master.check_release_gil()`
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
Raw records from `pop_error()` retain the associated register and auxiliary
word fields for diagnostics.

## Build and runtime

Build the extension on Windows with Visual Studio and Cython:

```powershell
python setup.py build_ext --inplace
python -m pytest -q
```

Linux builds use SOEM's raw-socket backend and require the system `libpcap`
development package and a compiler.

The Windows backend links against Npcap/WinPcap's `wpcap.dll` and `Packet.dll`.
These DLLs are required when opening a network adapter, but pure Python modules
and the test suite can be used without EtherCAT hardware or the packet runtime.

Physical EtherCAT, PDO, mailbox and EoE behavior still requires a compatible
network adapter and at least one EtherCAT slave.

## Minimal EoE example

```python
import soemx

for adapter in soemx.find_adapters():
    print(adapter.name, adapter.desc)

with soemx.open("YOUR_INTERFACE") as master:
    if master.config_init() <= 0:
        raise RuntimeError("no EtherCAT slaves found")
    channel = master.slaves[0].eoe()
    channel.set_ip(b"192.168.1.20", b"255.255.255.0", b"192.168.1.1")
    ethernet_frame = b"replace with a complete Ethernet frame"
    channel.send(ethernet_frame)
    frame = channel.receive()
```

The example requires an EoE-capable slave and a WinPcap-compatible Npcap
installation on Windows (or the Linux packet-capture development package).

SOEM is included under `vendor/SOEM` for development and is licensed separately. See its `LICENSE.md`.
