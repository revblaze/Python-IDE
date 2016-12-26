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
#import "Parser.h"
#import "Runtime.h"

@interface ViewController : UIViewController <UITextViewDelegate, PyCoreDelegate> {
    NSInteger mode;
    PyCore *pyCore;
}

@property (nonatomic, strong) NSString *tempCode;
@property (nonatomic, strong) NSString *codeString;
@property (assign, nonatomic) IBOutlet EditorView *editorView;
@property (nonatomic, retain) BuildViewController *buildViewController;
@property (strong, nonatomic) UIDocumentInteractionController * docExportController;

- (void)saveFile;

@end
