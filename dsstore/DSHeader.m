//
//  DSHeader.m
//  dsstore
//
//  Created by Thomas Metge on 1/15/14.
//  Copyright (c) 2014 Flying Paper Software. All rights reserved.
//

#import "DSHeader.h"
#import "DSAllocator.h"
#import "DSChunkUtils.h"

// 36 byte header

@implementation DSHeader

@synthesize version, magic, allocator_offset, allocator_size, filler;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.version = 1;
        self.magic = 'Bud1';
        self.allocator_offset = 0;
        self.allocator_size = 0;
        self.allocator = [[[DSAllocator alloc] init] autorelease];
    }
    return self;
}

- (BOOL)parseData:(NSData*)data withError:(NSError**)err {
    if ([data length] < 36) {  // Invalid file or incomplete header
        if (err) {
            *err = [NSError errorWithDomain:@"com.flyingpaper.dsstore"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey: @"Invalid data (size)"}];
        }
        return NO;
    }

    self.version = DSGetUInt32([data bytes]);
    self.magic = DSGetUInt32([data bytes] + 4);
    self.allocator_offset = DSGetUInt32([data bytes] + 8);
    self.allocator_size = DSGetUInt32([data bytes] + 12);

    // Sanity checks
    if (self.version != 1) {  // Version never changes
        if (err) {
            *err = [NSError errorWithDomain:@"com.flyingpaper.dsstore"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey: @"Invalid version"}];
        }
        return NO;
    }
    if (self.magic != 'Bud1') {  // Magic is magic, you know
        if (err) {
            *err = [NSError errorWithDomain:@"com.flyingpaper.dsstore"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey: @"Invalid magic"}];
        }
        return NO;
    }
    if (self.allocator_offset == 0) {  // Can't point to 0.
        if (err) {
            *err = [NSError errorWithDomain:@"com.flyingpaper.dsstore"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey: @"Invalid allocator offset"}];
        }
        return NO;
    }

    int allocator_offset_copy = DSGetUInt32([data bytes] + 16);
    if (allocator_offset_copy != self.allocator_offset) {  // Malformed header
        if (err) {
            *err = [NSError errorWithDomain:@"com.flyingpaper.dsstore"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey: @"Invalid allocator offset copy"}];
        }
        return NO;
    }

    // Parse the allocator
    return [self.allocator parseData:data atOffset:allocator_offset withError:err];
}

@end
