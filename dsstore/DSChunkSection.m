//
//  DSChunkSection.m
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#import "DSChunkSection.h"
#import "DSChunk.h"
#import "DSChunkUtils.h"

@implementation DSChunkSection

@synthesize data = _data, chunks, section_id = _section_id;

+(DSChunkSection*)chunkSectionWithData:(NSData*)data andSection:(int)section
{
    return [[[DSChunkSection alloc] initWithData:data andSection:section] autorelease];
}

-(instancetype)initWithData:(NSData*)data andSection:(int)section
{
    self = [super init];
    if (self) {
        self.data = data;
        _section_id = section;
        _chunks = nil;
        _offset = 0;
    }
    return self;
}

-(int)parse
{
    unsigned long length = [self.data length];
    const unsigned char *bytes = [self.data bytes];

    _offset_location = 20 + self.section_id * 4;
    if (length < _offset_location + 4) return NO; // Truncated file.

    _offset = DSGetUInt32(bytes + _offset_location);

    if (_offset == 0) return NO; // No more chunk sections, parsing is done.

    _offset &= ~0x0f; // Chunk sections are 16-byte aligned, but the offsets are not for some reason.

    if (length < _offset + 12) return NO; // Truncated file.

    int val2 = DSGetUInt32(bytes + _offset + 4);
    int numchunks = DSGetUInt32(bytes + _offset + 8);
    int chunk_offs = _offset + 12;

    NSMutableArray *parsedChunks = [NSMutableArray arrayWithCapacity:numchunks];

    for(int i=0;i<numchunks;i++)
    {
        if (val2 & 2) chunk_offs += 4; // Extra four-byte value before each chunk.
        DSChunk *chunk = [DSChunk chunkWithData:self.data atOffset:chunk_offs];

        if (![chunk parse]) return NO; // Done (or something went wrong

        [parsedChunks addObject:chunk];
        chunk_offs = chunk.offset;
    }

    _chunks = parsedChunks;

    return YES;
}

-(NSArray*)chunks
{
    return _chunks;
}

@end
