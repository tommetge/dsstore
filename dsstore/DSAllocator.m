//
//  DSAllocator.m
//  dsstore
//
//  Created by Thomas Metge on 1/15/14.
//  Copyright (c) 2014 Flying Paper Software. All rights reserved.
//

#import "DSAllocator.h"
#import "DSChunkUtils.h"

#pragma mark AllocatorDirEnt

@interface AllocatorDirEnt () {
    NSString* _name;
    int _block_offset;
}

- (instancetype)initWithName:(NSString*)name blockOffset:(int)offset;
@end

@implementation AllocatorDirEnt

@synthesize name = _name, block_offset = _block_offset;

- (instancetype)initWithName:(NSString *)name blockOffset:(int)offset
{
    self = [super init];
    if (self) {
        _name = name;
        _block_offset = offset;
    }
    return self;
}

@end

#pragma mark AllocatorFreeEnt

@interface AllocatorFreeEnt : NSObject {
    int _index;
    int _size;
    NSArray* _block_offsets;
}
@property (readonly) int index;
@property (readonly) int size;
@property (readonly) NSArray* block_offsets;

- (instancetype)initWithIndex:(int)index blockOffsets:(NSArray*)offsets;

@end

@implementation AllocatorFreeEnt

@synthesize index = _index, size = _size, block_offsets = _block_offsets;

- (instancetype)initWithIndex:(int)index blockOffsets:(NSArray*)offsets {
    self = [super init];
    if (self) {
        _index = index;
        _size = 2^index;
        _block_offsets = [offsets retain];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    [_block_offsets release];
}

@end

#pragma mark DSAllocator

@interface DSAllocator() {
    int block_count;            // 4 bytes, indicating number of block_addresses
    int filler;                 // 4 bytes
    NSArray *block_addresses;   // Zero-filled to the next 256 entries/1024 bytes
    int directory_count;        // 4 bytes, indicating number of directory_entries
    // directory_entries        // 1 byte count, count bytes of name, 4 byte block offset
    NSArray *free_lists;        // 1 byte count, count block offsets
}

- (uint32_t)blockOffsetForIndex:(int)blockIndex;

@end

@implementation DSAllocator

@synthesize directory_entries;

- (instancetype)init {
    self = [super init];
    if (self) {
        block_count = 0;
        filler = 0;
        block_addresses = nil;
        directory_count = 0;
        self.directory_entries = nil;
        free_lists = nil;
    }
    return self;
}

- (BOOL)parseData:(NSData*)data atOffset:(int)offset withError:(NSError**)err {
    if ([data length] < offset + 46) { // Minimum allocator size
        if (err) {
            *err = [NSError errorWithDomain:@"com.flyingpaper.dsstore"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey: @"Invalid data (size)"}];
        }
        return NO;
    }

    block_count = DSGetUInt32([data bytes] + offset);

    // Size of block_addresses is padded up to the next 1024 bytes
    int r = block_count * 4 % 1024;
    int directory_count_offset = block_count * 4;

    if (r != 0) {
        directory_count_offset += 1024 - r;
    }

    if ([data length] < directory_count_offset + 4) { // Malformed
        if (err) {
            *err = [NSError errorWithDomain:@"com.flyingpaper.dsstore"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey: @"Invalid data (malformed)"}];
        }
        return NO;
    }

    NSMutableArray* _block_addresses = [NSMutableArray arrayWithCapacity:block_count];
    for (int i = 8; i < block_count * 4; i += 4) {
        NSNumber* address = [NSNumber numberWithUnsignedInt:DSGetUInt32([data bytes] + offset + i)];
        [_block_addresses addObject:address];
    }
    block_addresses = _block_addresses;

    directory_count = DSGetUInt32([data bytes] + offset + directory_count_offset);

    // There should be at least directory_count * 4 bytes left
    if ([data length] < directory_count_offset + 4 * directory_count) {
        if (err) {
            *err = [NSError errorWithDomain:@"com.flyingpaper.dsstore"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey: @"Invalid data (size of directory)"}];
        }
        return NO;
    }

    // This *could* be a dictionary, but we're playing it safe, in case there are
    // duplicate names.
    NSMutableArray* _directory_entries = [NSMutableArray arrayWithCapacity:directory_count];
    int entry_offset = offset + directory_count_offset + 4;
    for (int i = 0; i < directory_count; i++) {
        int name_length = DSGetUInt32([data bytes] + entry_offset);
        NSString* dir_name = [[NSString alloc] initWithBytes:[data bytes] + entry_offset + 4
                                                      length:name_length * 2
                                                    encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF16BE)];
        int dir_block = DSGetUInt32([data bytes] + entry_offset + 4 + name_length * 2);
        uint32_t block_offset = [self blockOffsetForIndex:dir_block];
        AllocatorDirEnt *dir_ent = [[[AllocatorDirEnt alloc] initWithName:[dir_name autorelease]
                                                              blockOffset:block_offset] autorelease];
        [_directory_entries addObject:dir_ent];
        entry_offset += 4 + name_length + 4;
    }

    self.directory_entries = _directory_entries;

    // entry_offset should now point to the beginning of the free lists
    if ([data length] < entry_offset + 32 * 4) { // Malformed
        if (err) {
            *err = [NSError errorWithDomain:@"com.flyingpaper.dsstore"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey: @"Invalid data (entry offset)"}];
        }
        return NO;
    }

    NSMutableArray* _free_lists = [NSMutableArray arrayWithCapacity:32];
    for (int i = 0; i < 32; i++) {
        int list_count = DSGetUInt32([data bytes] + entry_offset);
        NSMutableArray* list_blocks = [NSMutableArray arrayWithCapacity:list_count];
        for (int l = 0; l < list_count; l++) {
            uint32_t address = DSGetUInt32([data bytes] + entry_offset);
            NSNumber* blockAddress = [NSNumber numberWithUnsignedInt:address];
            [list_blocks addObject:blockAddress];
        }
        AllocatorFreeEnt *free_ent = [[[AllocatorFreeEnt alloc] initWithIndex:i
                                                                 blockOffsets:list_blocks] autorelease];
        [_free_lists addObject:free_ent];
    }

    return YES;
}

- (uint32_t)blockOffsetForIndex:(int)blockIndex {
    if (block_addresses == nil) {
        [NSException raise:NSRangeException
                    format:@"Block addresses unavailable"];
    }
    if (blockIndex > [block_addresses count]) {
        [NSException raise:NSRangeException
                    format:@"Requested index beyond bounds (%ld)", (unsigned long)[block_addresses count]];
    }
    return [[block_addresses objectAtIndex:blockIndex] unsignedIntValue];
    return 0;
}

@end
