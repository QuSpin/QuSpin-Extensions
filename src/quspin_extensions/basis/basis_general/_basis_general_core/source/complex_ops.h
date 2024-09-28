#ifndef COMPLEX_OPS_H
#define COMPLEX_OPS_H

/*
 *  Functions to handle arithmetic operations on NumPy complex values
 */
#include <numpy/arrayobject.h>
#include <complex>

namespace basis_general
{

typedef std::complex<double> npy_cdouble_wrapper;
typedef std::complex<float> npy_cfloat_wrapper;

namespace complex_ops
{

inline npy_cdouble_wrapper exp(npy_cdouble_wrapper z){
  return std::exp(z);
}

inline npy_cfloat_wrapper exp(npy_cfloat_wrapper z){
  return std::exp(z);
}

inline npy_cdouble_wrapper conj(npy_cdouble_wrapper z){
  return std::conj(z);
}

inline npy_cfloat_wrapper conj(npy_cfloat_wrapper z){
  return std::conj(z);
} 


}


}

namespace basis_general_addition 
{

/*
 *  Functions to handle arithmetic operations on NumPy complex_wrapper values
 */

template <typename T, typename... Ts> struct result_type {
  using value_type =
      decltype(std::declval<T>() *
               std::declval<typename result_type<Ts...>::value_type>());
};

template <typename T> struct result_type<T> {
  using value_type = T;
};

template <typename... T>
using result_type_t = typename result_type<T...>::value_type;



template <class c_type> struct complex_wrapper {
  c_type _Val[2];

public:
  complex_wrapper(const c_type r = c_type(0), const c_type i = c_type(0)) {
    _Val[0] = r;
    _Val[1] = i;
  }
  template <class _c_type>
  complex_wrapper(const complex_wrapper<_c_type> &B) {
    _Val[0] = B.real();
    _Val[1] = B.imag();
  }
  /* Conversion */
  operator bool() const {
    if (_Val[0] == 0 && _Val[1] == 0) {
      return false;
    } else {
      return true;
    }
  }
  /* Operators */
  complex_wrapper operator-() const {
    return complex_wrapper(-_Val[0], -_Val[1]);
  }
  complex_wrapper conj() const { return complex_wrapper(_Val[0], -_Val[1]); }
  inline c_type real() const { return _Val[0]; }
  inline c_type imag() const { return _Val[1]; }
  /* in-place operators */
  complex_wrapper &operator+=(const complex_wrapper &B) {
    _Val[0] += B.real();
    _Val[1] += B.imag();
    return (*this);
  }
  complex_wrapper &operator-=(const complex_wrapper &B) {
    _Val[0] -= B.real();
    _Val[1] -= B.imag();
    return (*this);
  }
  complex_wrapper &operator*=(const complex_wrapper &B) {
    c_type temp = _Val[0] * B.real() - _Val[1] * B.imag();
    _Val[1] = _Val[0] * B.imag() + _Val[1] * B.real();
    _Val[0] = temp;
    return (*this);
  }
  complex_wrapper &operator/=(const complex_wrapper &B) {
    c_type denom = 1.0 / (B.real() * B.real() + B.imag() * B.imag());
    c_type temp = (_Val[0] * B.real() + _Val[1] * B.imag()) * denom;
    _Val[1] = (_Val[1] * B.real() - _Val[0] * B.imag()) * denom;
    _Val[0] = temp;
    return (*this);
  }
  /* Boolean operations */
  bool operator==(const complex_wrapper &B) const {
    return _Val[0] == B.real() && _Val[1] == B.imag();
  }
  bool operator!=(const complex_wrapper &B) const {
    return _Val[0] != B.real() || _Val[1] != B.imag();
  }
  bool operator<(const complex_wrapper &B) const {
    return (_Val[0] == B.real() ? _Val[1] < B.imag() : _Val[0] < B.real());
  }
  bool operator>(const complex_wrapper &B) const {
    return (_Val[0] == B.real() ? _Val[1] > B.imag() : _Val[0] > B.real());
  }
  bool operator<=(const complex_wrapper &B) const {
    return (_Val[0] == B.real() ? _Val[1] <= B.imag() : _Val[0] <= B.real());
  }
  bool operator>=(const complex_wrapper &B) const {
    return (_Val[0] == B.real() ? _Val[1] >= B.imag() : _Val[0] >= B.real());
  }
  template <typename T> bool operator==(const T &B) const {
    return _Val[0] == B && _Val[1] == T(0);
  }
  template <typename T> bool operator!=(const T &B) const {
    return _Val[0] != B || _Val[1] != T(0);
  }
  template <typename T> bool operator<(const T &B) const {
    return (_Val[0] == B ? _Val[1] < T(0) : _Val[0] < B);
  }
  template <typename T> bool operator>(const T &B) const {
    return (_Val[0] == B ? _Val[1] > T(0) : _Val[0] > B);
  }
  template <typename T> bool operator<=(const T &B) const {
    return (_Val[0] == B ? _Val[1] <= T(0) : _Val[0] <= B);
  }
  template <typename T> bool operator>=(const T &B) const {
    return (_Val[0] == B ? _Val[1] >= T(0) : _Val[0] >= B);
  }
  template <class _c_type>
  complex_wrapper &operator=(const complex_wrapper<_c_type> &B) {
    _Val[0] = c_type(B.real());
    _Val[1] = c_type(B.imag());
    return (*this);
  }
  template <class _c_type> complex_wrapper &operator=(const _c_type &B) {
    _Val[0] = c_type(B);
    _Val[1] = c_type(0);
    return (*this);
  }
};

typedef complex_wrapper<float> cfloat;
typedef complex_wrapper<double> cdouble;
typedef complex_wrapper<long double> cldouble;

// operator+ition

template <typename U, typename T>
complex_wrapper<result_type_t<U, T>> operator+(const U &B,
                                               const complex_wrapper<T> &A) {
  return complex_wrapper<result_type_t<U, T>>(B + A.real(), A.imag());
}

template <typename U, typename T>
complex_wrapper<result_type_t<U, T>> operator+(const complex_wrapper<T> &A,
                                               const U &B) {
  return complex_wrapper<result_type_t<U, T>>(B + A.real(), A.imag());
}

// Unary minus

template <typename U, typename T>
complex_wrapper<result_type_t<U, T>> operator-(const U &B,
                                               const complex_wrapper<T> &A) {
  return complex_wrapper<result_type_t<U, T>>(B - A.real(), -A.imag());
}

template <typename U, typename T>
complex_wrapper<result_type_t<U, T>> operator-(const complex_wrapper<T> &A,
                                               const U &B) {
  return complex_wrapper<result_type_t<U, T>>(A.real() - B, A.imag());
}

// Multiplication

template <typename T, typename U>
complex_wrapper<result_type_t<U, T>> operator*(const complex_wrapper<T> &A,
                                               const U &B) {
  return complex_wrapper<result_type_t<U, T>>(A.real() * B, A.imag() * B);
}

template <typename T, typename U>
complex_wrapper<result_type_t<U, T>> operator*(const U &B,
                                               const complex_wrapper<T> &A) {
  return complex_wrapper<result_type_t<U, T>>(B * A.real(), B * A.imag());
}

// Division

template <typename T, typename U>
complex_wrapper<result_type_t<U, T>> operator/(const U &B,
                                               const complex_wrapper<T> &A) {
  return (B * A.conj()) / (A.real() * A.real() + A.imag() * A.imag());
}

template <typename T, typename U>
complex_wrapper<result_type_t<U, T>> operator/(const complex_wrapper<T> &A,
                                               const U &B) {
  return complex_wrapper<result_type_t<U, T>>(A.real() / B, A.imag() / B);
}

template <typename U, typename T>
complex_wrapper<result_type_t<U, T>> add(const complex_wrapper<U> &B,
                                         const complex_wrapper<T> &A) {
  return complex_wrapper<result_type_t<U, T>>(B.real() + A.real(),
                                              B.imag() + A.imag());
}

template <typename U, typename T>
complex_wrapper<result_type_t<U, T>> sub(const complex_wrapper<U> &B,
                                         const complex_wrapper<T> &A) {
  return complex_wrapper<result_type_t<U, T>>(B.real() - A.real(),
                                              B.imag() - A.imag());
}

template <typename T, typename U>
complex_wrapper<result_type_t<U, T>> mul(const complex_wrapper<U> &B,
                                         const complex_wrapper<T> &A) {
  return complex_wrapper<result_type_t<U, T>>(
      B.real() * A.real() - B.imag() * A.imag(),
      B.imag() * A.real() + B.real() * A.imag());
}

template <typename T, typename U>
complex_wrapper<result_type_t<U, T>> div(const complex_wrapper<U> &B,
                                         const complex_wrapper<T> &A) {
  return (B * A.conj()) / (A.real() * A.real() + A.imag() * A.imag());
}

cfloat operator+(const cfloat &A, const cfloat &B) { return add(B, A); }
cdouble operator+(const cfloat &A, const cdouble &B) { return add(B, A); }
cdouble operator+(const cdouble &A, const cfloat &B) { return add(B, A); }
cdouble operator+(const cdouble &A, const cdouble &B) { return add(B, A); }
cldouble operator+(const cldouble &A, const cfloat &B) { return add(B, A); }
cldouble operator+(const cfloat &A, const cldouble &B) { return add(B, A); }
cldouble operator+(const cldouble &A, const cdouble &B) { return add(B, A); }
cldouble operator+(const cdouble &A, const cldouble &B) { return add(B, A); }
cldouble operator+(const cldouble &A, const cldouble &B) { return add(B, A); }

cfloat operator-(const cfloat &A, const cfloat &B) { return sub(B, A); }
cdouble operator-(const cfloat &A, const cdouble &B) { return sub(B, A); }
cdouble operator-(const cdouble &A, const cfloat &B) { return sub(B, A); }
cdouble operator-(const cdouble &A, const cdouble &B) { return sub(B, A); }
cldouble operator-(const cldouble &A, const cfloat &B) { return sub(B, A); }
cldouble operator-(const cfloat &A, const cldouble &B) { return sub(B, A); }
cldouble operator-(const cldouble &A, const cdouble &B) { return sub(B, A); }
cldouble operator-(const cdouble &A, const cldouble &B) { return sub(B, A); }
cldouble operator-(const cldouble &A, const cldouble &B) { return sub(B, A); }

cfloat operator*(const cfloat &A, const cfloat &B) { return mul(B, A); }
cdouble operator*(const cfloat &A, const cdouble &B) { return mul(B, A); }
cdouble operator*(const cdouble &A, const cfloat &B) { return mul(B, A); }
cdouble operator*(const cdouble &A, const cdouble &B) { return mul(B, A); }
cldouble operator*(const cldouble &A, const cfloat &B) { return mul(B, A); }
cldouble operator*(const cfloat &A, const cldouble &B) { return mul(B, A); }
cldouble operator*(const cldouble &A, const cdouble &B) { return mul(B, A); }
cldouble operator*(const cdouble &A, const cldouble &B) { return mul(B, A); }
cldouble operator*(const cldouble &A, const cldouble &B) { return mul(B, A); }

cfloat operator/(const cfloat &A, const cfloat &B) { return div(B, A); }
cdouble operator/(const cfloat &A, const cdouble &B) { return div(B, A); }
cdouble operator/(const cdouble &A, const cfloat &B) { return div(B, A); }
cdouble operator/(const cdouble &A, const cdouble &B) { return div(B, A); }
cldouble operator/(const cldouble &A, const cfloat &B) { return div(B, A); }
cldouble operator/(const cfloat &A, const cldouble &B) { return div(B, A); }
cldouble operator/(const cldouble &A, const cdouble &B) { return div(B, A); }
cldouble operator/(const cdouble &A, const cldouble &B) { return div(B, A); }
cldouble operator/(const cldouble &A, const cldouble &B) { return div(B, A); }

}


#endif
