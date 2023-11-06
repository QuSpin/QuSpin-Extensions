from setuptools import setup
import os
import sys
import subprocess
import numpy as np


def basis_1d_extension():
    from Cython.Build import cythonize

    package_dir = os.path.join("src", "quspin", "extensions", "_basis_1d_core")
    cython_src = [
        os.path.join(package_dir, "hcp_basis.pyx"),
        os.path.join(package_dir, "hcp_ops.pyx"),
        os.path.join(package_dir, "spf_basis.pyx"),
        os.path.join(package_dir, "spf_ops.pyx"),
        os.path.join(package_dir, "boson_basis.pyx"),
        os.path.join(package_dir, "boson_ops.pyx"),
    ]
    exts = cythonize(cython_src)

    for ext in exts:
        ext.include_dirs.append(np.get_include())

    return exts


def matvec_extension():
    from Cython.Build import cythonize

    package_dir = os.path.join("src", "quspin", "extensions", "matvec")
    
    subprocess.check_call(
        [sys.executable, os.path.join(package_dir, "generate_oputils.py")]
    )
    
    cython_src = [
        os.path.join(package_dir, "_oputils.pyx"),
    ]
    exts = cythonize(cython_src)

    includes = [np.get_include(), os.path.join(package_dir,"_oputils")]

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
        *basis_1d_extension(),
        *matvec_extension(),
    ],
)
