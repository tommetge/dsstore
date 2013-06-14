//
//  DSStore.h
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSStore : NSObject {
    NSData* _data;
    NSMutableArray* _sections;
}

@property (readonly) NSArray* sections;
@property (retain) NSData* data;

+(DSStore*)storeWithData:(NSData*)data;
-(id)initWithData:(NSData*)data;

-(BOOL)parse;

@end
