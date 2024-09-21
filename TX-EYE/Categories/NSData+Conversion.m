//
//  NSData+Conversion.m
//  TX-EYE
//
//  Created by CoreCat on 2021/11/28.
//  Copyright © 2021 CoreCat. All rights reserved.
//

#import "NSData+Conversion.h"

@implementation NSData (Conversion)

- (NSString *)hexString
{
    NSUInteger bytesCount = self.length;
    if (bytesCount) {
        const char *hexChars = "0123456789ABCDEF";
        const unsigned char *dataBuffer = self.bytes;
        char *chars = malloc(sizeof(char) * (bytesCount * 3 + 1));
        if (chars == NULL) {
            // malloc returns null if attempting to allocate more memory than the system can provide. Thanks Cœur
            [NSException raise:NSInternalInconsistencyException format:@"Failed to allocate more memory" arguments:nil];
            return nil;
        }
        char *s = chars;
        for (unsigned i = 0; i < bytesCount; ++i) {
            *s++ = hexChars[((*dataBuffer & 0xF0) >> 4)];
            *s++ = hexChars[(*dataBuffer & 0x0F)];
            *s++ = ' ';
            dataBuffer++;
        }
        *s = '\0';
        NSString *hexString = [NSString stringWithUTF8String:chars];
        free(chars);
        return hexString;
    }
    return @"";
}

@end
