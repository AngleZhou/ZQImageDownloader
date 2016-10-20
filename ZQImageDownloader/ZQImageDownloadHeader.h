//
//  ZQImageDownloadHeader.h
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/19.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#ifndef ZQImageDownloadHeader_h
#define ZQImageDownloadHeader_h

typedef void(^ZQImageDownloadProgressBlock)(NSUInteger imageDataLength, NSInteger expectedSize);
typedef void(^ZQImageDownloadDoneBlock)(UIImage *image, NSData *imageData, NSError *error);
typedef void(^ZQImageDownloadCancelBlock)(void);

NSString * const kOperationProcessBlock = @"kOperationProcessBlock";
NSString * const kOperationDoneBlock = @"kOperationDoneBlock";

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

#endif /* ZQImageDownloadHeader_h */
