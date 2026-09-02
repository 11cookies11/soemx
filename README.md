# soemx

Python bindings for the [Simple Open EtherCAT Master (SOEM)](https://github.com/OpenEtherCATsociety/SOEM), implemented with Cython.

The project is intended to provide a complete, Python-friendly API for EtherCAT master operations, including EoE (Ethernet over EtherCAT), which is not currently exposed by PySOEM.

## Status

Early development. The binding API is not stable yet.

## Planned modules

- Master and slave lifecycle
- Process data (PDO)
- SDO / CoE
- EoE mailbox transport and Ethernet frame transfer
- FoE and SoE
- Distributed clocks and recovery helpers

SOEM is included under `vendor/SOEM` for development and is licensed separately. See its `LICENSE.md`.
