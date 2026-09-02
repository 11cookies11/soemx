from pathlib import Path
import os
import sys
from setuptools import Extension, setup
from Cython.Build import cythonize

root = Path(__file__).parent.resolve()
soem = root / "vendor" / "SOEM"
sources = ["soemx/soemx.pyx", "soemx/soemx_native.c"]
sources += [f"vendor/SOEM/src/{name}" for name in [
    "ec_base.c", "ec_coe.c", "ec_config.c", "ec_dc.c", "ec_eoe.c",
    "ec_foe.c", "ec_main.c", "ec_print.c", "ec_soe.c"]]
if sys.platform == "win32":
    platform_sources = [
        "vendor/SOEM/osal/win32/osal.c",
        "vendor/SOEM/oshw/win32/nicdrv.c",
        "vendor/SOEM/oshw/win32/oshw.c",
    ]
    platform_includes = [
        soem / "osal" / "win32",
        soem / "oshw" / "win32",
        soem / "oshw" / "win32" / "wpcap" / "Include",
    ]
    platform_libraries = ["wpcap", "Packet", "winmm", "ws2_32"]
    platform_library_dirs = [soem / "oshw" / "win32" / "wpcap" / "Lib" / "x64"]
elif sys.platform.startswith("linux"):
    platform_sources = [
        "vendor/SOEM/osal/linux/osal.c",
        "vendor/SOEM/oshw/linux/nicdrv.c",
        "vendor/SOEM/oshw/linux/oshw.c",
    ]
    platform_includes = [soem / "osal" / "linux", soem / "oshw" / "linux"]
    platform_libraries = ["pcap", "pthread"]
    platform_library_dirs = []
else:
    raise RuntimeError("soemx currently supports Windows and Linux builds")
sources += platform_sources
# setuptools requires source entries to be relative to setup.py.  The vendored
# SOEM paths are normalized to POSIX separators for manifest generation.
sources = [path.replace("\\", "/") for path in sources]

extension = Extension(
    "soemx._soemx",
    sources=sources,
    include_dirs=[str(soem / "include"), str(soem / "build" / "include"), str(soem / "osal"), *(str(path) for path in platform_includes), str(root / "soemx")],
    library_dirs=[str(path) for path in platform_library_dirs],
    libraries=platform_libraries,
)

extensions = cythonize([extension], language_level=3)
for ext in extensions:
    ext.sources = [os.path.relpath(source, root).replace("\\", "/")
                   for source in ext.sources]

setup(
    ext_modules=extensions,
    include_package_data=False,
    exclude_package_data={"soemx": ["*.c", "*.h"]},
)
