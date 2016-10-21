//
//  ZQImageDownloadManager.h
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZQImageDownloadHeader.h"
#import "ZQImageDownloadOperation.h"


/**
 *  unique for every call, even with the same url.
 */
@interface ZQDownloadToken : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) id downloadCancelToken;
@end


/**
 *  Only deal with download
 */
@interface ZQImageDownloadManager : NSObject
@property (nonatomic, assign) NSInteger maxConcurrentDownloads;
@property (nonatomic, assign) NSTimeInterval downloadTimeout;

/**
 *  Singleton method, returns the shared instance
 *
 *  @return global shared instance of ZQImageDownloadManager class
 */
+ (instancetype)sharedInstance;


/**
 *  Download an image from internet, and return in doneBlock.
 *
 *  @return an ZQDownloadToken object. Unique for every call. Same url will share the same operation. <A, B, C>3个请求的URL地址相同， 只创建一个下载任务，下载完成后再分别调用<A, B, C>各自的completion.
 */
- (ZQDownloadToken *)downloadImageWithURL:(NSURL *)url progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock;

/**
 *  Generate an operaton for downloading. For testing purpose.
 *
 *  @return an ZQImageDownloadOperation object. Same url will share the same operation. <A, B, C>3个请求的URL地址相同， 只创建一个下载任务，返回同一个operation.
 */
- (ZQImageDownloadOperation *)operationWithURL:(NSURL *)url progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock;

/**
 *  Cancel all operations.
 */
- (void)cancelAll;
/**
 *  Cancel one operation.
 *  @param token    Unique for every call
 */
- (void)cancel:(ZQDownloadToken *)token;
@end
