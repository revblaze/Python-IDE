//
//  Runtime.m
//  Python IDE
//
//  Created by Justin Bush on 2016-12-25.
//  Copyright © 2016 Justin Bush. All rights reserved.
//

#import "Runtime.h"
#import "AST.h"

#pragma mark Runtime object

@implementation PyCore

@synthesize delegate;

+ (PyCore *)sharedInstance {
    static PyCore *instance;
    if (!instance) {
        instance = [[PyCore alloc] init];
    }
    return instance;
}

+ (NSObject *)True {
    static NSObject *True = nil;
    if (!True) {
        True = [[NSNumber alloc] initWithBool:YES];
    }
    return True;
}

+ (NSObject *)False {
    static NSObject *False = nil;
    if (!False) {
        False = [[NSNumber alloc] initWithBool:NO];
    }
    return False;
}

+ (NSObject *)None {
    static NSObject *None = nil;
    if (!None) {
        None = [NSNull null];
    }
    return None;
}

- (id)init {
    if ((self = [super init])) {
        self->builtins = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          [PyCore None], @"None",
                          [PyCore True], @"True",
                          [PyCore False], @"False",
                          [BuiltinFunction functionWithSelector:@selector(print:)], @"print",
                          [BuiltinFunction functionWithSelector:@selector(len:)], @"len",
                          nil];
    }
    
    return self;
}


- (Frame *)newInitialFrame {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:builtins forKey:@"__builtins__"];
    Frame *initialFrame = [[Frame alloc] initWithLocals:dict globals:dict pyCore:self];
    
    return initialFrame;
}

@end


#pragma mark -
#pragma mark Frame object

@implementation Frame

@synthesize locals;
@synthesize globals;
@synthesize pyCore;
@synthesize resultType;
@synthesize arguments;

- (Frame *)initWithLocals:(NSMutableDictionary *)locals_
                  globals:(NSMutableDictionary *)globals_
                   pyCore:(PyCore *)pyCore_ {
    if ((self = [self init])) {
        locals = locals_;
        globals = globals_;
        pyCore = pyCore_;
    }
    return self;
}

- (NSObject *)localValueForName:(NSString *)name {
    return [locals objectForKey:name];
}

- (void)setLocalValue:(NSObject *)value forName:(NSString *)name {
    [locals setObject:value forKey:name];
}

- (NSObject *)globalValueForName:(NSString *)name {
    NSObject *value = [globals objectForKey:name];
    if (!value) {
        value = [globals objectForKey:@"__builtins__"];
        value = [(NSDictionary *)value objectForKey:name];
    }
    return value;
}

- (void)setGlobalValue:(NSObject *)value forName:(NSString *)name {
    [globals setObject:value forKey:name];
}

- (Value *)typeError:(NSString *)message {
    self.resultType = kException;
    return [@"TypeError: " stringByAppendingString:message];
}

- (Value *)raise:(NSString *)exception {
    self.resultType = kException;
    return exception;
}

@end


#pragma mark -
#pragma mark Function objects

@implementation Function

+ (Function *)withName:(NSString *)name
                params:(NSArray *)params
              defaults:(NSArray *)defaults
                 suite:(Suite *)suite
               globals:(NSMutableDictionary *)globals {
    Function *function = [[self alloc] init];
    if (function) {
        function->name = [name copy];
        function->params = [params copy];
        function->defaults = [defaults copy];
        function->suite = suite;
        function->globals = globals;
    }
    return function;
}

- (Value *)call:(Frame *)frame {
    NSUInteger acount = [frame.arguments count];
    NSUInteger pcount = [params count];
    NSUInteger dcount = [defaults count];
    
    if (acount > pcount || acount < pcount - dcount) {
        return [frame typeError:@"Wrong number of arguments"];
    }
    
    NSMutableDictionary *locals = [[NSMutableDictionary alloc] initWithCapacity:pcount];
    
    for (NSUInteger i = 0; i < acount; i++) {
        [locals setObject:[frame.arguments objectAtIndex:i] forKey:[params objectAtIndex:i]];
    }
    for (NSUInteger i = acount; i < pcount; i++) {
        [locals setObject:[defaults objectAtIndex:i + dcount - pcount] forKey:[params objectAtIndex:i]];
    }
    
    frame.arguments = nil;
    
    Frame *newFrame = [[Frame alloc] initWithLocals:locals globals:globals pyCore:frame.pyCore];
    
    
    Value *result = [(Suite *)suite evaluate:newFrame];
    if (newFrame.resultType) {
        if (newFrame.resultType == kReturn) {
            newFrame.resultType = kValue;
        }
        if (newFrame.resultType == kBreak) {
            result = [newFrame raise:@"SyntaxError: 'Break' outside loop"];
        }
    }
    
    frame.resultType = newFrame.resultType;
    
    
    return result;
}

