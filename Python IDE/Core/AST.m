//
//  AST.m
//  Python IDE
//
//  Created by Justin Bush on 2016-12-25.
//  Copyright © 2016 Justin Bush. All rights reserved.
//

#import "AST.h"

#pragma mark Helper functions

static inline NSObject *toBoolean(BOOL value) {
    return value ? [PyCore True] : [PyCore False];
}

static inline NSObject *toNumber(NSInteger value) {
    return [NSNumber numberWithInteger:value];
}

static inline BOOL isInteger(NSObject *object) {
    return [object isKindOfClass:[NSNumber class]];
}

static inline BOOL isString(NSObject *object) {
    return [object isKindOfClass:[NSString class]];
}

static inline BOOL isSequence(NSObject *object) {
    return [object isKindOfClass:[NSArray class]];
}

static inline BOOL isList(NSObject *object) {
    return [object isKindOfClass:[NSMutableArray class]];
}

static inline BOOL isDict(NSObject *object) {
    return [object isKindOfClass:[NSMutableDictionary class]];
}

static inline BOOL isSet(NSObject *object) {
    return [object isKindOfClass:[NSMutableSet class]];
}

static inline NSInteger asInteger(NSObject *object) {
    return [(NSNumber *)object integerValue];
}

static BOOL nonZero(Value *value) {
    return
    value == [PyCore True] ||
    (isInteger(value) && [(NSNumber *)value intValue]) ||
    (isString(value) && [(NSString *)value length]) ||
    (isSequence(value) && [(NSArray *)value count]) ||
    (isDict(value) && [(NSMutableDictionary *)value count]) ||
    (isSet(value) && [(NSMutableSet *)value count]);
}

static inline BOOL matches(Value *value, Value *type) {
    return YES;
}

static NSString *op(NSObject *object) {
    NSString *name = NSStringFromClass([object class]);
    return [name substringToIndex:[name length] - 4];
}

static NSString *descriptionForArray(NSArray *array) {
    NSMutableString *buffer = [NSMutableString string];
    [buffer appendString:@"["];
    BOOL first = YES;
    for (NSObject *object in array) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[object description]];
    }
    [buffer appendString:@"]"];
    return buffer;
}


#pragma mark -
#pragma mark Expression nodes

@implementation Expr

- (Value *)evaluate:(Frame *)frame {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (Value *)setValue:(NSObject *)value frame:(Frame *)frame {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end


@implementation BinaryExpr

+ (BinaryExpr *)exprWithLeftExpr:(Expr *)leftExpr rightExpr:(Expr *)rightExpr {
    BinaryExpr *expr = [[self alloc] init];
    if (expr) {
        expr->leftExpr = leftExpr;
        expr->rightExpr = rightExpr;
    }
    return expr;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@, %@)", op(self), leftExpr, rightExpr];
}

@end


@implementation UnaryExpr

+ (UnaryExpr *)exprWithExpr:(Expr *)expr {
    UnaryExpr *unaryExpr = [[self alloc] init];
    if (unaryExpr) {
        unaryExpr->expr = expr;
    }
    return unaryExpr;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", op(self), expr];
}

@end


@implementation IfExpr

+ (IfExpr *)exprWithTestExpr:(Expr *)testExpr thenExpr:(Expr *)thenExpr elseExpr:(Expr *)elseExpr {
    IfExpr *expr = [[self alloc] init];
    if (expr) {
        expr->testExpr = testExpr;
        expr->thenExpr = thenExpr;
        expr->elseExpr = elseExpr;
    }
    return expr;
}


- (Value *)evaluate:(Frame *)frame {
    Value *test = [testExpr evaluate:frame];
    if (frame.resultType) {
        return test;
    }
    
    return [(nonZero(test) ? thenExpr : elseExpr) evaluate:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"If(%@, %@, %@)", testExpr, thenExpr, elseExpr];
}

@end


@implementation OrExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    if (nonZero(left)) {
        return left;
    }
    
    return [rightExpr evaluate:frame];
}

@end


@implementation AndExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    if (nonZero(left)) {
        return [rightExpr evaluate:frame];
    }
    
    return left;
}

@end


@implementation NotExpr

