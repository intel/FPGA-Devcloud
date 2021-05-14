#ifndef UTIL_H
#define UTIL_H

#include "Halide.h"
#include <iostream>
#include <stdlib.h>
#include <assert.h>
#include <cmath>

using namespace Halide;
using namespace Halide::Internal;
using namespace std;

enum VALUES {
    RANDOM,
    SEQUENTIAL,
    CONSTANT
};

template<typename T, size_t N>
Buffer<T> new_data(VALUES v) {
    Buffer<T> b(N);
    for (size_t i = 0; i < N; i++) {
        if (v == VALUES::RANDOM) {
            b(i) = (T)rand();
        } else {
            b(i) = i;
        }
    }
    return b;
}

template<typename T, int N1, int N2>
Buffer<T> new_data_2d(VALUES v) {
    Buffer<T> b(N1, N2);
    for (int i = 0; i < N1; i++) {
        for (int j = 0; j < N2; j++) {
            if (v == VALUES::RANDOM) {
                b(i, j) = (T) rand() + 1;
            } else {
                // b(i, j) = (i + 1)*(j + 1) + log(i * j + 1);
                b(i, j) = i + j + 1;
            }
        }
    }
    return b;
}

template<typename T, int N1, int N2>
Buffer<T> new_data_2d_lu(VALUES v) {
    Buffer<T> b(N1, N2);
    for (int i = 0; i < N1; i++) {
        for (int j = 0; j < N2; j++) {
            if (v == VALUES::RANDOM) {
                b(i, j) = (T) rand() + 1;
            } else {
                b(i, j) = (i + 1)*(j + 1) + log(i * j + 1);
            }
        }
    }
    return b;
}

template<typename T, int N1, int N2, int N3>
Buffer<T> new_data_3d_lu(VALUES v) {
    Buffer<T> b(N1, N2, N3);
    for (int i = 0; i < N1; i++) {
        for (int j = 0; j < N2; j++) {
            for (int k = 0; k < N3; k++) {
                if (v == VALUES::RANDOM) {
                    b(i, j, k) = (T) rand();
                } else {
                    b(i, j, k) = (i + 1)*(j + 1) + log(i * j + 1);
                }
            }
        }
    }
    return b;
}

template<typename T, int N1, int N2, int N3>
Buffer<T> new_data_3d(VALUES v) {
    Buffer<T> b(N1, N2, N3);
    for (int i = 0; i < N1; i++) {
        for (int j = 0; j < N2; j++) {
            for (int k = 0; k < N3; k++) {
                if (v == VALUES::RANDOM) {
                    b(i, j, k) = (T) rand();
                } else {
                    b(i, j, k) = i + j + k;
                }
            }
        }
    }
    return b;
}

template <typename T, size_t M, size_t N>
Buffer<T> new_matrix(VALUES v) {
    Buffer<T> b(M, N);
    for (size_t i = 0; i < M; i++) {
        for (size_t j = 0; j < N; j++) {
            if (v == VALUES::RANDOM) {
                b(i, j) = (T)rand();
            }
            else {
                b(i, j) = i * N + j;
            }
        }
    }
    return b;
}

template <typename T, size_t M, size_t N, size_t P>
Buffer<T> new_data_3D(VALUES v) {
    Buffer<T> b(M, N, P);
    for (size_t i = 0; i < M; i++) {
        for (size_t j = 0; j < N; j++) {
            for (size_t p = 0; p < P; p++) {
                if (v == VALUES::RANDOM) {
                    b(i, j, p) = (T)rand();
                }
                else {
                    b(i, j, p) = i * N * P + j * P + p;
                }
            }
        }
    }
    return b;
}

template <typename T, size_t M, size_t N, size_t P, size_t Q>
Buffer<T> new_data_4D(VALUES v) {
    Buffer<T> b(M, N, P, Q);
    for (size_t i = 0; i < M; i++) {
        for (size_t j = 0; j < N; j++) {
            for (size_t p = 0; p < P; p++) {
                for (size_t q = 0; q < Q; q++) {
                    if (v == VALUES::RANDOM) {
                        b(i, j, p, q) = (T)rand();
                    }
                    else {
                        b(i, j, p, q) = i * N * P * Q + j * P * Q + p * Q + q;
                    }
                }
            }
        }
    }
    return b;
}

