//
//  ViewController.m
//  Python IDE
//
//  Created by Justin Bush on 2015-12-07.
//  Copyright © 2015 Justin Bush. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    textView.delegate = self;
    
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
    
    self.textView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    // Load Code.txt
    NSString* documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* codeFile = [documentsDir stringByAppendingPathComponent:@"Code.txt"];
    NSString *codeString = [NSString stringWithContentsOfFile:codeFile encoding:NSUTF8StringEncoding error:NULL];
    textView.text = codeString;
    NSLog(@"Loaded Code.txt");
}

- (void)viewWillDisappear:(BOOL)animated {
    // Save text to Code.txt
    self.codeString = textView.text;
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/Code.txt", documentsDir];
    [self.codeString writeToFile:codeFile
                      atomically:NO
                        encoding:NSStringEncodingConversionAllowLossy
                           error:nil];
    NSLog(@"String: %@", self.codeString);
    NSLog(@"Saved text to Code.txt");
}

- (void)enterBackground:(NSNotification *)notification{
    [self saveFile];
}

- (void)saveFile {
    // Save text to Code.txt
    self.codeString = textView.text;
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/Code.txt", documentsDir];
    [self.codeString writeToFile:codeFile
                      atomically:NO
                        encoding:NSStringEncodingConversionAllowLossy
                           error:nil];
    NSLog(@"String: %@", self.codeString);
    NSLog(@"Saved text to Code.txt");
}

- (void)createFile {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *codeFile = [NSString stringWithFormat:@"%@/Code.txt", documentsDir];
    NSString *codeString = @"print(\"Hello, world\")";
    [codeString writeToFile:codeFile
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
    NSLog(@"Created Code.txt");
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
