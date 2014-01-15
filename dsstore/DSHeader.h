//
//  DSHeader.h
//  dsstore
//
//  Created by Thomas Metge on 1/15/14.
//  Copyright (c) 2014 Flying Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSAllocator.h"

@interface DSHeader : NSObject

// The following apear in order in the first 36 bytes of
// the .DS_Store file
@property (nonatomic, assign)   int   version;          // 4 bytes
@property (nonatomic, assign)   int   magic;            // 4 bytes
@property (nonatomic, assign)   int   allocator_offset; // 4 bytes
@property (nonatomic, assign)   int   allocator_size;   // 4 bytes
@property (nonatomic, readonly) char* filler;           // 16 bytes (unknown)
@property (nonatomic, retain)   DSAllocator* allocator;

- (instancetype)init;

- (BOOL)parseData:(NSData*)data withError:(NSError**)err;

@end
