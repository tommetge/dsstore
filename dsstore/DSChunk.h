//
//  DSChunk.h
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSChunk : NSObject {
    NSData* _data;
    int _offset;
    NSString* _filename;
    NSString* _attrname;
    NSString* _typename;
    id _value;
}

@property (retain) NSData* data;
@property (readonly) int offset;
@property (assign) NSString* filename;
@property (assign) NSString* attrname;
@property (assign) NSString* typename;
@property (assign) id value;

+(DSChunk*)chunkWithData:(NSData*)data atOffset:(int)offset;
-(instancetype)initWithData:(NSData*)data atOffset:(int)offset;
-(BOOL)parse;

@end
