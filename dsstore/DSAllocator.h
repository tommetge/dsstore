//
//  DSAllocator.h
//  dsstore
//
//  Created by Thomas Metge on 1/15/14.
//  Copyright (c) 2014 Flying Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AllocatorDirEnt : NSObject

@property (readonly) NSString* name;
@property (readonly) int block_offset;

@end

@interface DSAllocator : NSObject

@property (nonatomic, retain) NSArray* directory_entries;

- (instancetype)init;
- (BOOL)parseData:(NSData*)data atOffset:(int)offset withError:(NSError**)err;

@end
