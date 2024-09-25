from setuptools import find_packages, setup, Extension
from Cython.Build import cythonize
from typing import List
import os
import sys
import glob
import numpy as np


def boost_includes():
    if "BOOST_ROOT" in os.environ:
        path = os.environ["BOOST_ROOT"]
    else:
        path = None
        
        for root, dirs, files in os.walk("."):
            if "boost" in root and "include" in dirs:
                path = root
                break
            
        if path is None:
            raise FileNotFoundError("Could not find boost headers")
        
    include_path = os.path.join(path, "include")
    print(f"[BOOST LOG] {include_path}")
    return include_path
            
            
            


def basis_utils_extension(**kwargs) -> List[Extension]:
    package_path = ("quspin_extensions", "basis")
    package_dir = os.path.join("src", *package_path)

    includes = [
        np.get_include(),
        boost_includes(),
        os.path.join(package_dir, "_basis_utils"),
        os.path.join(package_dir, "basis_general", "_basis_general_core", "source"),
    ]

    if sys.platform == "win32":
        extra_compile_args = []
    else:
        extra_compile_args = [
            "-fno-strict-aliasing",
            "-Wno-unused-variable",
            "-Wno-unknown-pragmas",
            "-std=c++17",
        ]

    return generate_extensions(package_path, includes, extra_compile_args, **kwargs)


def basis_general_core_extension(**kwargs) -> List[Extension]:
    package_path = (
        "quspin_extensions",
        "basis",
        "basis_general",
        "_basis_general_core",
    )
    package_dir = os.path.join("src", *package_path)
    includes = [np.get_include(), os.path.join(package_dir, "source"), boost_includes()]

    if sys.platform == "win32":
        extra_compile_args = []
    else:
        extra_compile_args = [
            "-fno-strict-aliasing",
            "-Wno-unused-variable",
            "-Wno-unknown-pragmas",
            "-std=c++17",
        ]

    return generate_extensions(package_path, includes, extra_compile_args,**kwargs)


def basis_1d_extension(**kwargs) -> List[Extension]:
    package_path = ("quspin_extensions", "basis", "basis_1d", "_basis_1d_core")

    includes = [np.get_include()]

    return generate_extensions(package_path, includes, **kwargs)

def generate_extensions(package_path, includes=[], extra_compile_args=[], skip_ext=lambda x: False):
    package_dir = os.path.join("src", *package_path)
    cython_src = glob.glob(os.path.join(package_dir, "*.pyx"))

    exts = []

    for cython_file in cython_src:
        module_name = os.path.split(cython_file)[-1].replace(".pyx", "")
        module_path = ".".join(package_path + (module_name,))
        
        if "DEV_MODE" in os.environ.keys() and skip_ext(module_path):
            continue

        exts.append(
            Extension(
                module_path,
                [cython_file],
                include_dirs=includes,
                extra_compile_args=extra_compile_args,
            )
        )

    return cythonize(exts, include_path=includes)

# use this to skip certain extensions for easier local development
# e.g. here we skip all builds exccpt for the general_basis_utils
def skip_ext(module_path):
    return "general_basis_utils" not in module_path

ext_modules = [
    *basis_general_core_extension(skip_ext=skip_ext),
    *basis_1d_extension(skip_ext=skip_ext),
    *basis_utils_extension(skip_ext=skip_ext),
]

setup(
    include_package_data=True,
    packages=find_packages(where='src'),
    package_dir={'': 'src'},
    ext_modules=ext_modules,
)
