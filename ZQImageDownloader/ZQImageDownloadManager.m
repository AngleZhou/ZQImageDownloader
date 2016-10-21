//
//  ZQImageDownloadManager.m
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import "ZQImageDownloadManager.h"
#import "ZQImageDownloadOperation.h"


@implementation ZQDownloadToken

@end



@interface ZQImageDownloadManager () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableDictionary <NSURL*, ZQImageDownloadOperation*> *operations;//方便查找, 需要在operation创建，取消或者完成时更新
@end

@implementation ZQImageDownloadManager

#pragma mark - life cycle

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

//<A,B,C>同时调用，
- (void)cancel:(ZQDownloadToken *)token {
    dispatch_barrier_async(self.barrierQueue, ^{
        ZQImageDownloadOperation *op = self.operations[token.url];
        BOOL bCancel = [op cancel:token];
        if (bCancel) {
            [self.operations removeObjectForKey:token.url];
        }
    });
    
}
- (void)cancelAll {
    [self.downloadQueue cancelAllOperations];
    [self.operations removeAllObjects];
}

#pragma mark - Public API

+ (instancetype)sharedInstance {
    static ZQImageDownloadManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

//<A,B,C>同时调用，需要对同一个Operation的hanlders修改，每个object一个唯一的cancelToken
- (id)downloadImageWithURL:(NSURL *)url progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock {
    if (!url) {
        return nil;
    }
    
    __block ZQDownloadToken *downloadToken;
    //同步执行以便返回，栅栏块防止handlers被A,B,C同时修改
    dispatch_barrier_sync(self.barrierQueue, ^{
        ZQImageDownloadOperation *operation = self.operations[url];
        if (!operation) {
            if (self.downloadTimeout == 0.0) {
                self.downloadTimeout = 30.0;
            }
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:self.downloadTimeout];
            operation = [[ZQImageDownloadOperation alloc] initWithRequest:request inSession:self.session progress:progressBlock completion:doneBlock];
            operation.completionBlock = ^{
                [self.operations removeObjectForKey:url];
            };
            [self.downloadQueue addOperation:operation];
            self.operations[url] = operation;
        }
        
        id opHandler = [operation addHandlersOfProgressBlock:progressBlock doneBlock:doneBlock];
        downloadToken = [ZQDownloadToken new];
        downloadToken.url = url;
        downloadToken.downloadCancelToken = opHandler;
    });

    return downloadToken;
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
