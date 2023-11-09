from setuptools import find_namespace_packages, setup, Extension
from Cython.Build import cythonize
from typing import List
import os
import sys
import glob
import subprocess
import numpy as np


def boost_includes():
    if "BOOST_INCLUDES" in os.environ:
        return os.environ["BOOST_INCLUDES"]
    else:
        from sysconfig import get_paths

        data_path = get_paths()["data"]

        if sys.platform == "win32":
            python_includes = os.path.join(data_path, "Library", "include")
        else:
            python_includes = os.path.join(data_path, "include")

        if "boost" in os.listdir(python_includes):
            return os.path.join(python_includes, "boost")
        else:
            raise ValueError(
                f"No boost directory found in {python_includes} and no value "
                "set for BOOST_INCLUDES environment variable."
            )


def basis_utils_extension() -> List[Extension]:
    package_path = ("quspin", "extensions", "basis")
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
            "-std=c++11",
        ]

    return generate_extensions(package_path, includes, extra_compile_args)


def basis_general_core_extension() -> List[Extension]:
    package_path = (
        "quspin",
        "extensions",
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
            "-std=c++11",
        ]

    return generate_extensions(package_path, includes, extra_compile_args)


def basis_1d_extension() -> List[Extension]:
    package_path = ("quspin", "basis", "basis_1d", "extensions", "_basis_1d_core")

    includes = [np.get_include()]

    return generate_extensions(package_path, includes)


def matvec_extension() -> List[Extension]:
    package_path = ("quspin", "extensions", "tools", "matvec")
    package_dir = os.path.join("src", *package_path)

    subprocess.check_call(
        [sys.executable, os.path.join(package_dir, "generate_oputils.py")]
    )

    includes = [
        np.get_include(),
        os.path.join("src", "quspin", "extensions", "tools", "matvec", "_oputils"),
    ]

    return generate_extensions(package_path, includes)


def expm_multiply_parallel_core_extension() -> List[Extension]:
    package_path = ("quspin", "extensions", "tools", "expm_multiply_parallel_core")
    package_dir = os.path.join("src", *package_path)

    subprocess.check_call(
        [sys.executable, os.path.join(package_dir, "generate_source.py")]
    )

    includes = [
        np.get_include(),
        os.path.join("src", "quspin", "extensions", "tools", "matvec", "_oputils"),
        os.path.join(package_dir, "source"),
    ]

    return generate_extensions(package_path, includes)


def generate_extensions(package_path, includes=[], extra_compile_args=[]):
    package_dir = os.path.join("src", *package_path)
    cython_src = glob.glob(os.path.join(package_dir, "*.pyx"))

    exts = []

    for cython_file in cython_src:
        module_name = os.path.split(cython_file)[-1].replace(".pyx", "")
        module_path = ".".join(package_path + (module_name,))

        exts.append(
            Extension(
                module_path,
                [cython_file],
                include_dirs=includes,
                extra_compile_args=extra_compile_args,
            )
        )

    return cythonize(exts, include_path=includes)


ext_modules = [
    *matvec_extension(),
    *expm_multiply_parallel_core_extension(),
    # *basis_1d_extension(),
    # *basis_general_core_extension(),
    # *basis_utils_extension(),
]
setup(
    include_package_data=True,
    packages=find_namespace_packages(where='src'),
    package_dir={'': 'src'},
    ext_modules=ext_modules,
)
