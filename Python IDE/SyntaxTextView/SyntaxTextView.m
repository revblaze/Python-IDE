//
//  SyntaxTextView.m
//  Python IDE
//
//  Created by Justin Bush on 2015-12-10.
//  Copyright © 2015 Justin Bush. All rights reserved.
//

#import "SyntaxTextView.h"
#import "LineNumberLayoutManager.h"

@implementation SyntaxTextView

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(NO, @"initWithCoder not allowed");
    return self;
}

- (id)initWithFrame:(CGRect) frame {
    NSTextStorage* ts = [[NSTextStorage alloc] init];
    LineNumberLayoutManager* lm = [[LineNumberLayoutManager alloc] init];
    NSTextContainer* tc = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    // Wrap text to the text view's frame
    tc.widthTracksTextView = YES;
    
    // Exclude the line number gutter from the display area available for text display.
    tc.exclusionPaths = @[[UIBezierPath bezierPathWithRect:CGRectMake(0.0, 0.0, 40.0, CGFLOAT_MAX)]];
    
    [lm addTextContainer:tc];
    [ts addLayoutManager:lm];
    
    if ((self = [super initWithFrame:frame textContainer:tc])) {
        self.contentMode = UIViewContentModeRedraw; // cause drawRect: to be called on frame resizing and divice rotation
        
        //  I'm finding that this text view is not behaving properly when typing into a new line at the end of the body
        //  of text.  The cursor is positioned inward, and then jumpts back to the propor position when a character is
        //  typed.  I'm sure this has something to do with the view's typingAttributes or one of the delegate methods.
        
        //self.typingAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:16.0],
        //                          NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]};
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    // Draw the line number gutter background
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0].CGColor);
    CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y, kLineNumberGutterWidth, bounds.size.height));
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextStrokeRect(context, CGRectMake(bounds.origin.x + 39.5, bounds.origin.y, 0.5, CGRectGetHeight(bounds)));
    
    [super drawRect:rect];
}

@end
