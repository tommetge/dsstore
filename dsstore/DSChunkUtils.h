//
//  DSChunkUtils.h
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#pragma once

static inline uint32_t DSGetUInt32(const uint8_t *b) {
    return ((uint32_t)b[0]<<24) | ((uint32_t)b[1]<<16) |
    ((uint32_t)b[2]<<8) | (uint32_t)b[3];
}

static inline int32_t DSGetInt32(const uint8_t *b) {
    return ((int32_t)b[0]<<24) | ((int32_t)b[1]<<16) |
    ((int32_t)b[2]<<8) | (int32_t)b[3];
}

static inline int64_t DSGetInt64(const uint8_t *b) {
    return ((int64_t)b[0]<<56) | ((int64_t)b[1]<<48) |
    ((int64_t)b[2]<<40) | ((int64_t)b[3]<<32) |
    ((int32_t)b[4]<<24) | ((int32_t)b[5]<<16) |
    ((int32_t)b[6]<<8) | (int32_t)b[7];
}
