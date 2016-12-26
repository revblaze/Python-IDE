//
//  Runtime.h
//  Python IDE
//
//  Created by Justin Bush on 2016-12-25.
//  Copyright © 2016 Justin Bush. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Expr;  // Forward declaration
@class Suite; // Forward declaration
@class Frame; // Forward declaration

typedef NSObject Value;

// Cause of raised exception
typedef enum { kValue, kReturn, kBreak, kException } ResultType;


@protocol PyCoreDelegate

- (void)print:(NSString *)string;

@end


// Beginning of the runtime system
@interface PyCore : NSObject {
    NSMutableDictionary *builtins;
    id<PyCoreDelegate> __weak delegate;
}

@property(nonatomic,weak) id<PyCoreDelegate> delegate;

+ (PyCore *)sharedInstance;

+ (NSObject *)True;
+ (NSObject *)False;
+ (NSObject *)None;

- (Frame *)newInitialFrame;

@end


// Stores variables (local and global)
@interface Frame : NSObject {
    NSMutableDictionary *locals;
    NSMutableDictionary *globals;
    PyCore *pyCore;
    ResultType resultType;
    NSArray *arguments;
}

@property(nonatomic, readonly) NSMutableDictionary *locals;
@property(nonatomic, readonly) NSMutableDictionary *globals;
@property(nonatomic, readonly) PyCore *pyCore;
@property(nonatomic, assign) ResultType resultType;
@property(nonatomic, retain) NSArray *arguments;

- (Frame *)initWithLocals:(NSMutableDictionary *)locals
                  globals:(NSMutableDictionary *)globals
                   pyCore:(PyCore *)pyCore;

- (NSObject *)localValueForName:(NSString *)name;
- (void)setLocalValue:(NSObject *)value forName:(NSString *)name;
- (NSObject *)globalValueForName:(NSString *)name;
- (void)setGlobalValue:(NSObject *)value forName:(NSString *)name;

- (Value *)typeError:(NSString *)message;
- (Value *)raise:(NSString *)exception;

@end


// Something you can call
@protocol Callable

- (Value *)call:(Frame *)frame;

@end


// Represents PyCore function objects
@interface Function : NSObject <Callable> {
    NSString *name;
    NSArray *params;
    NSArray *defaults;
    Suite *suite;
    NSMutableDictionary *globals;
}

+ (Function *)withName:(NSString *)name
                params:(NSArray *)params
              defaults:(NSArray *)defaults
                 suite:(Suite *)suite
               globals:(NSMutableDictionary *)globals;

- (Value *)call:(Frame *)frame;

@end


@interface BuiltinFunction : NSObject <Callable> {
    SEL selector;
}

+ (BuiltinFunction *)functionWithSelector:(SEL)selector;

- (Value *)call:(Frame *)frame;

- (Value *)print:(Frame *)frame;

@end


@interface BuiltinMethod : BuiltinFunction {
    Value *receiver;
}

+ (BuiltinMethod *)methodWithSelector:(SEL)selector receiver:(Value *)receiver;

@end


// Print PyCore objects
@interface NSObject (PyCore)

- (NSString *)__repr__;
- (NSString *)__str__;

@end
