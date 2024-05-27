#!python
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True
# cython: language_level=2
# distutils: language=c++



cimport numpy as _np
from libc.math cimport sin,cos,sqrt

from types cimport *


import numpy as _np
#from scipy.misc import comb
from scipy.special import comb




include "sources/hcp_bitops.pyx"
include "sources/refstate.pyx"
include "sources/op_templates.pyx"
include "sources/hcp_ops.pyx"

