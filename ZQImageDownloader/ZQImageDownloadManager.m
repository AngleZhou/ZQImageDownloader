//
//  ZQImageDownloadManager.m
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import "ZQImageDownloadManager.h"
#import "ZQImageDownloadOperation.h"

@interface ZQImageDownloadManager () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableDictionary <NSURL*, ZQImageDownloadOperation*> *operations;
@end

@implementation ZQImageDownloadManager

+ (instancetype)sharedInstance {
    static ZQImageDownloadManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)config {
    if (self = [super init]) {
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 5;
        _barrierQueue = dispatch_queue_create("com.ZQImageDownloadManager.barrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _operations = [NSMutableDictionary new];
    }
    return self;
}
- (void)dealloc {
    [_downloadQueue cancelAllOperations];
    [_session invalidateAndCancel];
    _session = nil;
}

#pragma mark - Public API

- (id)downloadImageWithURL:(NSURL *)url progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock {
    if (!url) {
        return nil;
    }
    
    ZQImageDownloadOperation *operation = self.operations[url];
    if (!operation) {
        if (self.downloadTimeout == 0.0) {
            self.downloadTimeout = 30.0;
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:self.downloadTimeout];
        operation = [[ZQImageDownloadOperation alloc] initWithRequest:request inSession:self.session progress:progressBlock completion:doneBlock];
        [self.downloadQueue addOperation:operation];
        self.operations[url] = operation;
    }
    
    NSDictionary *dic = @{kOperationProcessBlock : progressBlock,
                          kOperationDoneBlock : doneBlock};
    [operation.blocks addObject:dic];
    
    
    return operation;
}



#pragma mark - Private

- (ZQImageDownloadOperation *)operationForDataTask:(NSURLSessionTask *)task {
    for (ZQImageDownloadOperation *op in self.downloadQueue.operations) {
        if (op.dataTask.taskIdentifier == task.taskIdentifier) {
            return op;
        }
    }
    return nil;
}



/**
 *  All network repsonses from Task Delegate and Data Delegate are passed to operation.
 *
 */

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    ZQImageDownloadOperation *op = [self operationForDataTask:task];
    [op URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    ZQImageDownloadOperation *op = [self operationForDataTask:task];
    [op URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    ZQImageDownloadOperation *op = [self operationForDataTask:dataTask];
    [op URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    ZQImageDownloadOperation *op = [self operationForDataTask:dataTask];
    [op URLSession:session dataTask:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    ZQImageDownloadOperation *op = [self operationForDataTask:dataTask];
    [op URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}



@end
