//
//  ZQImageManager.h
//  ZQImageDownloader
//
//  Created by Angle on 16/10/21.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

//  This is the extern .h file for users.



#import <Foundation/Foundation.h>
#import "ZQImageDownloadHeader.h"

@interface ZQImageManager : NSObject

/**
 *  Singleton method, returns the shared instance
 *
 *  @return global shared instance of ZQImageManager class
 */
+ (instancetype)sharedInstance;

/**
 *  Fetch image from Memory(1st) or Disk(2nd), or download(3rd). If downloaded, save image to both Memory and Disk. The method is asynchronize. completion and progress callbacks are in Main thread.
 *
 *  @param urlStr            The URL string to the image to get
 
 
 typedef void(^ZQImageDownloadProgressBlock)(NSUInteger imageDataLength, NSInteger expectedSize);
 typedef void(^ZQImageDownloadDoneBlock)(UIImage *image, NSData *imageData, NSError *error);
 
 
 */
- (void)downloadImageWithURLString:(NSString *)urlStr progress:(ZQImageDownloadProgressBlock)progress completion:(ZQImageDownloadDoneBlock)completion;

/**
 *  Fetch thumb image from Memory(1st)
    if not found, fetch original image from disk and generate thumb image,(2nd)
    if nothing found in disk, download. (3rd)
    If downloaded, save original image to disk, and generate thumb image to save in memory and return in completion block.
    The method is asynchronize. completion and progress callbacks are in Main thread.
 *
 *  @param urlStr            The URL string to the image to get
 *
 */
- (void)downloadThumbImageWithURLString:(NSString *)urlStr progress:(ZQImageDownloadProgressBlock)progress completion:(ZQImageDownloadDoneBlock)completion;
@end