template <typename T, size_t M, size_t N, size_t P, size_t Q, size_t X>
Buffer<T> new_data_5D(VALUES v) {
    Buffer<T> b(M, N, P, Q, X);
    for (size_t i = 0; i < M; i++) {
        for (size_t j = 0; j < N; j++) {
            for (size_t p = 0; p < P; p++) {
                for (size_t q = 0; q < Q; q++) {
                    for (size_t x = 0; x < X; x++) {
                        if (v == VALUES::RANDOM) {
                            b(i, j, p, q, x) = (T)rand();
                        }
                        else {
                            b(i, j, p, q, x) = i * N * P * Q * X +
                                               j * P * Q * X +
                                               p * Q * X +
                                               q * X +
                                               x;
                        }
                    }
                }
            }
        }
    }
    return b;
}

template <typename T, size_t M, size_t N, size_t P, size_t Q, size_t X, size_t Y>
Buffer<T> new_data_6D(VALUES v) {
    Buffer<T> b(M, N, P, Q, X, Y);
    for (size_t i = 0; i < M; i++) {
        for (size_t j = 0; j < N; j++) {
            for (size_t p = 0; p < P; p++) {
                for (size_t q = 0; q < Q; q++) {
                    for (size_t x = 0; x < X; x++) {
                        for (size_t y = 0; y < Y; y++) {
                            if (v == VALUES::RANDOM) {
                                b(i, j, p, q, x, y) = (T)rand();
                            } else
                            if (v == VALUES::CONSTANT) {
                                b(i, j, p, q, x, y) = (T)1;
                            } else {
                                b(i, j, p, q, x, y) = i * N * P * Q * X * Y +
                                                      j * P * Q * X * Y +
                                                      p * Q * X * Y +
                                                      q * X * Y +
                                                      x * Y;
                            }
                        }
                    }
                }
            }
        }
    }
    return b;
}

template <typename T>
void check_equal(const Buffer<T> &a, const Buffer<T> &b) {
    assert(a.number_of_elements() == b.number_of_elements());
    a.for_each_element([&](int x) {
#ifdef VERBOSE_DEBUG
        cout << a(x) << ", " << b(x) << "\n";
#endif
        assert(a(x) == b(x));
    });
}

template <typename T>
void check_equal_2D(const Buffer<T> &a, const Buffer<T> &b) {
    assert(a.number_of_elements() == b.number_of_elements());
    int line_number = a.width();
    a.for_each_element([&](int x, int y) {
#ifdef VERBOSE_DEBUG
        cout << a(x, y) << ", " << b(x, y) << " ";
        if (x == line_number - 1)
            cout << std::endl;
#endif
        assert(a(x, y) == b(x, y));
    });
}

template <typename T>
void check_equal_3D(const Buffer<T> &a, const Buffer<T> &b) {
    assert(a.number_of_elements() == b.number_of_elements());
    int width = a.width(), height = a.height();
    a.for_each_element([&](int x, int y, int z) {
#ifdef VERBOSE_DEBUG
        cout << a(x, y, z) << ", " << b(x, y, z) << " ";
        if (x == width - 1){
            cout << std::endl;
            if (y == height - 1)
                cout << std::endl;
        }
#endif
        assert(a(x, y, z) == b(x, y, z));
    });
}

template <typename T>
void check_equal_4D(const Buffer<T> &a, const Buffer<T> &b) {
    assert(a.number_of_elements() == b.number_of_elements());
    int width = a.width(), height = a.height(), channel = a.channels();
    a.for_each_element([&](int x, int y, int z, int w) {
#ifdef VERBOSE_DEBUG
        cout << a(x, y, z, w) << ", " << b(x, y, z, w) << " ";
        if (x == width - 1) {
            cout << std::endl;
            if (y == height - 1) {
                cout << std::endl;
                if (z == channel - 1)
                    cout << std::endl;
            }
        }
#endif
        assert(a(x, y, z, w) == b(x, y, z, w));
});
}

