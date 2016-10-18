//
//  ZQImageDownloadManager.m
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import "ZQImageDownloadManager.h"

@interface ZQImageDownloadManager ()
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@end

@implementation ZQImageDownloadManager

+ (instancetype)sharedInstance {
    static ZQImageDownloadManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}


@end
