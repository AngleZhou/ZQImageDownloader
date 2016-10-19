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


@interface ZQImageDownloadManager : NSObject
@property (nonatomic, assign) NSInteger maxConcurrentDownloads;
@property (nonatomic, assign) NSTimeInterval downloadTimeout;

- (id)downloadImageWithURL:(NSURL *)url progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock;
@end