template <typename T>
void check_equal_5D(const Buffer<T> &a, const Buffer<T> &b) {
    assert(a.number_of_elements() == b.number_of_elements());
    int width = a.width(), height = a.height(), channel = a.channels();
    a.for_each_element([&](int x, int y, int z, int w, int u) {
#ifdef VERBOSE_DEBUG
        cout << "(" << x << ", " << y << ", " << z << ", " << w << ", " << u << ") = " << a(x, y, z, w, u) << ", " << b(x, y, z, w, u) << "\n";
        if (x == width - 1) {
            cout << std::endl;
            if (y == height - 1) {
                cout << std::endl;
                if (z == channel - 1)
                    cout << std::endl;
            }
        }
#endif
        assert(a(x, y, z, w, u) == b(x, y, z, w, u));
    });
}

template <typename T>
void check_equal_6D(const Buffer<T> &a, const Buffer<T> &b) {
    assert(a.number_of_elements() == b.number_of_elements());
    int width = a.width(), height = a.height(), channel = a.channels();
    a.for_each_element([&](int x, int y, int z, int w, int u, int v) {
#ifdef VERBOSE_DEBUG
        cout << "(" << x << ", " << y << ", " << z << ", " << w << ", " << u << ", " << v << ") = " << a(x, y, z, w, u, v) << ", " << b(x, y, z, w, u, v) << "\n";
        if (x == width - 1) {
            cout << std::endl;
            if (y == height - 1) {
                cout << std::endl;
                if (z == channel - 1)
                    cout << std::endl;
            }
        }
#endif
        assert(a(x, y, z, w, u, v) == b(x, y, z, w, u, v));
    });
}

template <typename T>
class CheckHelper {
 public:
    const Buffer<T>& a;
    const Buffer<T>& b;
    CheckHelper(const Buffer<T>& a, const Buffer<T> &b) : a(a), b(b) {}
    template<typename... Args>
    void operator() (Args... args) {
#ifdef VERBOSE_DEBUG
        cout << a(args...) << ", " << b(args...) << "\n";
#endif
        assert(a(args...) == b(args...));
    }
};

template <typename T>
class EqualHelper {
 public:
    bool equal;
    const Buffer<T>& a;
    const Buffer<T>& b;
    EqualHelper(const Buffer<T>& a, const Buffer<T>& b) : a(a), b(b) {
        equal = false;
    }
    // template<typename... Args>
    // void operator() (Args... args) {
    //     equal &= (a(args...) == b(args...));
    // } 
    void operator() (int x) {
        equal &= (a(x) == b(x));
    }
};

template <typename T>
void check_equal_ND(const Buffer<T> &a, const Buffer<T> &b) {
    CheckHelper<T> helper = CheckHelper<T>(a, b);
    assert(a.number_of_elements() == b.number_of_elements());
    a.for_each_element(helper);
}

template <typename T>
bool buffer_equal(const Buffer<T> &a, const Buffer<T> &b) {
    if (!(a.number_of_elements() == b.number_of_elements())) {
        return false;
    }
    EqualHelper<T> helper = EqualHelper<T>(a, b);
    a.for_each_element(helper);
    return helper.equal;
}

template<typename T, int N1, int N2>
Buffer<T> get_result_of_simple_case1() {
    Buffer<T> b(N1, N2);
    for (int i = 0; i < N1; i++) {
        for (int j = 0; j < N2; j++) {
            b(i, j) = (T) (i + j - 1); // (j > 0 ? i + j - 1 : i + j);
        }
    }
    return b;
}

template<typename T, int N1, int N2>
Buffer<T> get_result_of_simple_case2() {
    Buffer<T> b(N1, N2);
    for (int i = 0; i < N1; i++) {
        for (int j = 0; j < N2; j++) {
            b(i, j) = (T) (i + j); // (j > 0 ? i + j - 1 : i + j);
        }
    }
    return b;
}

template<typename T, int N1, int N2, int N3>
Buffer<T> get_result_of_mm(const Buffer<T> &a, const Buffer<T> &b) {
    Buffer<T> c(N1, N2);
    for (int i = 0; i < N1; i++) {
        for (int j = 0; j < N2; j++) {
            c(i, j) = 0;
            for (int k = 0; k < N3; k++) {
                c(i, j) += (T) a(i, k) * b(k, j);
            }
        }
    }
    return c;
}

