//
//  StreamingUnzipper.h
//  amfetamine
//
//  Created by Sem Voigtländer on 19/11/2017.
//  Copyright © 2017 Sem Voigtländer. All rights reserved.
//

@interface StreamingUnzipper : NSObject {
    int  _activeCallbacks;
    void * _decompressionOutputBuffer;
    double  _lastExtractionProgressSent;
    long long  _sandboxToken;
    NSObject<OS_dispatch_queue> * inProcessDelegateQueue;
    NSObject * inProcessExtractorDelegate;
    NSXPCConnection * xpcConnection;
}

- (id)_beginNonStreamablePassthroughWithRemainingBytes:(const void*)arg1 length:(unsigned int)arg2;
- (void)_extractionEnteredPassThroughMode;
- (void)_sendExtractionCompleteAtArchivePath:(id)arg1;
- (void)_sendExtractionProgress:(double)arg1;
- (void)_setErrorState;
- (void)_supplyBytes:(const char *)arg1 length:(unsigned int)arg2 withReply:(id /* block */)arg3;
- (void)dealloc;
- (void)finishStreamWithReply:(id /* block */)arg1;
- (id)inProcessDelegateQueue;
- (id)inProcessExtractorDelegate;
- (id)init;
- (void)setActiveCallbacks:(int)arg1;
- (void)setInProcessDelegateQueue:(id)arg1;
- (void)setInProcessExtractorDelegate:(id)arg1;
- (void)setXpcConnection:(id)arg1;
- (void)setupUnzipperWithOutputPath:(id)arg1 sandboxExtensionToken:(char *)arg2 options:(id)arg3 withReply:(id /* block */)arg4;
- (void)supplyBytes:(id)arg1 withReply:(id /* block */)arg2;
- (void)suspendStreamWithReply:(id /* block */)arg1;
- (id)xpcConnection;

@end
