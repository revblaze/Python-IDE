//
//  EditorView.m
//  Python IDE
//
//  Created by Justin Bush on 2015-12-10.
//  Copyright © 2015 Justin Bush. All rights reserved.
//
//  This class is here so that we can use a storyboard.  This is required because we must use the UITextView's
//  -[initWithFrame:textContainer:] initializer in order to substitute our own layout manager.  This cannot be done
//  using UITextView's -[initWithCoder:] initializer which is the one used whe views are created from a storyboard.
//

#import "EditorView.h"

@implementation EditorView

@synthesize textView;

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        textView.selectable = YES;
        textView = [[SyntaxTextView alloc] initWithFrame:self.bounds];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textView.font = [UIFont fontWithName:@"Menlo-Regular" size:14];
        [self addSubview:textView];
    }
    return self;
}

@end
