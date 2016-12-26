//
//  BuildViewController.m
//  Python IDE
//
//  Created by Justin Bush on 2015-12-07.
//  Copyright © 2015 Justin Bush. All rights reserved.
//

#import "BuildViewController.h"
#import "ViewController.h"

@class ViewController;

@interface BuildViewController ()

@end

@implementation BuildViewController

@synthesize codeString, consoleCode, consoleView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Console";
    
    
    // Setup consoleView
    self.consoleView.selectable = YES;
    self.consoleView.editable = NO;
    self.consoleView.font = [UIFont fontWithName:@"Menlo-Regular" size:14];
    
}

- (void)viewDidAppear:(BOOL)animated {
    // Preparation for saved console history
    if (![consoleCode isEqual: @""]) {
        consoleCode = @"";
        
        // consoleCode = [NSString stringWithFormat:@"%@\n%@", codeString, consoleCode];
        
        consoleCode = [codeString stringByAppendingString: consoleCode];
        
        // consoleCode = [@">>>" stringByAppendingString: consoleCode];
        
        consoleCode = [consoleCode stringByReplacingOccurrencesOfString: @"\n" withString:@"\n>>> "];
        self.consoleView.text = consoleCode;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
