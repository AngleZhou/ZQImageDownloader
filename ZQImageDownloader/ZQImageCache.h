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

/**
 *  Singleton method, returns the shared instance
 *
 *  @return global shared instance of ZQImageCache class
 */
+ (instancetype)sharedInstance;


/**
 *  store image both in memory and disk. 
 *  The disk path is: folder named com.ZQImageCache.image in default cache dictionary in User domain.
 *
 *  @param image            image to save
 *  @param imageURLStr      image url
 */
- (void)storeImage:(UIImage *)image withImageURL:(NSString *)imageURLStr;
/**
 *  store image both in memory or disk.
 *
 *  @param image            image to save
 *  @param imageURLStr      image url
 */
- (void)storeImage:(UIImage *)image withImageURL:(NSString *)imageURLStr toDisk:(BOOL)toDisk;
/**
 *  generate thumb image to store in both memory and disk, and store original image to disk.
 *  The disk path is: folder named com.ZQImageCache.image in default cache dictionary in User domain.
 *
 *  @param image            image to save (original)
 *  @param imageURLStr      image url
 */
- (UIImage *)storeThumbImage:(UIImage *)image withImageURL:(NSString *)imageURLStr;


/**
 *  fetch image from memory, 
 *  if not found, fetch from disk, and store in memory.
 *  if not found, return nil in completion.

    The disk path is: folder named com.ZQImageCache.image in default cache dictionary in User domain.
    Asynchronize. completion in main thread.
 
 *  @param imageURLStr      image url
 *  @param completion       return image or nil in completion
 
 typedef void(^ZQImageCacheGetComplection)(UIImage *);
 
 */
- (void)getImageWithImageURL:(NSString *)imageURLStr completion:(ZQImageCacheGetComplection)completion;
/**
 *  fetch thumb image from memory,
 *  if not found, fetch from disk, and store in memory.
 *  if not found, fetch original image from disk, generate thumb and save in memory and disk.
 *  if not found, return nil in completion.
 
    The disk path is: folder named com.ZQImageCache.image in default cache dictionary in User domain.
    Asynchronize. completion in main thread.
 
 *  @param imageURLStr      image url
 *  @param completion       return image or nil in completion
 
 typedef void(^ZQImageCacheGetComplection)(UIImage *);
 
 */
- (void)getThumbImageWithImageURL:(NSString *)imageURLStr completion:(ZQImageCacheGetComplection)completion;


/**
 *  clear memory cache
 */
- (void)clearMemoryCache;
/**
 *  clear disk cache. Asynchronize.
 
 typedef void(^ZQimageCacheNoParamBlock)();
 
 */
- (void)clearDiskCacheWithCompletion:(ZQimageCacheNoParamBlock)completion;


/**
 *  return image from memory cache. For testing purpose.
 */
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;
/**
 *  return image in comletion from disk cache. For testing purpose.
 
  typedef void(^ZQImageCacheGetComplection)(UIImage *);
 
 */
- (void)imageFromDiskCacheForKey:(NSString *)key completion:(ZQImageCacheGetComplection)completion;

@end
