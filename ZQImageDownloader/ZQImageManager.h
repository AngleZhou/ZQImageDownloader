//
//  ZQImageManager.h
//  ZQImageDownloader
//
//  Created by Angle on 16/10/21.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZQImageDownloadHeader.h"

@interface ZQImageManager : NSObject
- (void)downloadImageWithURLString:(NSString *)urlStr progress:(ZQImageDownloadProgressBlock)progress completion:(ZQImageDownloadDoneBlock)completion;
@end
