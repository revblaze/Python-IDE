//
//  EditorView.h
//  Python IDE
//
//  Created by Justin Bush on 2015-12-10.
//  Copyright © 2015 Justin Bush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyntaxTextView.h"

@interface EditorView : UIView

@property (nonatomic) SyntaxTextView *textView;

@end
