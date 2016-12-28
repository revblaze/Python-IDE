//
//  ViewController.m
//  Python IDE
//
//  Created by Justin Bush on 2015-12-07.
//  Copyright © 2015 Justin Bush. All rights reserved.
//

#import "ViewController.h"
#import "NSString+AttributedStringConversion.h"
#import "Tester.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize tempCode, codeString, editorView, buildViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Check if File.py exists
    NSString* documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/File.py", documentsDir];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:codeFile];
    
    NSLog(@"viewWillAppear");
    
    if (fileExists == true) {
        // File.py does exist, continue to viewDidLoad
        NSLog(@"File.py does exist");
    }
    
    else if (fileExists == false) {
        // File.py does not exist, create the file
        NSLog(@"File.py does not exist");
        ViewController *viewController = [ViewController alloc];
        [viewController createFile];
    }
    
    // Create a new Python runtime
    pyCore = [[PyCore alloc] init];
    pyCore.delegate = self;
    mode = 0;
    
    // Attempt at getting the line numbered textView to work
    NSUInteger navBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    UIEdgeInsets insets = editorView.textView.contentInset;
    insets.top += navBarHeight;
    editorView.textView.contentInset = insets;
    
}

- (void)viewWillAppear:(BOOL)animated {
    // Load File.py
    NSString* documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* codeFile = [documentsDir stringByAppendingPathComponent:@"File.py"];
    NSString *codeString = [NSString stringWithContentsOfFile:codeFile encoding:NSUTF8StringEncoding error:NULL];
    NSAttributedString *formattedCode = [[NSAttributedString alloc]  initWithString:codeString];
    
    // Format editor
    editorView.textView.attributedText = formattedCode;
    [editorView.textView setAttributedText:formattedCode];
    editorView.textView.selectable = YES;
    editorView.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    editorView.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    editorView.textView.font = [UIFont fontWithName:@"Menlo-Regular" size:13];
    tempCode = @"";
    NSLog(@"Loaded File.py");
}

- (void)viewWillDisappear:(BOOL)animated {
    // Save code to File.py
    [self saveFile];
    NSLog(@"Saved code to File.py");
}

- (void)enterBackground:(NSNotification *)notification{
    // Save if user has entered background
    [self saveFile];
}

- (void)saveFile {
    // Save code to File.py
    codeString = editorView.textView.text;
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/File.py", documentsDir];
    [codeString writeToFile:codeFile
                      atomically:NO
                        encoding:NSStringEncodingConversionAllowLossy
                           error:nil];
    NSLog(@"Saved code to File.py");
}

- (void)createFile {
    // Creates file File.py with print("Hello, world")
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/File.py", documentsDir];
    NSString *codeString = @"print(\"Hello, world!\")\n";
    [codeString writeToFile:codeFile
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
    NSLog(@"Created File.py");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark -
#pragma mark Run Python code

- (void)_appendStringToOutputView:(NSString *)string {
    codeString = [codeString stringByAppendingFormat: string, @"%@\n"];
}

// Return PyCore callback
- (void)print:(NSString *)string {
    [self _appendStringToOutputView:string];
    NSString *lineToAdd = (@"%@", string);
    tempCode = [NSString stringWithFormat:@"%@\n%@", tempCode, lineToAdd];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Run Python Compiler
    [editorView.textView resignFirstResponder];
    
    Parser *parser = [[Parser alloc] initWithString:editorView.textView.text];
    Suite *suite;
    
    @try {
        suite = [parser parse_file];
    }
    
    @catch (NSException *exception) {
        [self _appendStringToOutputView:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
        return;
    }
    
    @finally {
        // Do nothing
    }
    
    if (mode) {
        [self _appendStringToOutputView:[suite description]];
        return;
    }
    
    Frame *frame = [pyCore newInitialFrame];
    
    @try {
        [suite evaluate:frame];
    }
    
    @catch (NSException *exception) {
        [self _appendStringToOutputView:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
        return;
    }
    
    @finally {
        // Do nothing
    }
    
    // Push File.py content to buildView
    BuildViewController *buildView = [segue destinationViewController];
    buildView.codeString = tempCode;
}

- (IBAction)exportFile:(id) sender {
    // Save code to File.py
    [self saveFile];
    NSLog(@"Saved code to File.py");
    NSLog(@"Preparing for export");
    
    // Export file using UIDocumentInteractionController
    NSURL * myURL = [NSURL fileURLWithPath:[self getFilePath]];
    _docExportController = [UIDocumentInteractionController interactionControllerWithURL:myURL];
    if(![_docExportController presentOpenInMenuFromRect:[self.view frame] inView:self.view animated:YES]) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You don't have a compatible app." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSString*)getFilePath{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0];
    
    NSString * fileName = [documentDirectory stringByAppendingString:@"/File.py"];
    return fileName;
}

- (void)keyboardWasShown:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.editorView.textView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    self.editorView.textView.scrollIndicatorInsets = self.editorView.textView.contentInset;
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    self.editorView.textView.contentInset = UIEdgeInsetsZero;
    self.editorView.textView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
