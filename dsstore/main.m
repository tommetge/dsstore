//
//  main.m
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSChunkSection.h"
#import "DSChunk.h"
#import "DSStore.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        if (argc != 2) {
            NSLog(@"Invalid arguments.");
            NSLog(@"Usage: %s [path]", argv[0]);
            return 1;
        }

        NSString *path = [NSString stringWithUTF8String:argv[1]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSLog(@"File does not exist");
            return 1;
        }

        NSData *data=[NSData dataWithContentsOfFile:path];
        if (!data) {
            NSLog(@"Unable to read file");
            return 1;
        }

        DSStore *store = [DSStore storeWithData:data];
        if (![store parse]) {
            NSLog(@"Failed to parse file");
            return 1;
        }

        for (DSChunkSection *section in store.sections) {
            NSLog(@"Section: %d (%ld chunks)", section.section_id, (unsigned long)[section.chunks count]);
            for (DSChunk *chunk in section.chunks) {
                NSLog(@"\"%@\" = {\n\t%@ = %@\n}", chunk.filename, chunk.attrname, chunk.value);
            }
        }
    }
    return 0;
}

