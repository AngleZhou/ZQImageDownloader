//
//  ZQTestImageCache.m
//  ZQImageDownloader
//
//  Created by Angle on 16/10/21.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZQImageCache.h"

@interface ZQTestImageCache : XCTestCase
@property (nonatomic, strong) ZQImageCache *cacheManager;
@end

@implementation ZQTestImageCache

- (void)setUp {
    [super setUp];
    self.cacheManager = [ZQImageCache sharedInstance];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self clearAllCacheWithCompletion:^{
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCacheMemory {
    UIImage *image = [self imageForTesting];
    NSString *key = @"testImage";
    [self.cacheManager storeImage:image withImageURL:key toDisk:NO];
    
    [self.cacheManager getImageWithImageURL:key completion:^(UIImage *img) {
        XCTAssertEqual(image, img, @"really store in memory?");
    }];
}

- (void)testCacheDisk {
    UIImage *image = [self imageForTesting];
    NSString *key = @"testImage";
    
    __block XCTestExpectation *expects = [self expectationWithDescription:@"Image from Disk done!"];
    [self.cacheManager storeImage:image withImageURL:key toDisk:YES];
    [self.cacheManager getImageWithImageURL:key completion:^(UIImage *img) {
        if (img) {
            [expects fulfill];
        }
        else {
            XCTFail(@"Image From Disk Fail!!");
        }
        
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

#pragma mark - Private Helper

- (void)clearAllCacheWithCompletion:(ZQimageCacheNoParamBlock)completion {
    [self.cacheManager clearMemoryCache];
    [self.cacheManager clearDiskCacheWithCompletion:completion];
}
- (UIImage *)imageForTesting{
    static UIImage *reusableImage = nil;
    if (!reusableImage) {
        reusableImage = [UIImage imageWithContentsOfFile:[self testImagePath]];
    }
    return reusableImage;
}

- (NSString *)testImagePath {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return [testBundle pathForResource:@"TestImage" ofType:@"jpg"];
}
@end
