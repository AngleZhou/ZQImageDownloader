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
@property (nonatomic, strong) NSArray *operationCallers;
@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (nonatomic, readwrite, getter=isFinished) BOOL finished;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableData *imageData;

@end

@implementation ZQImageDownloadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;



- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock {
    if (self = [super init]) {
        _request = request;
        _session = session;
        
        _blocks = [NSMutableArray array];
        
        _executing = NO;
        _finished = NO;
    }
    return self;
}


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

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    self.imageData = nil;
    
}

- (void)start {
    if (self.isCancelled) {
        self.finished = YES;
        [self reset];
        return;
    }
    
    self.dataTask = [self.session dataTaskWithRequest:self.request];
    [self.dataTask resume];
    for (ZQImageDownloadProgressBlock process in [self blocksForKey:kOperationProcessBlock]) {
        process(0);
    }
}

- (NSArray *)blocksForKey:(NSString *)key {
    NSMutableArray *mArr = [NSMutableArray array];
    for (NSDictionary *dic in self.blocks) {
        [mArr addObject:dic[key]];
    }
    return mArr;
}


#pragma mark - Private

- (void)doneBlocksWithImage:(UIImage *)image imageData:(NSData *)imageData error:(NSError *)error {
    NSArray *arrBlocks = [self blocksForKey:kOperationDoneBlock];
    dispatch_main_async_safe(^{
        for (ZQImageDownloadDoneBlock doneBlock in arrBlocks) {
            doneBlock(image, imageData, error);
        }
    });
}

#pragma mark - NSURLSessionTaskDelegate
//完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //
    if ([self blocksForKey:kOperationDoneBlock].count > 0) {
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
    
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"%@", response);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
    //progress handling
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    
}




@end