- (Value *)evaluate:(Frame *)frame {
    Value *value = [expr evaluate:frame];
    if (frame.resultType) {
        return value;
    }
    
    return toBoolean(!nonZero(value));
}

@end


@implementation LtExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    if (![left respondsToSelector:@selector(compare:)]) {
        return [frame typeError:@"Bad operands for <"];
    }
    
    return toBoolean([(NSNumber *)left compare:(NSNumber *)right] == NSOrderedAscending);
}

@end


@implementation GtExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    if (![left respondsToSelector:@selector(compare:)]) {
        return [frame typeError:@"Bad operands for >"];
    }
    
    return toBoolean([(NSNumber *)left compare:(NSNumber *)right] == NSOrderedDescending);
}

@end


@implementation LeExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    if (![left respondsToSelector:@selector(compare:)]) {
        return [frame typeError:@"Bad operands for <="];
    }

    return toBoolean([(NSNumber *)left compare:(NSNumber *)right] != NSOrderedDescending);
}

@end


@implementation GeExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    if (![left respondsToSelector:@selector(compare:)]) {
        return [frame typeError:@"Bad operands for >="];
    }
    
    return toBoolean([(NSNumber *)left compare:(NSNumber *)right] != NSOrderedAscending);
}

@end


@implementation EqExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    return toBoolean([left isEqual:right]);
}

@end


@implementation NeExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    return toBoolean(![left isEqual:right]);
}

@end


@implementation InExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    // Variable Type: Tuple, List, Set, Dict
    if ([right respondsToSelector:@selector(containsObject:)]) {
        return toBoolean([(NSArray *)right containsObject:left]);
    }
    // Variable Type: Str
    if ([right isKindOfClass:[NSString class]]) {
        return toBoolean([(NSString *)right rangeOfString:(NSString *)left].location != NSNotFound);
    }
    // Variable Type: Iterable
    if ([right isKindOfClass:[NSEnumerator class]]) {
        for (NSObject *value in (NSEnumerator *)right) {
            if ([left isEqual:value]) {
                return [PyCore True];
            }
        }
        return [PyCore False];
    }
    return [frame typeError:@"Right argument is not iterable"];
}

@end


@implementation IsExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    return toBoolean(left == right);
}

@end


@implementation AddExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    if (isInteger(left) && isInteger(right)) {
        return toNumber(asInteger(left) + asInteger(right));
    }
    
    if (isString(left) && isString(right)) {
        return [(NSString *)left stringByAppendingString:(NSString *)right];
    }
    
    if (isSequence(left) && isSequence(right)) {
        return [(NSArray *)left arrayByAddingObjectsFromArray:(NSArray *)right];
    }
    
    return [frame typeError:@"Unsupported operands for +"];
}

@end


@implementation SubExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    if (isInteger(left) && isInteger(right)) {
        return toNumber(asInteger(left) - asInteger(right));
    }
    
    return [frame typeError:@"Unsupported operands for -"];
}

@end


@implementation MulExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    if (isInteger(left) && isInteger(right)) {
        return toNumber(asInteger(left) * asInteger(right));
    }
    
    if (isString(left) && isInteger(right)) {
        NSInteger count = asInteger(right);
        if (count < 1) {
            return @"";
        }
        if (count == 1) {
            return left;
        }
        NSString *string = (NSString *)left;
        NSMutableString *buffer = [NSMutableString stringWithCapacity:[string length] * count];
        while (count--) {
            [buffer appendString:string];
        }
        return [buffer copy];
    }
    
    return [frame typeError:@"Unsupported operands for *"];
}

@end


@implementation DivExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    if (isInteger(left) && isInteger(right)) {
        return toNumber(asInteger(left) / asInteger(right));
    }
    
    return [frame typeError:@"Unsupported operands for /"];
}

@end