@end


@implementation BuiltinFunction

+ (BuiltinFunction *)functionWithSelector:(SEL)selector {
    BuiltinFunction *bf = [[self alloc] init];
    if (bf) {
        bf->selector = selector;
    }
    return bf;
}

- (Value *)call:(Frame *)frame {
    Value *result = [self performSelector:selector withObject:frame];
    frame.arguments = nil;
    return result;
}

- (Value *)print:(Frame *)frame {
    if ([frame.arguments count] != 1) {
        return [frame typeError:@"print(): Wrong number of arguments"];
    }
    
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    BOOL first = YES;
    for (NSObject *argument in frame.arguments) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@" "];
        }
        [buffer appendString:[argument __str__]];
    }
    [frame.pyCore.delegate print:buffer];
    
    
    return nil;
}

- (Value *)len:(Frame *)frame {
    if ([frame.arguments count] != 1) {
        return [frame typeError:@"len(): Wrong number of arguments"];
    }
    
    Value *arg = [frame.arguments objectAtIndex:0];
    
    if ([arg isKindOfClass:[NSString class]]) {
        return [NSNumber numberWithInteger:[(NSString *)arg length]];
    }
    if ([arg respondsToSelector:@selector(count)]) {
        return [NSNumber numberWithInteger:[(NSArray *)arg count]];
    }
    
    return [frame typeError:@"Object has no len()"];
}

@end


@implementation BuiltinMethod

+ (BuiltinMethod *)methodWithSelector:(SEL)selector receiver:(Value *)receiver {
    BuiltinMethod *method = [[self alloc] init];
    if (method) {
        method->selector = selector;
        method->receiver = receiver;
    }
    return method;
}

- (Value *)append:(Frame *)frame {
    if ([frame.arguments count] != 1) {
        return [frame typeError:@"append(): Wrong number of arguments"];
    }
    
    [(NSMutableArray *)receiver addObject:[frame.arguments objectAtIndex:0]];
    
    return nil;
}

@end


#pragma mark -
#pragma mark Foundation class extensions

@implementation NSObject (PyCore)

- (NSString *)__repr__ {
    return [self description];
}

- (NSString *)__str__ {
    return [self __repr__];
}

@end


@implementation NSString (PyCore)

- (NSString *)__repr__ {
    NSString *singleQuote = @"\'";
    NSString *doubleQuote = @"\"";
    
    BOOL useDoubleQuote = [self rangeOfString:singleQuote].location != NSNotFound
    && [self rangeOfString:doubleQuote].location == NSNotFound;
    NSString *quote = useDoubleQuote ? doubleQuote : singleQuote;
    
    NSString *string = self;
    string = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    if (!useDoubleQuote) {
        string = [string stringByReplacingOccurrencesOfString:singleQuote withString:@"\\'"];
    }
    return [NSString stringWithFormat:@"%@%@%@", quote, string, quote];
}

- (NSString *)__str__ {
    return self;
}

@end


@implementation NSArray (PyCore)

- (NSString *)__repr__ {
    NSMutableString *buffer = [NSMutableString string];
    [buffer appendString:@"("];
    BOOL first = YES;
    for (NSObject *value in self) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[value __repr__]];
    }
    if ([self count] == 1) {
        [buffer appendString:@","];
    }
    [buffer appendString:@")"];
    return buffer;
}

@end


@implementation NSMutableArray (PyCore)

- (NSString *)__repr__ {
    NSMutableString *buffer = [NSMutableString string];
    [buffer appendString:@"["];
    BOOL first = YES;
    for (NSObject *value in self) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[value __repr__]];
    }
    [buffer appendString:@"]"];
    return buffer;
}

@end


@implementation NSMutableSet (PyCore)

- (NSString *)__repr__ {
    if (![self count]) {
        return @"set()";
    }
    NSMutableString *buffer = [NSMutableString string];
    [buffer appendString:@"{"];
    BOOL first = YES;
    for (NSObject *value in self) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[value __repr__]];
    }
    [buffer appendString:@"}"];
    return buffer;
}

@end


@implementation NSMutableDictionary (PyCore)

- (NSString *)__repr__ {
    NSMutableString *buffer = [NSMutableString string];
    [buffer appendString:@"{"];
    BOOL first = YES;
    for (NSObject *key in self) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[key __repr__]];
        [buffer appendString:@": "];
        [buffer appendString:[[self objectForKey:key] __repr__]];
    }
    [buffer appendString:@"}"];
    return buffer;
}

@end


@implementation NSNull (PyCore)

- (NSString *)__repr__ {
    return @"None";
}

@end
