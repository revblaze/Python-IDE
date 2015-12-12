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

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.textView = [[SyntaxTextView alloc] initWithFrame:self.bounds];
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.textView];
    }
    return self;
}

@end
