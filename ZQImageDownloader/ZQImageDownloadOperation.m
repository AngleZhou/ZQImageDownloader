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

@property (nonatomic, copy) ZQImageDownloadProgressBlock progressBlock;
@property (nonatomic, copy) ZQImageDownloadDoneBlock doneBlock;
@property (nonatomic, copy) ZQImageDownloadCancelBlock cancelBlock;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSData *imageData;
@end

@implementation ZQImageDownloadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;



- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock cancellation:(ZQImageDownloadCancelBlock)cancelBlock {
    if (self = [super init]) {
        _request = request;
        _progressBlock = [progressBlock copy];
        _doneBlock = [doneBlock copy];
        _cancelBlock = [cancelBlock copy];
        
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
    self.doneBlock = nil;
    self.imageData = nil;
    
}

- (void)start {
    if (self.isCancelled) {
        self.finished = YES;
        [self reset];
        return;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 15;
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
}

#pragma mark NSURLSessionTaskDelegate
//完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //
    if (error) {
        if (self.doneBlock) {
            self.doneBlock(nil, nil, error);
        }
    }
    else {
        if (self.doneBlock) {
            if (self.imageData) {
                UIImage *image = [UIImage imageWithData:self.imageData];//只考虑了jpg, png
                if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                    NSError *err = [NSError errorWithDomain:ZQImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image size is zero"}];
                    self.doneBlock(nil, nil, err);
                }
                else {
                    self.doneBlock(image, self.imageData, nil);
                }
            }
            else {
                NSError *err = [NSError errorWithDomain:ZQImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image Data is nil"}];
                self.doneBlock(nil, nil, err);
            }
        }
    }
    
    [self done];
}
//取消

//失败

//进度

@end
