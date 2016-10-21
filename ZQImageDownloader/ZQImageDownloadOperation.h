//
//  ZQImageDownloadOperation.h
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZQImageDownloadHeader.h"


typedef NSMutableDictionary<NSString*, id> ZQHandlersDictionary;

@interface ZQImageDownloadOperation : NSOperation <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
/**
 *  用来保存不同调用者的处理，调用者请求的url相同
 */
@property (nonatomic, strong) NSMutableArray *handlers;
@property (nonatomic, assign) NSInteger expectedSize;

/**
 *  Init an ZQImageDownloadOperation object.
 
 *  @return ZQImageDownloadOperation
 
 *  @param  request         request to download image from a url
 *  @param  session         the session which download tasks run on.
 *  @param  progressBlock   progress callback.
 *  @param  doneBlock       completion callback.
 */
- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock;

/**
 *  Cancel an download operation
 */
- (BOOL)cancel:(id)cancelToken;

/**
 *  Bind process Blocks of the same url to one operation. 
 
 *  @return an object to identify every call.
 */
- (id)addHandlersOfProgressBlock:(ZQImageDownloadProgressBlock)progressBlock doneBlock:(ZQImageDownloadDoneBlock)doneBlock;



@end
