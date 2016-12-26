//
//  Tester.m
//  Python IDE
//
//  Created by Justin Bush on 2016-12-25.
//  Copyright © 2016 Justin Bush. All rights reserved.
//

#import "Tester.h"
#import "Parser.h"


@implementation Tester

- (NSString *)runContentsOfFile:(NSString *)path {
    NSMutableString *report = [NSMutableString string];
    
    NSArray *lines = [[NSString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding
                                                   error:nil]
                      componentsSeparatedByString:@"\n"];
    
    NSMutableString *buffer = [NSMutableString string];
    
    for (NSString *line in lines) {
        if ([line length] == 0 || [line characterAtIndex:0] == '#') {
            continue;
        }
        
        if ([line hasPrefix:@">>> "] || [line hasPrefix:@"... "]) {
            [buffer appendString:[line substringFromIndex:4]];
            [buffer appendString:@"\n"];
        } else {
            NSString *source = buffer;
            NSString *expected = line;
            
            [report appendString:@"----------\n"];
            [report appendString:source];
            
            Parser *p = [[Parser alloc] initWithString:source];
            Suite *s = [p parse_file];
            
            PyCore *pyCore = [[PyCore alloc] init];
            Frame *frame = [pyCore newInitialFrame];
            
            @try {
                Value *result = [s evaluate:frame];
                if (frame.resultType) {
                    [report appendFormat:@"Exceptional result(%d): %@\n",
                     frame.resultType, [result __repr__]];
                } else {
                    NSString *actual = [result __repr__];
                    
                    if ([actual isEqualToString:expected]) {
                        [report appendString:@"\nOK\n"];
                    } else {
                        [report appendString:@"\nActual  : "];
                        [report appendString:actual];
                        [report appendString:@"\nExpected: "];
                        [report appendString:expected];
                        [report appendString:@"\n"];
                    }
                }
            }
            
            @catch (NSException *exception) {
                [report appendFormat:@"\n%@: %@\n", exception.name, exception.reason];
            }
            
            
            [buffer setString:@""];
        }
    }
    
    if ([buffer length]) {
        @throw NSInvalidArgumentException;
    }
    
    return report;
}

+ (NSString *)run {
    Tester *tester = [[Tester alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"parsertests" ofType:@"py"];
    NSString *report = [tester runContentsOfFile:path];
    NSLog(@"%@", report);
    return report;
}

@end
