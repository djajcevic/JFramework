//
//  NSString+JF.m
//  Hattrick
//
//  Created by Denis Jajčević on 12/17/12.
//  Copyright (c) 2012 JF. All rights reserved.
//

#import "NSString+JF.h"

static char base64EncodingTable[64] = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

@implementation NSString (JF)

- (NSURL *)URL
{
    return [NSURL URLWithString:self];
}

//- (NSString *)localized
//{
//    return [[[self appDelegate] localeBundle] localizedStringForKey:self value:self table:nil];
//}
//
//- (NSString *)hr
//{
//    return [[[self appDelegate] hrLocaleBundle] localizedStringForKey:self value:self table:nil];
//}
//
//- (NSString *)en
//{
//    return [[[self appDelegate] enLocaleBundle] localizedStringForKey:self value:self table:nil];
//}

- (NSNumber *)integerNumber
{
    return [NSNumber numberWithInteger:[self integerValue]];
}

- (NSNumber *)floatNumber
{
    return [NSNumber numberWithFloat:[self floatValue]];
}

- (NSNumber *)doubleNumber
{
    return [NSNumber numberWithDouble:[self doubleValue]];
}

- (NSNumber *)boolNumber
{
    return [NSNumber numberWithBool:[self boolValue]];
}

- (void)log
{
//#ifdef DEBUG
    NSLog (@"ISPC: %@", self);
//#endif
}

- (NSString *)escaped
{
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)unescaped
{
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)base64
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString base64StringFromData:data length:data.length];
}

+ (NSString *)base64StringFromData:(NSData *)data length:(int)length
{
    unsigned long ixtext, lentext;
    long          ctremaining;
    unsigned char input[3], output[4];
    short         i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString     *result;

    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity:lentext];
    raw    = [data bytes];
    ixtext = 0;

    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i    = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }

        for (i = 0; i < ctcopy; i++)
            [result appendString:[NSString stringWithFormat:@"%c", base64EncodingTable[output[i]]]];

        for (i = ctcopy; i < 4; i++)
            [result appendString:@"="];

        ixtext += 3;
        charsonline += 4;

        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}

- (NSString *)sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData     *data = [NSData dataWithBytes:cstr length:self.length];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1 (data.bytes, data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return output;
}

- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5 (cStr, strlen (cStr), digest); // This is the md5 call

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return output;
}

- (NSString *)dictionaryPath
{
    return [[NSBundle mainBundle] pathForResource:self ofType:@"plist"];
}

-(NSRange) range
{
    return NSMakeRange(0, [self length]);
}

-(BOOL)matches:(NSString *)pattern
{
    assert(pattern != nil);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSRange range = [regex rangeOfFirstMatchInString:self options:0 range:self.range];
    BOOL matches = range.length > 0;
    return matches;
}

-(BOOL)isValidEmail
{
    return [self matches:@"^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"];
}


@end
