//
//  ZQImageManager.m
//  ZQImageDownloader
//
//  Created by Angle on 16/10/21.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import "ZQImageManager.h"
#import "ZQImageCache.h"
#import "ZQImageDownloadManager.h"


@interface ZQImageManager ()
@property (nonatomic, strong) ZQImageCache *cacheManager;
@property (nonatomic, strong) ZQImageDownloadManager *downloadManager;
@end

@implementation ZQImageManager

+ (instancetype)sharedInstance {
    static ZQImageManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        _cacheManager = [ZQImageCache sharedInstance];
        _downloadManager = [ZQImageDownloadManager sharedInstance];
    }
    return self;
}

#pragma mark - Public

- (void)downloadImageWithURLString:(NSString *)urlStr progress:(ZQImageDownloadProgressBlock)progress completion:(ZQImageDownloadDoneBlock)completion {
    //TODO: NSAssert() completion must not be nil
    [self.cacheManager getImageWithImageURL:urlStr completion:^(UIImage *imgCached) {
        if (!imgCached) {
            //需要下载
            NSURL *url = [NSURL URLWithString:urlStr];
            [self.downloadManager downloadImageWithURL:url progress:progress completion:^(UIImage *image, NSData *imageData, NSError *error) {
                if (image) {
                    [self.cacheManager storeImage:image withImageURL:urlStr];
                }
                [self completionSafeInMain:completion image:image imageData:imageData error:error];
            }];
        }
        [self completionSafeInMain:completion image:imgCached imageData:nil error:nil];
    }];
}

- (void)completionSafeInMain:(ZQImageDownloadDoneBlock)completion image:(UIImage *)image imageData:(NSData *)imageData error:(NSError *)error {
    dispatch_main_async_safe(^{
        if (completion) {
            completion(image, imageData, error);
        }
        
    });
    
}

@end
