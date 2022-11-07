#ifndef UNITY_BUF_H
#define UNITY_BUF_H

#ifdef _WIN32
#define _CRT_SECURE_NO_WARNINGS
#define DLL_EXPORT __declspec(dllexport)
#include <windows.h>
#elif defined(__EMSCRIPTEN__)
#include <emscripten.h>
#define DLL_EXPORT EMSCRIPTEN_KEEPALIVE
#else
#define DLL_EXPORT 
#endif

#include <stdatomic.h>
#include "libavformat/url.h"

typedef struct {
    uint8_t **datas;
    size_t data_size;
    size_t *data_lengths;
    size_t count;
    const char *uri;
    int flags;
    size_t read_position;
    int clear_count;
    size_t max_count;
    atomic_flag is_lock;
} UnitybufStates;

typedef struct {
    UnitybufStates *states;
} UnitybufContext;

#endif