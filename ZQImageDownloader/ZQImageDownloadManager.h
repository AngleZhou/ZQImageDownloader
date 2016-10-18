//
//  ZQImageDownloadManager.h
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ZQImageDownloadProgressBlock)(CGFloat progress);
typedef void(^ZQImageDownloadDoneBlock)(void);

@interface ZQImageDownloadManager : NSObject
@property (assign, nonatomic) NSInteger maxConcurrentDownloads;
@property (assign, nonatomic) NSTimeInterval downloadTimeout;

- (id)downloadImageWithURL:(NSURL *)url progress:(ZQImageDownloadProgressBlock)progressBlock completion:(ZQImageDownloadDoneBlock)doneBlock;
@end
