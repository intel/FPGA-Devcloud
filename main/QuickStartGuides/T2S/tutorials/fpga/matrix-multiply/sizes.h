#ifndef SIZES_H
#define SIZES_H

#ifdef TINY
    #define II   4
    #define JJ   4
    #define KK   4
    #define III  2
    #define JJJ  2
    #define KKK  2

    // Testing purpose only: help define the sizes of test inputs
    // matrix a: 64 * 64
    // matrix b: 64 * 64
    #define OUTERMOST_I 8
    #define OUTERMOST_J 8
    #define OUTERMOST_K 8
#endif


#ifdef SMALL
    #define II   4
    #define JJ   4
    #define KK   256
    #define III  2
    #define JJJ  4
    #define KKK  4

    // Testing purpose only: help define the sizes of test inputs
    // matrix a: 2K * 4K
    // matrix b: 4K * 2K
    #define OUTERMOST_I 256
    #define OUTERMOST_J 128
    #define OUTERMOST_K 4
#endif

#ifdef MEDIUM
    #define II   32
    #define JJ   32
    #define KK   32
    #define III  8
    #define JJJ  8
    #define KKK  8

    // Testing purpose only: help define the sizes of test inputs
    // matrix a: 2K * 4K
    // matrix b: 4K * 2K
    #define OUTERMOST_I 8
    #define OUTERMOST_J 8
    #define OUTERMOST_K 16
#endif

#ifdef LARGE
    #define II   32
    #define JJ   32
    #define KK   32
    #define III  10
    #define JJJ  8
    #define KKK  16

    // Testing purpose only: help define the sizes of test inputs
    // matrix a: 10K * 2K
    // matrix b: 2K * 8K
    #define OUTERMOST_I 32
    #define OUTERMOST_J 32
    #define OUTERMOST_K 4
#endif


#endif
