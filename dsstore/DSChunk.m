//
//  DSChunk.m
//  dsstore
//
//  Created by Tom Metge on 6/13/13.
//  Copyright (c) 2013 Flying Paper Software. All rights reserved.
//

#import "DSChunk.h"
#import "DSChunkUtils.h"

@implementation DSChunk

@synthesize data = _data, filename = _filename, attrname = _attrname,
            typename = _typename, value = _value, offset = _offset;

+(DSChunk*)chunkWithData:(NSData *)data atOffset:(int)offset
{
    return [[[DSChunk alloc] initWithData:data atOffset:offset] autorelease];
}

-(instancetype)initWithData:(NSData *)data atOffset:(int)offset
{
    self = [super init];
    if (self) {
        self.data = data;
        _offset = offset;
    }
    return self;
}

-(BOOL)parse
{
    unsigned long length = [self.data length];
    const unsigned char *bytes=[self.data bytes];

    if(length < self.offset+4) return NO; // Truncated file.

    int namelen=DSGetUInt32(bytes + self.offset);
    if(length < self.offset + 12 + namelen * 2) return NO; // Truncated file.

    self.filename=[[[NSString alloc] initWithBytes:bytes + self.offset + 4
                                            length:namelen*2
                                          encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF16BE)] autorelease];
    _offset += 4 + namelen * 2;

    self.attrname=[[[NSString alloc] initWithBytes:bytes + self.offset length:4
                                          encoding:NSISOLatin1StringEncoding] autorelease];
    self.typename=[[[NSString alloc] initWithBytes:bytes + self.offset + 4 length:4
                                          encoding:NSISOLatin1StringEncoding] autorelease];
    uint32_t attr=DSGetUInt32(bytes + self.offset);
    uint32_t type=DSGetUInt32(bytes + self.offset + 4);
    _offset += 8;

    switch(type)
    {
        case 'long': // Four-byte long.
        case 'shor': // Shorts seem to be 4 bytes too.
        {
            if(length < self.offset + 4) return NO; // Truncated file.
            self.value=[NSNumber numberWithLong:DSGetInt32(bytes + self.offset)];
            _offset += 4;
            break;
        }

        case 'bool': // One-byte boolean.
            if(length < self.offset + 1) return NO; // Truncated file.
            self.value=[NSNumber numberWithBool:bytes[self.offset]];
            _offset += 1;
            break;

        case 'blob': // Binary data.
        {
            if(length < self.offset + 4) return NO; // Truncated file.
            int len=DSGetUInt32(bytes + self.offset);
            if(length < self.offset + 4 + len) return NO; // Truncated file.
            switch (attr) {
                case 'bwsp':
                case 'glvp':
                case 'lsvC':
                case 'lsvp':
                case 'lsvP':
                case 'icvp':
                case 'icvP':
                {
                    NSString *errorDescription = nil;
                    NSPropertyListFormat format;
                    NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:[NSData dataWithBytes:bytes + self.offset + 4 length:len] mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorDescription];
                    if (!errorDescription) {
                        self.value = plist;
                    } else {
                        self.value=[NSData dataWithBytes:bytes + self.offset + 4 length:len];
                    }
                    break;
                }

                default:
                {
                    self.value=[NSData dataWithBytes:bytes + self.offset + 4 length:len];
                    break;
                }
            }
            _offset += 4 + len;
            break;
        }

        case 'type': // Four-byte char.
        {
            // FIXME: this is untested.
            if(length < self.offset + 4) return NO; // Truncated file.
            self.value=[[[NSString alloc] initWithBytes:bytes + self.offset
                                                 length:4
                                               encoding:NSISOLatin1StringEncoding] autorelease];
            _offset += 4;
            break;
        }

        case 'ustr': // UTF16BE string
        {
            if(length < self.offset + 4) return NO; // Truncated file.
            int len=DSGetUInt32(bytes + self.offset);
            if(length < self.offset + 4 + len * 2) return NO; // Truncated file.
            self.value=[[[NSString alloc] initWithBytes:bytes + self.offset + 2
                                                 length:len*2
                                               encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF16BE)] autorelease];
            _offset += 4 + len * 2;
            break;
        }

        case 'comp': // Eight-byte long.
        case 'dutc': // Eight-byte long. (1/65536 second increments since epoch)
        {
            if(length < self.offset + 8) return NO; // Truncated file.
            self.value=[NSNumber numberWithDouble:DSGetInt64((const uint8_t*)bytes + self.offset)];
            _offset += 8;
            break;
        }

        default:
        {
            NSLog(@"Unknown type code: %@", self.typename);
            return NO; // Unknown chunk type, give up.
        }
    }
    
    return YES;
}

@end
