//
//  ZQImageDownloadOperation.m
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import "ZQImageDownloadOperation.h"

NSString *const ZQImageErrorDomain = @"ZQImageErrorDomain";

@interface ZQImageDownloadOperation ()
@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (nonatomic, readwrite, getter=isFinished) BOOL finished;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableData *imageData;

@property (nonatomic, strong) dispatch_queue_t barrierQueue;

@end

@implementation ZQImageDownloadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;



- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock {
    if (self = [super init]) {
        _request = request;
        _session = session;
        
        _expectedSize = 0;
        
        _handlers = [NSMutableArray array];
        _barrierQueue = dispatch_queue_create("com.ZQImageDownloadOperation.barrierQueue", DISPATCH_QUEUE_CONCURRENT);
        
        _executing = NO;
        _finished = NO;
    }
    return self;
}

//异步operation
- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}
- (BOOL)isAsynchronous {
    return YES;
}

#pragma mark - Public API

//保留<A, B, C>不同的处理
- (id)addHandlersOfProgressBlock:(ZQImageDownloadProgressBlock)progressBlock doneBlock:(ZQImageDownloadDoneBlock)doneBlock {
    ZQHandlersDictionary *hd = [ZQHandlersDictionary new];
    if (progressBlock) {
        hd[kOperationProcessBlock] = [progressBlock copy];
    }
    if (doneBlock) {
        hd[kOperationDoneBlock] = [doneBlock copy];
    }
    //写栅栏异步
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.handlers addObject:hd];
    });
    return hd;
}

//<A, B, c>url相同，同一个Operation，A取消，B,C仍执行
- (BOOL)cancel:(id)cancelToken {
    __block BOOL shouldCancel = NO;
    dispatch_barrier_sync(self.barrierQueue, ^{
        [self.handlers removeObjectIdenticalTo:cancelToken];
        if (self.handlers.count == 0) {
            shouldCancel = YES;
        }
    });
    //所有调用者都取消了这个Operation
    if (shouldCancel) {
        [self cancel];
    }
    return shouldCancel;
}

#pragma mark - Status

- (void)cancel {
    if (self.isFinished) {
        return;
    }
    
    @synchronized (self) {
        if (self.dataTask) {
            [self.dataTask cancel];
        }
    }
    if (!self.isFinished) {
        self.finished = YES;
    }
    if (self.isExecuting) {
        self.executing = NO;
    }
    
    [self reset];
}
- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    self.imageData = nil;
    self.dataTask = nil;
    [self.handlers removeAllObjects];
    self.request = nil;
}

- (void)start {
    if (self.isCancelled) {
        self.finished = YES;
        [self reset];
        return;
    }
    
    @synchronized (self) {
        self.dataTask = [self.session dataTaskWithRequest:self.request];
        [self.dataTask resume];
    }
    
    for (ZQImageDownloadProgressBlock process in [self handlersForKey:kOperationProcessBlock]) {
        process(0, 0);
    }
}

- (NSArray *)handlersForKey:(NSString *)key {
    NSMutableArray *mArr = [NSMutableArray array];
    for (NSDictionary *dic in self.handlers) {
        [mArr addObject:dic[key]];
    }
    return mArr;
}


#pragma mark - Private

- (void)doneBlocksWithImage:(UIImage *)image imageData:(NSData *)imageData error:(NSError *)error {
    NSArray *arrBlocks = [self handlersForKey:kOperationDoneBlock];
    dispatch_main_async_safe(^{
        for (ZQImageDownloadDoneBlock doneBlock in arrBlocks) {
            doneBlock(image, imageData, error);
        }
    });
}

#pragma mark - NSURLSessionTaskDelegate
//完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    @synchronized (self) {
        self.dataTask = nil;
    }
    
    if ([self handlersForKey:kOperationDoneBlock].count > 0) {
        if (error) {
            [self doneBlocksWithImage:nil imageData:nil error:error];
        }
        else {
            if (self.imageData) {
                UIImage *image = [UIImage imageWithData:self.imageData];//只考虑了jpg, png
                if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                    NSError *err = [NSError errorWithDomain:ZQImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image size is zero"}];
                    [self doneBlocksWithImage:nil imageData:nil error:err];
                }
                else {
                    [self doneBlocksWithImage:image imageData:self.imageData error:nil];
                }
            }
            else {
                NSError *err = [NSError errorWithDomain:ZQImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image Data is nil"}];
                [self doneBlocksWithImage:nil imageData:nil error:err];
            }
            
        }
    }
    
    
    [self done];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        disposition = NSURLSessionAuthChallengeUseCredential;
    } else {
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"%@", response);
    self.expectedSize = ((NSHTTPURLResponse *)response).expectedContentLength;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
    //progress handling
    for (ZQImageDownloadProgressBlock progressBlock in [self handlersForKey:kOperationProcessBlock]) {
        progressBlock(self.imageData.length, self.expectedSize);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    
}




@end
