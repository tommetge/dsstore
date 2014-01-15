//
//  DSStore.h
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSHeader.h"

@interface DSStore : NSObject

@property (readonly) NSArray* sections;
@property (nonatomic, retain) NSData* data;
@property (nonatomic, retain) DSHeader* header;

+(DSStore*)storeWithData:(NSData*)data;
-(id)initWithData:(NSData*)data;

-(BOOL)parseWithError:(NSError**)err;

@end
