//
//  ViewController.m
//  Python IDE
//
//  Created by Justin Bush on 2015-12-07.
//  Copyright © 2015 Justin Bush. All rights reserved.
//

#import "ViewController.h"
#import "NSString+AttributedStringConversion.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize codeString, editorView, buildViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // Check if Code.txt exists
    NSString* documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/Code.txt", documentsDir];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:codeFile];
    
    NSLog(@"viewWillAppear");
    
    if (fileExists == true) {
        // Code.txt does exist, continue to viewDidLoad
        NSLog(@"Code.txt does exist");
    }
    
    else if (fileExists == false) {
        // Code.txt does not exist, create the file
        NSLog(@"Code.txt does not exist");
        ViewController *viewController = [ViewController alloc];
        [viewController createFile];
    }
    
    // Attempt at getting the line numbered textView to work
    NSUInteger navBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    UIEdgeInsets insets = editorView.textView.contentInset;
    insets.top += navBarHeight;
    editorView.textView.contentInset = insets;
    
}

- (void)viewWillAppear:(BOOL)animated {
    // Load Code.txt
    NSString* documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* codeFile = [documentsDir stringByAppendingPathComponent:@"Code.txt"];
    NSString *codeString = [NSString stringWithContentsOfFile:codeFile encoding:NSUTF8StringEncoding error:NULL];
    NSAttributedString *formattedCode = [[NSAttributedString alloc]  initWithString:codeString];
    editorView.textView.attributedText = formattedCode;
    [editorView.textView setAttributedText:formattedCode];
    editorView.textView.selectable = YES;
    editorView.textView.font = [UIFont fontWithName:@"Menlo-Regular" size:12];
    NSLog(@"Loaded Code.txt");
    NSLog(@"String: %@", formattedCode);
}

- (void)viewWillDisappear:(BOOL)animated {
    // Save text to Code.txt
    codeString = editorView.textView.text;
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/Code.txt", documentsDir];
    [codeString writeToFile:codeFile
                      atomically:NO
                        encoding:NSStringEncodingConversionAllowLossy
                           error:nil];
    NSLog(@"String: %@", codeString);
    NSLog(@"Saved text to Code.txt");
}

- (void)enterBackground:(NSNotification *)notification{
    // Save if user has entered background
    [self saveFile];
}

- (void)saveFile {
    // Save text to Code.txt
    codeString = editorView.textView.text;
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/Code.txt", documentsDir];
    [codeString writeToFile:codeFile
                      atomically:NO
                        encoding:NSStringEncodingConversionAllowLossy
                           error:nil];
    NSLog(@"String: %@", codeString);
    NSLog(@"Saved text to Code.txt");
}

- (void)createFile {
    // Creates file Code.txt with print("Hello, world")
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/Code.txt", documentsDir];
    NSString *codeString = @"print(\"Hello, world!\")";
    [codeString writeToFile:codeFile
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
    NSLog(@"Created Code.txt");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Push Code.txt content to buildView
    BuildViewController *buildView = [segue destinationViewController];
    buildView.codeString = editorView.textView.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