@implementation ModExpr

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    if (isInteger(left) && isInteger(right)) {
        return toNumber(asInteger(left) % asInteger(right));
    }
    
    if (isString(left) && isSequence(right)) {
        NSString *string = (NSString *)left;
        NSArray *tuple = (NSArray *)right;
        
        NSMutableString *buffer = [NSMutableString string];
        
        NSUInteger j = 0;
        
        for (NSUInteger i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if (c == '%') {
                c = [string characterAtIndex:++i];
                switch (c) {
                    case 's':
                        [buffer appendString:[[tuple objectAtIndex:j++] __str__]];
                        break;
                    case 'r':
                        [buffer appendString:[[tuple objectAtIndex:j++] __repr__]];
                        break;
                    case 'd':
                    case 'i':
                    case 'f':
                        [buffer appendFormat:@"%@", [tuple objectAtIndex:j++]];
                        break;
                    case '%':
                        [buffer appendString:@"%"];
                        break;
                    default:
                        [buffer appendFormat:@"%%%c", c];
                        break;
                }
            } else {
                [buffer appendFormat:@"%c", c];
            }
        }
        return [buffer copy];
    }
    
    return [frame typeError:@"Unsupported operands for %"];
}

@end


@implementation NegExpr

- (Value *)evaluate:(Frame *)frame {
    Value *value = [expr evaluate:frame];
    if (frame.resultType) {
        return value;
    }
    
    if (isInteger(value)) {
        return toNumber(-asInteger(value));
    }
    
    return [frame typeError:@"TypeError: Bad operand type for unary -"];
}

@end


@implementation PosExpr

- (Value *)evaluate:(Frame *)frame {
    Value *value = [expr evaluate:frame];
    if (frame.resultType) {
        return value;
    }
    
    if (isInteger(value)) {
        return toNumber(+asInteger(value));
    }
    
    return [frame typeError:@"TypeError: Bad operand type for unary +"];
}

@end


@implementation CallExpr

+ (CallExpr *)exprWithFuncExpr:(Expr *)funcExpr argExprs:(NSArray *)argExprs {
    CallExpr *callExpr = [[self alloc] init];
    if (callExpr) {
        callExpr->funcExpr = funcExpr;
        callExpr->argExprs = argExprs;
    }
    return callExpr;
}


- (Value *)evaluate:(Frame *)frame {
    Value *func = [funcExpr evaluate:frame];
    if (frame.resultType) {
        return func;
    }
    
    if (![func conformsToProtocol:@protocol(Callable)]) {
        return [frame typeError:@"Object is not callable"];
    }
    
    NSUInteger count = [argExprs count];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; i++) {
        Value *result = [(Expr *)[argExprs objectAtIndex:i] evaluate:frame];
        if (frame.resultType) {
            return result;
        }
        
        [arguments addObject:result];
    }
    
    frame.arguments = arguments;
    
    return [(NSObject<Callable> *)func call:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Call(%@, %@)", funcExpr, descriptionForArray(argExprs)];
}

@end


@implementation IndexExpr

+ (IndexExpr *)exprWithExpr:(Expr *)expr subscriptExpr:(Expr *)subscriptExpr {
    IndexExpr *indexExpr = [[self alloc] init];
    if (indexExpr) {
        indexExpr->expr = expr;
        indexExpr->subscriptExpr = subscriptExpr;
    }
    return indexExpr;
}


- (Value *)evaluate:(Frame *)frame {
    Value *target = [expr evaluate:frame];
    if (frame.resultType) {
        return target;
    }
    
    Value *subscript = [subscriptExpr evaluate:frame];
    if (frame.resultType) {
        return subscript;
    }
    
    // For Type: Str
    if (isString(target)) {
        NSString *string = (NSString *)target;
        
        int index = asInteger(subscript);
        if (index < 0) {
            index += [string length];
        }
        if (index < 0 || index >= [string length]) {
            return [frame raise:@"IndexError"];
        }
        
        return [string substringWithRange:NSMakeRange(index, 1)];
    }
    
    // For Type: Tuple, List
    if ([target respondsToSelector:@selector(objectAtIndex:)]) {
        NSArray *list = (NSArray *)target;
        int index = asInteger(subscript);
        if (index < 0) {
            index += [list count];
        }
        if (index < 0 || index >= [list count]) {
            return [frame raise:@"IndexError"];
        }
        return [list objectAtIndex:index];
    }
    
    // For Type: Dict
    if ([target respondsToSelector:@selector(objectForKey:)]) {
        NSDictionary *dict = (NSDictionary *)target;
        Value *result = [dict objectForKey:subscript];
        if (result) {
            return result;
        }
        return [frame raise:@"KeyError"];
    }
    
    return [frame typeError:@"Object is not subscriptable"];
}

