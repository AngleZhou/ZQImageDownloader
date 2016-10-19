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




@interface ZQImageDownloadOperation : NSOperation <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
/**
 *  用来保存不同调用者的处理，调用者请求的url相同
 */
@property (nonatomic, strong) NSMutableArray *blocks;

- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock;



@end
