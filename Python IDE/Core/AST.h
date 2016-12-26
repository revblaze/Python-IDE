//
//  AST.h
//  Python IDE
//
//  Created by Justin Bush on 2016-12-25.
//  Copyright © 2016 Justin Bush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Runtime.h"

#pragma mark Expression nodes

@interface Expr : NSObject

- (Value *)evaluate:(Frame *)frame;
- (Value *)setValue:(Value *)value frame:(Frame *)frame;

@end


@interface BinaryExpr : Expr {
    Expr *leftExpr;
    Expr *rightExpr;
}

+ (BinaryExpr *)exprWithLeftExpr:(Expr *)leftExpr rightExpr:(Expr *)rightExpr;

@end


@interface UnaryExpr : Expr {
    Expr *expr;
}

+ (UnaryExpr *)exprWithExpr:(Expr *)Expr;

@end


@interface IfExpr : Expr {
    Expr *testExpr;
    Expr *thenExpr;
    Expr *elseExpr;
}

+ (IfExpr *)exprWithTestExpr:(Expr *)testExpr thenExpr:(Expr *)thenExpr elseExpr:(Expr *)elseExpr;

@end


@interface OrExpr : BinaryExpr
@end


@interface AndExpr : BinaryExpr
@end


@interface NotExpr : UnaryExpr
@end


@interface LtExpr : BinaryExpr
@end


@interface GtExpr : BinaryExpr
@end


@interface LeExpr : BinaryExpr
@end


@interface GeExpr : BinaryExpr
@end


@interface EqExpr : BinaryExpr
@end


@interface NeExpr : BinaryExpr
@end


@interface InExpr : BinaryExpr
@end


@interface IsExpr : BinaryExpr
@end


@interface AddExpr : BinaryExpr
@end


@interface SubExpr : BinaryExpr
@end


@interface MulExpr : BinaryExpr
@end


@interface DivExpr : BinaryExpr
@end


@interface ModExpr : BinaryExpr
@end


@interface NegExpr : UnaryExpr
@end


@interface PosExpr : UnaryExpr
@end


@interface CallExpr : Expr {
    Expr *funcExpr;
    NSArray *argExprs;
}

+ (CallExpr *)exprWithFuncExpr:(Expr *)funcExpr argExprs:(NSArray *)argExprs;

@end


@interface IndexExpr : Expr {
    Expr *expr;
    Expr *subscriptExpr;
}

+ (IndexExpr *)exprWithExpr:(Expr *)expr subscriptExpr:(Expr *)subscriptExpr;

@end


@interface AttrExpr : Expr {
    Expr *expr;
    NSString *name;
}

+ (AttrExpr *)exprWithExpr:(Expr *)expr name:(NSString *)name;

@end


@interface LiteralExpr : Expr {
    Value *value;
}

+ (LiteralExpr *)exprWithValue:(Value *)value;

@end


@interface VariableExpr : Expr {
    NSString *name;
}

+ (VariableExpr *)exprWithName:(NSString *)name;

@end


@interface TupleExpr : Expr {
    NSArray *exprs;
}

+ (Expr *)exprWithExprs:(NSArray *)exprs;

@end


@interface ListExpr : TupleExpr
@end


@interface SetExpr : TupleExpr
@end


@interface DictExpr : TupleExpr
@end


#pragma mark -
#pragma mark Statement nodes


@interface Stmt : NSObject

- (Value *)evaluate:(Frame *)frame;

@end


@interface Suite : Stmt {
    NSArray *stmts;
}

+ (Suite *)suiteWithPassStmt;
+ (Suite *)suiteWithStmt:(Stmt *)stmt;
+ (Suite *)suiteWithStmts:(NSArray *)stmts;

@end


@interface IfStmt : Stmt {
    Expr *testExpr;
    Suite *thenSuite;
    Suite *elseSuite;
}

+ (IfStmt *)stmtWithTestExpr:(Expr *)testExpr thenSuite:(Suite *)thenSuite elseSuite:(Suite *)elseSuite;

@end


@interface WhileStmt : Stmt {
    Expr *testExpr;
    Suite *whileSuite;
    Suite *elseSuite;
}

+ (WhileStmt *)stmtWithTestExpr:(Expr *)testExpr whileSuite:(Suite *)whileSuite elseSuite:(Suite *)elseSuite;

@end


@interface ForStmt : Stmt {
    Expr *targetExpr;
    Expr *iterExpr;
    Suite *forSuite;
    Suite *elseSuite;
}

+ (ForStmt *)stmtWithTargetExpr:(Expr *)targetExpr iterExpr:(Expr *)iterExpr forSuite:(Suite *)forSuite elseSuite:(Suite *)elseSuite;

@end


@interface TryFinallyStmt : Stmt {
    Suite *trySuite;
    Suite *finallySuite;
}

+ (TryFinallyStmt *)stmtWithTrySuite:(Suite *)trySuite finallySuite:(Suite *)finallySuite;

@end


@interface TryExceptStmt : Stmt {
    Suite *trySuite;
    NSArray *exceptClauses;
    Suite *elseSuite;
}

+ (TryExceptStmt *)stmtWithTrySuite:(Suite *)trySuite exceptClauses:(NSArray *)exceptClauses elseSuite:(Suite *)elseSuite;

@end


@interface ExceptClause : NSObject {
    Expr *exceptionsExpr;
    NSString *name;
    Suite *suite;
}

+ (ExceptClause *)exceptClauseWithExceptionsExpr:(Expr *)exceptionsExpr name:(NSString *)name suite:(Suite *)suite;

- (Value *)matches:(Value *)value frame:(Frame *)frame;
- (Value *)evaluate:(Value *)value frame:(Frame *)frame;

@end


@interface DefStmt : Stmt {
    NSString *name;
    NSArray *params;
    NSArray *defexprs;
    Suite *suite;
}

+ (DefStmt *)stmtWithName:(NSString *)name params:(NSArray *)params defaults:(NSArray *)defexprs suite:(Suite *)suite;

@end


@interface ClassStmt : Stmt {
    NSString *name;
    Expr *superExpr;
    Suite *suite;
}

+ (ClassStmt *)stmtWithName:(NSString *)name superExpr:(Expr *)superExpr suite:(Suite *)suite;

@end


@interface PassStmt : Stmt

+ (Stmt *)stmt;

@end


@interface BreakStmt : Stmt

+ (Stmt *)stmt;

@end


@interface ReturnStmt : Stmt {
    Expr *expr;
}

+ (Stmt *)stmtWithExpr:(Expr *)expr;

@end


@interface RaiseStmt : Stmt {
    Expr *expr;
}

+ (Stmt *)stmtWithExpr:(Expr *)expr;

@end


@interface AssignStmt : Stmt {
    Expr *leftExpr;
    Expr *rightExpr;
}

+ (Stmt *)stmtWithLeftExpr:(Expr *)leftExpr rightExpr:(Expr *)rightExpr;

@end


@interface AddAssignStmt : AssignStmt
@end


@interface SubAssignStmt : AssignStmt
@end


@interface ExprStmt : Stmt {
    Expr *expr;
}

+ (Stmt *)stmtWithExpr:(Expr *)expr;

@end