- (Value *)setValue:(NSObject *)value frame:(Frame *)frame {
    Value *target = [expr evaluate:frame];
    if (frame.resultType) {
        return target;
    }
    
    Value *subscript = [subscriptExpr evaluate:frame];
    if (frame.resultType) {
        return subscript;
    }
    
    // list
    if ([target respondsToSelector:@selector(replaceObjectAtIndex:withObject:)]) {
        NSMutableArray *list = (NSMutableArray *)target;
        int index = asInteger(subscript);
        if (index < 0) {
            index += [list count];
        }
        if (index < 0 || index >= [list count]) {
            return [frame raise:@"IndexError"];
        }
        [list replaceObjectAtIndex:index withObject:value];
        return nil;
    }
    
    // dict
    if ([target respondsToSelector:@selector(setObject:forKey:)]) {
        NSMutableDictionary *dict = (NSMutableDictionary *)target;
        [dict setObject:value forKey:subscript];
        return nil;
    }
    
    return [frame typeError:@"Object does not support item assignment"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Index(%@, %@)", expr, subscriptExpr];
}

@end


@implementation AttrExpr

+ (AttrExpr *)exprWithExpr:(Expr *)expr name:(NSString *)name {
    AttrExpr *attrExpr = [[self alloc] init];
    if (attrExpr) {
        attrExpr->expr = expr;
        attrExpr->name = [name copy];
    }
    return attrExpr;
}


- (Value *)evaluate:(Frame *)frame {
    Value *result = [expr evaluate:frame];
    if (frame.resultType) {
        return result;
    }
    
    if ([result isKindOfClass:[NSMutableArray class]]) {
        if ([name isEqualToString:@"append"]) {
            return [BuiltinMethod methodWithSelector:@selector(append:) receiver:result];
        }
    }
    
    if ([result respondsToSelector:@selector(valueForKey:)]) {
        @try {
            result = [result valueForKey:name];
            if (result == nil) {
                result = [PyCore None];
            }
            return result;
        }
        @catch (NSException *exception) {
            if (![exception.name isEqualToString:NSUndefinedKeyException]) {
                @throw exception;
            }
        }
    }
    return [frame raise:@"AttributeError"];
}

- (Value *)setValue:(NSObject *)value frame:(Frame *)frame {
    Value *result = [expr evaluate:frame];
    if (frame.resultType) {
        return value;
    }
    
    if ([result respondsToSelector:@selector(setValue:forKey:)]) {
        @try {
            [result setValue:value forKey:name];
            return nil;
        }
        @catch (NSException *exception) {
            if (![exception.name isEqualToString:NSUndefinedKeyException]) {
                @throw exception;
            }
        }
    }
    
    return [frame raise:@"AttributeError"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Attr(%@, %@)", expr, name];
}

@end


@implementation LiteralExpr

+ (LiteralExpr *)exprWithValue:(NSObject *)value {
    LiteralExpr *expr = [[self alloc] init];
    if (expr) {
        expr->value = value;
    }
    return expr;
}


- (Value *)evaluate:(Frame *)frame {
    return value;
}

- (NSString *)description {
    return [value __repr__];
}

@end


@implementation VariableExpr

+ (VariableExpr *)exprWithName:(NSString *)name {
    VariableExpr *expr = [[self alloc] init];
    if (expr) {
        expr->name = [name copy];
    }
    return expr;
}


- (Value *)evaluate:(Frame *)frame {
    Value *result = [frame localValueForName:name];
    if (result) {
        return result;
    }
    
    result = [frame globalValueForName:name];
    if (result) {
        return result;
    }
    
    return [frame raise:@"NameError"];
}

- (Value *)setValue:(NSObject *)value frame:(Frame *)frame {
    [frame setLocalValue:value forName:name];
    return nil;
}

- (NSString *)description {
    return name;
}

@end


@implementation TupleExpr

+ (Expr *)exprWithExprs:(NSArray *)exprs {
    TupleExpr *expr = [[self alloc] init];
    if (expr) {
        expr->exprs = [exprs copy];
    }
    return expr;
}


- (Value *)evaluate:(Frame *)frame {
    NSMutableArray *tuple = [NSMutableArray arrayWithCapacity:[exprs count]];
    
    for (Expr *expr in exprs) {
        Value *result = [expr evaluate:frame];
        if (frame.resultType) {
            return result;
        }
        [tuple addObject:result];
    }
    
    return [NSArray arrayWithArray:tuple];
}

- (Value *)setValue:(NSObject *)value frame:(Frame *)frame {
    NSArray *tuple = (NSArray *)value;
    
    for (NSUInteger i = 0; i < [exprs count]; i++) {
        Value *result = [[exprs objectAtIndex:i] setValue:[tuple objectAtIndex:i] frame:frame];
        if (frame.resultType) {
            return result;
        }
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", op(self), descriptionForArray(exprs)];
}

@end


@implementation ListExpr

- (Value *)evaluate:(Frame *)frame {
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:[exprs count]];
    
    for (Expr *expr in exprs) {
        Value *result = [expr evaluate:frame];
        if (frame.resultType) {
            return result;
        }
        [list addObject:result];
    }
    
    return list;
}

@end


@implementation SetExpr

- (Value *)evaluate:(Frame *)frame {
    NSMutableSet *set = [NSMutableSet setWithCapacity:[exprs count]];
    
    for (Expr *expr in exprs) {
        Value *result = [expr evaluate:frame];
        if (frame.resultType) {
            return result;
        }
        [set addObject:result];
    }
    
    return set;
}

@end


@implementation DictExpr

- (Value *)evaluate:(Frame *)frame {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[exprs count]];
    
    for (NSArray *pair in exprs) {
        Expr *keyExpr = [pair objectAtIndex:0];
        Expr *valueExpr = [pair objectAtIndex:1];
        
        Value *key = [keyExpr evaluate:frame];
        if (frame.resultType) {
            return key;
        }
        
        Value *value = [valueExpr evaluate:frame];
        if (frame.resultType) {
            return value;
        }
        
        [dictionary setObject:value forKey:key];
    }
    
    return dictionary;
}

- (NSString *)description {
    NSMutableString *buffer = [NSMutableString string];
    [buffer appendString:@"Dict("];
    BOOL first = YES;
    for (NSArray *pair in exprs) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        Expr *keyExpr = [pair objectAtIndex:0];
        Expr *valueExpr = [pair objectAtIndex:1];
        [buffer appendString:[keyExpr description]];
        [buffer appendString:@": "];
        [buffer appendString:[valueExpr description]];
    }
    [buffer appendString:@")"];
    return buffer;
}

