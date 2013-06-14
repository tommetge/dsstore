//
//  DSStore.m
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#import "DSStore.h"
#import "DSChunkUtils.h"
#import "DSChunkSection.h"
#import "DSChunk.h"

@implementation DSStore

@synthesize data = _data, sections;

+(DSStore*)storeWithData:(NSData*)data
{
    return [[[DSStore alloc] initWithData:data] autorelease];
}

-(id)initWithData:(NSData*)data
{
    self = [super init];
    if (self) {
        self.data = data;
        _sections = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL)parse
{
    const unsigned char *bytes=[self.data bytes];
	double length=[self.data length];
	if(length<20) return NO; // Too short for the header.

	int ver=DSGetUInt32(bytes);
	if(ver!=1) return NO; // Unsupported version (probably).

	int type=DSGetUInt32(bytes+4);
	if(type!='Bud1') return NO; // Unsupported filetype.

    for(int n=0;;n++)
	{
        DSChunkSection* section = [DSChunkSection chunkSectionWithData:self.data andSection:n];
        [_sections addObject:section];
        if (![section parse]) {
            break;
        }
    }

    return YES;
}

-(NSArray*)sections
{
    return _sections;
}

@end
