//
//  ViewController.h
//  Python IDE
//
//  Created by Justin Bush on 2015-12-07.
//  Copyright © 2015 Justin Bush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "EditorView.h"
#import "BuildViewController.h"

@interface ViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) NSString *codeString;
@property (assign, nonatomic) IBOutlet EditorView *editorView;
@property (nonatomic, retain) BuildViewController *buildViewController;

- (void)saveFile;

@end