@end


#pragma mark -
#pragma mark Statement nodes


@implementation Stmt

- (Value *)evaluate:(Frame *)frame {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end


@implementation Suite

+ (Suite *)suiteWithPassStmt {
    return [self suiteWithStmt:[PassStmt stmt]];
}

+ (Suite *)suiteWithStmt:(Stmt *)stmt {
    return [self suiteWithStmts:[NSArray arrayWithObject:stmt]];
}

+ (Suite *)suiteWithStmts:(NSArray *)stmts {
    Suite *suite = [[self alloc] init];
    if (suite) {
        suite->stmts = [stmts copy];
    }
    return suite;
}


- (Value *)evaluate:(Frame *)frame {
    Value *result = [PyCore None];
    for (Stmt *stmt in stmts) {
        result = [stmt evaluate:frame];
        if (frame.resultType) {
            return result;
        }
    }
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Suite%@", descriptionForArray(stmts)];
}

@end


@implementation IfStmt

+ (IfStmt *)stmtWithTestExpr:(Expr *)testExpr thenSuite:(Suite *)thenSuite elseSuite:(Suite *)elseSuite {
    IfStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->testExpr = testExpr;
        stmt->thenSuite = thenSuite;
        stmt->elseSuite = elseSuite;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    Value *test = [testExpr evaluate:frame];
    if (frame.resultType) {
        return test;
    }
    if (nonZero(test)) {
        return [thenSuite evaluate:frame];
    } else {
        return [elseSuite evaluate:frame];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"If(%@, %@, %@)", testExpr, thenSuite, elseSuite];
}

@end


@implementation WhileStmt

+ (WhileStmt *)stmtWithTestExpr:(Expr *)testExpr whileSuite:(Suite *)whileSuite elseSuite:(Suite *)elseSuite {
    WhileStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->testExpr = testExpr;
        stmt->whileSuite = whileSuite;
        stmt->elseSuite = elseSuite;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    while (TRUE) {
        Value *test = [testExpr evaluate:frame];
        if (frame.resultType) {
            return test;
        }
        
        if (!nonZero(test)) {
            return [elseSuite evaluate:frame];
        }
        
        Value *result = [whileSuite evaluate:frame];
        if (frame.resultType) {
            if (frame.resultType == kBreak) {
                frame.resultType = kValue;
            }
            return result;
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"While(%@, %@, %@)", testExpr, whileSuite, elseSuite];
}

@end


@implementation ForStmt

+ (ForStmt *)stmtWithTargetExpr:(Expr *)targetExpr iterExpr:(Expr *)iterExpr forSuite:(Suite *)forSuite elseSuite:(Suite *)elseSuite {
    ForStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->targetExpr = targetExpr;
        stmt->iterExpr = iterExpr;
        stmt->forSuite = forSuite;
        stmt->elseSuite = elseSuite;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    Value *iter = [iterExpr evaluate:frame];
    if (frame.resultType) {
        return iter;
    }
    
    for (NSObject *value in (id<NSFastEnumeration>)iter) {
        Value *result = [targetExpr setValue:value frame:frame];
        if (frame.resultType) {
            return result;
        }
        
        result = [forSuite evaluate:frame];
        if (frame.resultType) {
            if (frame.resultType == kBreak) {
                frame.resultType = kValue;
            }
            return result;
        }
    }
    
    return [elseSuite evaluate:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"For(%@, %@, %@, %@)", targetExpr, iterExpr, forSuite, elseSuite];
}

@end


@implementation TryFinallyStmt

+ (TryFinallyStmt *)stmtWithTrySuite:(Suite *)trySuite finallySuite:(Suite *)finallySuite {
    TryFinallyStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->trySuite = trySuite;
        stmt->finallySuite = finallySuite;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    Value *result1 = [trySuite evaluate:frame];
    
    ResultType resultType = frame.resultType;
    
    Value *result2 = [finallySuite evaluate:frame];
    
    if (frame.resultType) {
        return result2;
    }
    
    frame.resultType = resultType;
    return result1;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TryFinally(%@, %@)", trySuite, finallySuite];
}

@end


@implementation TryExceptStmt

+ (TryExceptStmt *)stmtWithTrySuite:(Suite *)trySuite exceptClauses:(NSArray *)exceptClauses elseSuite:(Suite *)elseSuite {
    TryExceptStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->trySuite = trySuite;
        stmt->exceptClauses = [exceptClauses copy];
        stmt->elseSuite = elseSuite;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    Value *result = [trySuite evaluate:frame];
    if (frame.resultType) {
        if (frame.resultType == kException) {
            for (ExceptClause *exceptClause in exceptClauses) {
                Value *match = [exceptClause matches:result frame:frame];
                if (frame.resultType) {
                    return match;
                }
                if (match == [PyCore True]) {
                    return [exceptClause evaluate:result frame:frame];
                }
            }
        }
        return result;
    }
    
    return [elseSuite evaluate:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TryExcept(%@, %@, %@)", trySuite, exceptClauses, elseSuite];
}

@end


@implementation ExceptClause

+ (ExceptClause *)exceptClauseWithExceptionsExpr:(Expr *)exceptionsExpr name:(NSString *)name suite:(Suite *)suite {
    ExceptClause *clause = [[self alloc] init];
    if (clause) {
        clause->exceptionsExpr = exceptionsExpr;
        clause->name = [name copy];
        clause->suite = suite;
    }
    return clause;
}


- (Value *)matches:(Value *)value frame:(Frame *)frame {
    if (!exceptionsExpr) {
        return [PyCore True];
    }
    
    Value *result = [exceptionsExpr evaluate:frame];
    if (frame.resultType) {
        return result;
    }
    
    if ([result isKindOfClass:[NSArray class]]) {
        for (Value *r in (NSArray *)result) {
            if (matches(value, r)) {
                return [PyCore True];
            }
        }
    } else if (matches(value, result)) {
        return [PyCore True];
    }
    
    return [PyCore False];
}

- (Value *)evaluate:(Value *)value frame:(Frame *)frame {
    if (name) {
        [frame setLocalValue:value forName:name];
    }
    return [suite evaluate:frame];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"[%@, %@, %@]", exceptionsExpr, name, suite];
}

@end


@implementation DefStmt

+ (DefStmt *)stmtWithName:(NSString *)name params:(NSArray *)params defaults:(NSArray *)defexprs suite:(Suite *)suite {
    DefStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->name = [name copy];
        stmt->params = [params copy];
        stmt->defexprs = [defexprs copy];
        stmt->suite = suite;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    NSMutableArray *defaults = nil;
    if (defexprs) {
        defaults = [NSMutableArray arrayWithCapacity:[defexprs count]];
        for (Expr *expr in defexprs) {
            [defaults addObject:[expr evaluate:frame]];
        }
    }
    
    Function *function = [Function withName:name
                                     params:params
                                   defaults:defaults
                                      suite:suite
                                    globals:[frame globals]];
    [frame setLocalValue:function forName:name];
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Def(%@, %@, %@)", name, descriptionForArray(params), suite];
}

@end


@implementation ClassStmt

+ (ClassStmt *)stmtWithName:(NSString *)name superExpr:(Expr *)superExpr suite:(Suite *)suite {
    ClassStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->name = [name copy];
        stmt->superExpr = superExpr;
        stmt->suite = suite;
    }
    return stmt;
}


// TODO evaluate missing

- (NSString *)description {
    return [NSString stringWithFormat:@"Class(%@, %@, %@)", name, superExpr, suite];
}

@end


@implementation PassStmt

+ (Stmt *)stmt {
    return [[self alloc] init];
}

- (Value *)evaluate:(Frame *)frame {
    return nil;
}

- (NSString *)description {
    return @"Pass()";
}

@end


@implementation BreakStmt

+ (Stmt *)stmt {
    return [[self alloc] init];
}

- (Value *)evaluate:(Frame *)frame {
    frame.resultType = kBreak;
    return nil;
}

- (NSString *)description {
    return @"Break()";
}

@end


@implementation ReturnStmt

+ (Stmt *)stmtWithExpr:(Expr *)expr {
    ReturnStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->expr = expr;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    Value *value = [expr evaluate:frame];
    if (frame.resultType) {
        return value;
    }
    
    frame.resultType = kReturn;
    
    return value;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Return(%@)", expr];
}

@end


@implementation RaiseStmt

+ (Stmt *)stmtWithExpr:(Expr *)expr {
    RaiseStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->expr = expr;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    Value *value = [expr evaluate:frame];
    if (frame.resultType) {
        return value;
    }
    
    frame.resultType = kException;
    
    return value;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Raise(%@)", expr];
}

@end


@implementation AssignStmt

+ (Stmt *)stmtWithLeftExpr:(Expr *)leftExpr rightExpr:(Expr *)rightExpr {
    AssignStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->leftExpr = leftExpr;
        stmt->rightExpr = rightExpr;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    Value *value = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return value;
    }
    
    return [leftExpr setValue:value frame:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@, %@)", op(self), leftExpr, rightExpr];
}

@end


@implementation AddAssignStmt

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    return [leftExpr setValue:toNumber(asInteger(left) + asInteger(right)) frame:frame];
}

@end


@implementation SubAssignStmt

- (Value *)evaluate:(Frame *)frame {
    Value *left = [leftExpr evaluate:frame];
    if (frame.resultType) {
        return left;
    }
    
    Value *right = [rightExpr evaluate:frame];
    if (frame.resultType) {
        return right;
    }
    
    return [leftExpr setValue:toNumber(asInteger(left) - asInteger(right)) frame:frame];
}

@end


@implementation ExprStmt

+ (Stmt *)stmtWithExpr:(Expr *)expr {
    ExprStmt *stmt = [[self alloc] init];
    if (stmt) {
        stmt->expr = expr;
    }
    return stmt;
}


- (Value *)evaluate:(Frame *)frame {
    return [expr evaluate:frame];
}

- (NSString *)description {
    return [expr description];
}

@end
