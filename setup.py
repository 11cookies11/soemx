from pathlib import Path
from setuptools import Extension, setup
from Cython.Build import cythonize

root = Path(__file__).parent
soem = root / "vendor" / "SOEM"
sources = [str(root / "soemx" / "soemx.pyx"), str(root / "soemx" / "soemx_native.c")]
sources += [str(soem / "src" / name) for name in [
    "ec_base.c", "ec_coe.c", "ec_config.c", "ec_dc.c", "ec_eoe.c",
    "ec_foe.c", "ec_main.c", "ec_print.c", "ec_soe.c"]]
sources += [str(soem / "osal" / "win32" / "osal.c"), str(soem / "oshw" / "win32" / "nicdrv.c"), str(soem / "oshw" / "win32" / "oshw.c")]

extension = Extension(
    "soemx._soemx",
    sources=sources,
    include_dirs=[str(soem / "include"), str(soem / "osal"), str(soem / "osal" / "win32"), str(soem / "oshw" / "win32"), str(soem / "oshw" / "win32" / "wpcap" / "Include"), str(root / "soemx")],
    library_dirs=[str(soem / "oshw" / "win32" / "wpcap" / "Lib" / "x64")],
    libraries=["wpcap", "Packet"],
)

setup(ext_modules=cythonize([extension], language_level=3))
