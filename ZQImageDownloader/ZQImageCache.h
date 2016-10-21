//
//  ZQImageCache.h
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void(^ZQImageCacheGetComplection)(UIImage *);
typedef void(^ZQimageCacheNoParamBlock)();

@interface ZQImageCache : NSObject

+ (instancetype)sharedInstance;

- (void)storeImage:(UIImage *)image withImageURL:(NSString *)imageURLStr;

- (void)getImageWithImageURL:(NSString *)imageURLStr completion:(ZQImageCacheGetComplection)completion;
- (void)getThumbImageWithImageURL:(NSString *)imageURLStr completion:(ZQImageCacheGetComplection)completion;

- (void)clearMemoryCache;
- (void)clearDiskCacheWithCompletion:(ZQimageCacheNoParamBlock)completion;



@end
