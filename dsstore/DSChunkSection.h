//
//  DSChunkSection.h
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSChunkSection : NSObject {
    NSData* _data;
    NSMutableArray* _chunks;
    int _section_id;
}

@property (retain) NSData* data;
@property (readonly) NSArray* chunks;
@property (readonly) int section_id;

+(DSChunkSection*)chunkSectionWithData:(NSData*)data andSection:(int)section;
-(id)initWithData:(NSData*)data andSection:(int)section;
-(int)parse;

@end
