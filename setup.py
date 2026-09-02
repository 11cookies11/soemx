from pathlib import Path
import os
from setuptools import Extension, setup
from Cython.Build import cythonize

root = Path(__file__).parent.resolve()
soem = root / "vendor" / "SOEM"
sources = ["soemx/soemx.pyx", "soemx/soemx_native.c"]
sources += [f"vendor/SOEM/src/{name}" for name in [
    "ec_base.c", "ec_coe.c", "ec_config.c", "ec_dc.c", "ec_eoe.c",
    "ec_foe.c", "ec_main.c", "ec_print.c", "ec_soe.c"]]
sources += ["vendor/SOEM/osal/win32/osal.c", "vendor/SOEM/oshw/win32/nicdrv.c", "vendor/SOEM/oshw/win32/oshw.c"]
# setuptools requires source entries to be relative to setup.py.  The vendored
# SOEM paths are normalized to POSIX separators for manifest generation.
sources = [path.replace("\\", "/") for path in sources]

extension = Extension(
    "soemx._soemx",
    sources=sources,
    include_dirs=[str(soem / "include"), str(soem / "build" / "include"), str(soem / "osal"), str(soem / "osal" / "win32"), str(soem / "oshw" / "win32"), str(soem / "oshw" / "win32" / "wpcap" / "Include"), str(root / "soemx")],
    library_dirs=[str(soem / "oshw" / "win32" / "wpcap" / "Lib" / "x64")],
    libraries=["wpcap", "Packet", "winmm", "ws2_32"],
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
