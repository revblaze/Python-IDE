//
//  Token.h
//  Python IDE
//
//  Created by Justin Bush on 2016-12-25.
//  Copyright © 2016 Justin Bush. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Token : NSObject {
    NSString *source;
    NSRange range;
}

+ (NSArray *)tokenizeString:(NSString *)string;
+ (Token *)EOFToken;
+ (Token *)indentToken;
+ (Token *)dedentToken;

- (id)initWithSource:(NSString *)source range:(NSRange)range;
- (BOOL)isEqualToString:(NSString *)string;
- (BOOL)isNumber;
- (BOOL)isString;
- (NSNumber *)numberValue;
- (NSString *)stringValue;
- (NSString *)stringByUnescapingStringValue;
- (unichar)firstCharacter;
- (NSUInteger)lineNumber;

@end