template<typename T, int N1, int N2, int N3>
Buffer<T> get_result_of_mm2(const Buffer<T> &a, const Buffer<T> &b) {
    Buffer<T> c(N1, N2);
    for (int i = 0; i < N1; i++) {
        for (int j = 0; j < N2; j++) {
            c(i, j) = 0;
            for (int k = 0; k < N3; k++) {
                c(i, j) += (T) a(k, i) * b(k, j);
            }
        }
    }
    return c;
}

template<typename T, int L, int I, int J, int K>
Buffer<T> get_result_of_tmm(const Buffer<T> &a, const Buffer<T> &b) {
    Buffer<T> c(I, J, K);
    for (int i = 0; i < I; i++) {
        for (int j = 0; j < J; j++) {
            for (int k = 0; k < K; k++) {
                c(i, j, k) = 0;
                for (int l = 0; l < L; l++) {
                    c(i, j, k) += (T) a(l, i, j) * b(l, k);
                }
            }
        }
    }
    return c;
}

template<typename T, int I, int O, int R, int C, int P, int Q>
Buffer<T> get_result_of_conv(const Buffer<T> &a, const Buffer<T> &b) {
    Buffer<T> d(O, R, C);
    for (int o = 0; o < O; o++) {
        for (int r = 0; r < R; r++) {
            for (int c = 0; c < C; c++) {
                d(o, r, c) = 0;
                for (int i = 0; i < I; i++) {
                    for (int p = 0; p < P; p++) {
                        for (int q = 0; q < Q; q++) {
                            d(o, r, c) += (T) a(i, p+r, c+q) * b(i, o, p, q);
                        }
                    }
                }
            }
        }
    }
    return d;
}

template<typename T, int L, int I, int J, int K>
Buffer<T> get_result_of_mttkrp(const Buffer<T> &a, const Buffer<T> &b, const Buffer<T> &c) {
    Buffer<T> d(I, J);
    Buffer<T> e(I, J, K);
    for (int i = 0; i < K; i++) {
        for (int j = 0; j < J; j++) {
            d(i, j) = 0;
            for (int k = 0; k < K; k++) {
                e(i, j, k) = 0;
                for (int l = 0; l < L; l++) {
                    e(i, j, k) += (T) a(l, i, k) * c(l, j);
                }
                d(i, j) += (T) e(i, j, k) * b(k, j);
            }
        }
    }
    return d;
}

template<typename T, int N1, int N2, int N3>
Buffer<T> extract_result_of_mm(const Buffer<T> &a) {
    Buffer<T> b(N1, N2);
    for (int i = 0; i < N1; i++) {
        for (int j = 0; j < N2; j++) {
            b(i, j) = a(i, j, N3 - 1);
        }
    }
    return b;
}

void print_type(const Expr *op) {
    if (op->as<StringImm>()) {
        printf("is string\n");
    } else if (op->as<IntImm>()) {
        printf("is int\n");
    } else if (op->as<FloatImm>()) {
        printf("is float\n");
    } else if (op->as<Cast>()) {
        printf("is cast\n");
    } else if (op->as<Add>()) {
        printf("is add\n");
    } else if (op->as<Sub>()) {
        printf("is sub\n");
    } else if (op->as<Mul>()) {
        printf("is mul\n");
    } else if (op->as<Div>()) {
        printf("is div\n");
    } else if (op->as<Call>()) {
        printf("is call\n");
    } else if (op->as<Select>()) {
        printf("is select\n");
    } else if (op->as<Shuffle>()) {
        printf("is shuffle\n");
    } else if (op->as<Ramp>()) {
        printf("is ramp\n");
    } else if (op->as<Load>()) {
        printf("is load\n");
    } else if (op->as<Store>()) {
        printf("is store\n");
    } else if (op->as<Broadcast>()) {
        printf("is broadcast\n");
    } else if (op->as<Let>()) {
        printf("is let\n");
    } else if (op->as<Variable>()) {
        printf("is variable\n");
    } else {
        printf("don't know this ir\n");
    }
}

#endif

