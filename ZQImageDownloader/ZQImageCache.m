//
//  ZQImageCache.m
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import "ZQImageCache.h"

#define ZQDefaultCacheFolderName @"com.ZQImageCache.image"
#define thumbSizeBaseline 100.0/[UIScreen mainScreen].scale

@interface ZQImageCache ()
@property (nonatomic, strong) NSCache *cacheMemory;
@property (nonatomic, strong) NSString *cachePathDisk;
@property (nonatomic, strong) dispatch_queue_t queueIO;//同步队列做图片存取IO
@end

@implementation ZQImageCache

#pragma mark - life cycle

+ (instancetype)sharedInstance {
    static ZQImageCache *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}
- (instancetype)init {
    if (self = [super init]) {
        _cacheMemory = [[NSCache alloc] init];
        _queueIO = dispatch_queue_create("com.ZQImageCache.queueIO", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Public

- (void)storeImage:(UIImage *)image withImageURL:(NSString *)imageURLStr {
#ifdef debug
    NSAssert(image == nil, @"image is nil");
    NSAssert(imageURLStr == nil, @"image url is nil");
#endif
    if (!image || !imageURLStr) {
        return;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    //TODO get png imageData; what aout other image format?
    [self storeImageInMemory:image key:imageURLStr];
    [self storeImageData:imageData key:imageURLStr toDisk:self.cachePathDisk];
}


- (void)getImageWithImageURL:(NSString *)imageURLStr completion:(ZQImageCacheGetComplection)completion {
    [self getImageWithImageURL:imageURLStr bThumb:NO completion:completion];
}
- (void)getThumbImageWithImageURL:(NSString *)imageURLStr completion:(ZQImageCacheGetComplection)completion {
    [self getImageWithImageURL:imageURLStr bThumb:YES completion:completion];
}




- (void)clearMemoryCache {
    [self.cacheMemory removeAllObjects];
}

- (void)clearDiskCacheWithCompletion:(ZQimageCacheNoParamBlock)completion {
    dispatch_async(self.queueIO, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        if (![fileManager removeItemAtPath:self.cachePathDisk error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        if (![fileManager createDirectoryAtPath:self.cachePathDisk withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
        
    });
}
#pragma mark - Private

- (void)getImageWithImageURL:(NSString *)imageURLStr bThumb:(BOOL)bThumb completion:(ZQImageCacheGetComplection)completion {
#ifdef debug
    NSAssert(completion == nil, @"completion is nil");
    NSAssert(imageURLStr == nil, @"image url is nil");
#endif
    if (!imageURLStr || !completion) {
        return;
    }
    
    NSString *imageKey = bThumb ? [imageURLStr stringByAppendingString:@"_thumb"] : imageURLStr;
    UIImage *image = [self imageInMemoryWithKey:imageKey];
    if (image) {
        completion(image);
    }
    else {
        [self imageInDiskWithKey:imageKey bThumb:bThumb completion:completion];
    }
}

- (UIImage *)imageInMemoryWithKey:(NSString *)key {
    return [self.cacheMemory objectForKey:key];
}
//origin image
- (void)imageInDiskWithKey:(NSString *)key completion:(ZQImageCacheGetComplection)completion {
    [self imageInDiskWithKey:key bThumb:NO completion:completion];
}
- (void)imageInDiskWithKey:(NSString *)key bThumb:(BOOL)bThumb completion:(ZQImageCacheGetComplection)completion {
    __weak __typeof(&*self) wSelf = self;
    dispatch_async(self.queueIO, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *diskPath = [wSelf.cachePathDisk stringByAppendingPathComponent:key];
        BOOL bExist = [fileManager fileExistsAtPath:diskPath];
        if (bExist) {
            NSData *imageData = [NSData dataWithContentsOfFile:diskPath];
            UIImage *image = [UIImage imageWithData:imageData];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image);
                });
            }
        }
        else {
            if (bThumb) {
                NSString *originImgKey = [key substringToIndex:(key.length-6)];
                NSString *originImgPath = [wSelf.cachePathDisk stringByAppendingPathComponent:originImgKey];
                BOOL bOrigExist = [fileManager fileExistsAtPath:originImgPath];
                if (bOrigExist) {
                    NSData *imageData = [NSData dataWithContentsOfFile:originImgPath];
                    UIImage *image = [UIImage imageWithData:imageData];
                    UIImage *thumbImg = [wSelf thumbImage:image];
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(thumbImg);
                        });
                    }
                    //save thumb
                    [wSelf storeImage:thumbImg withImageURL:key];
                }
                
            }
            //TODO: 下载图片
            
        }
        
    });
}


//store in memory
- (void)storeImageInMemory:(UIImage *)image key:(NSString *)key {
    [self.cacheMemory setObject:image forKey:key];
}

//store in disk
- (void)storeImageData:(NSData *)imageData key:(NSString *)key toDisk:(NSString *)diskPath {
    if (!imageData) {
        return;
    }
    
    dispatch_async(self.queueIO, ^{
        NSString *filePath = [diskPath stringByAppendingPathComponent:key];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
    });
}

//get cache folder path on disk
- (NSString *)cachePathDisk {
    if (!_cachePathDisk) {
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        _cachePathDisk = [cachePath stringByAppendingPathComponent:ZQDefaultCacheFolderName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:_cachePathDisk]) {
            NSError *error;
            if (![fileManager createDirectoryAtPath:_cachePathDisk withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }

    }
    return _cachePathDisk;
}

- (UIImage *)thumbImage:(UIImage *)image {
    CGSize originSize = image.size;
    CGFloat width = originSize.width;
    CGFloat height = originSize.height;
    
    CGSize thumbSize;
    if (width > height) {
        thumbSize = CGSizeMake(thumbSizeBaseline, height * thumbSizeBaseline / width);
    }
    else {
        thumbSize = CGSizeMake(width * thumbSizeBaseline / height, thumbSizeBaseline);
    }
    UIGraphicsBeginImageContextWithOptions(thumbSize, NO, 0);
    [image drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
    UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumb;
}

@end
