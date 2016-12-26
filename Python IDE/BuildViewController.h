//
//  BuildViewController.h
//  Python IDE
//
//  Created by Justin Bush on 2015-12-07.
//  Copyright © 2015 Justin Bush. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildViewController : UIViewController

@property (nonatomic, strong) NSString *codeString;
@property (nonatomic, strong) NSString *consoleCode;
@property (nonatomic, retain) IBOutlet UITextView *consoleView;

@end
