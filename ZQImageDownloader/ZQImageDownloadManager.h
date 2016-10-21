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


@interface ZQDownloadToken : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) id downloadCancelToken;
@end


@interface ZQImageDownloadManager : NSObject
@property (nonatomic, assign) NSInteger maxConcurrentDownloads;
@property (nonatomic, assign) NSTimeInterval downloadTimeout;

+ (instancetype)sharedInstance;
- (id)downloadImageWithURL:(NSURL *)url progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock;
- (void)cancelAll;
- (void)cancel:(ZQDownloadToken *)token;
@end
