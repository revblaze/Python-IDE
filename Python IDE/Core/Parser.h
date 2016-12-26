//
//  Parser.h
//  Python IDE
//
//  Created by Justin Bush on 2016-12-25.
//  Copyright © 2016 Justin Bush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Token.h"
#import "AST.h"

@interface Parser : NSObject {
    NSArray *tokens;
    NSInteger index;
}

- (id)initWithString:(NSString *)source;
- (Expr *)parse_test;
- (Suite *)parse_suite;
- (Suite *)parse_file;

@end
