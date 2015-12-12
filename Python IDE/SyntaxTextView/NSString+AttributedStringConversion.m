//
//  NSString+AttributedStringConversion.m
//  Python IDE
//
//  Created by Justin Bush on 2015-12-10.
//  Copyright © 2015 Justin Bush. All rights reserved.
//

#import "NSString+AttributedStringConversion.h"

@implementation NSString (AttributedStringConversion)

- (NSAttributedString *)attributedString {
    return [[NSAttributedString alloc] initWithString:self];
}

@end
