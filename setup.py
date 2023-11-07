from setuptools import setup
from Cython.Build import cythonize

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


def basis_utils_extension():
    package_dir = os.path.join("src", "quspin", "extensions", "basis")

    cython_src = os.path.join(package_dir, "_basis_utils.pyx")

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

    exts = cythonize(cython_src, include_path=includes)

    for ext in exts:
        ext.include_dirs.extend(includes)
        ext.extra_compile_args.extend(extra_compile_args)

    return exts


def basis_general_core_extension():
    package_dir = os.path.join(
        "src", "quspin", "extensions", "basis", "basis_general", "_basis_general_core"
    )
    cython_src = glob.glob(os.path.join(package_dir, "*.pyx"))
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

    extra_link_args = []

    exts = cythonize(cython_src, include_path=includes)

    for ext in exts:
        ext.include_dirs.extend(includes)
        ext.extra_compile_args.extend(extra_compile_args)
        ext.extra_link_args.extend(extra_link_args)

    return exts


def basis_1d_extension():
    package_dir = os.path.join(
        "src", "quspin", "basis", "basis_1d", "extensions", "_basis_1d_core"
    )
    cython_src = glob.glob(os.path.join(package_dir, "*.pyx"))
    includes = [np.get_include()]

    exts = cythonize(cython_src, include_path=includes)

    for ext in exts:
        ext.include_dirs.extend(includes)

    return exts


def matvec_extension():
    package_dir = os.path.join("src", "quspin", "extensions", "tools", "matvec")

    subprocess.check_call(
        [sys.executable, os.path.join(package_dir, "generate_oputils.py")]
    )

    cython_src = [
        os.path.join(package_dir, "_oputils.pyx"),
    ]
    includes = [np.get_include(), os.path.join(package_dir, "_oputils")]

    exts = cythonize(cython_src, include_path=includes)

    for ext in exts:
        ext.include_dirs.extend(includes)

    return exts


def expm_multiply_parallel_core_extension():
    package_dir = os.path.join(
        "src", "quspin", "extensions", "tools", "expm_multiply_parallel_core"
    )

    subprocess.check_call(
        [sys.executable, os.path.join(package_dir, "generate_source.py")]
    )
    cython_src = [
        os.path.join(package_dir, "csr_matvec_wrapper.pyx"),
        os.path.join(package_dir, "expm_multiply_parallel_wrapper.pyx"),
    ]
    includes = [
        np.get_include(),
        os.path.join("src", "quspin", "extensions", "tools", "matvec", "_oputils"),
        os.path.join(package_dir, "source"),
    ]

    exts = cythonize(cython_src, include_path=includes)

    for ext in exts:
        ext.include_dirs.extend(includes)

    return exts


setup(
    name="quspin-extensions",
    version="0.1.0",
    author="Phillip Weinberg, Marin Bukov",
    author_email="weinbe58@gmail.com",
    description="C Extensions to the QuSpin package",
    package_dir={"": "src"},
    ext_modules=[
        # *basis_1d_extension(),
        # *matvec_extension(),
        # *expm_multiply_parallel_core_extension(),
        # *basis_general_core_extension(),
        *basis_utils_extension(),
    ],
)
