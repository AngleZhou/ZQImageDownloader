//
//  ZQImageDownloadOperation.h
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ZQImageDownloadProgressBlock)(CGFloat progress);
typedef void(^ZQImageDownloadDoneBlock)(UIImage *image, NSData *data, NSError *error);
typedef void(^ZQImageDownloadCancelBlock)(void);

@interface ZQImageDownloadOperation : NSOperation <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLRequest *request;


@end
