//
//  DSStore.m
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#import "DSStore.h"
#import "DSChunkSection.h"

@interface DSStore () {
    NSData* _data;
    NSMutableArray* _sections;
}

@end

@implementation DSStore

@synthesize data = _data, sections, header;

+(DSStore*)storeWithData:(NSData*)data
{
    return [[[DSStore alloc] initWithData:data] autorelease];
}

-(instancetype)initWithData:(NSData*)data
{
    self = [self init];
    if (self) {
        self.data = data;
    }
    return self;
}

// For creating a new .DS_Store file
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.header = [[[DSHeader alloc] init] autorelease];
        _sections = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL)parseWithError:(NSError **)err
{
    if (![self.header parseData:self.data withError:err]) {  // Invalid header
        return NO;
    }

    for(int n=0; ; n++)
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
