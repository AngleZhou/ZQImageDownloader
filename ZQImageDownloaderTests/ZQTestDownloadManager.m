//
//  ZQTestDownloadManager.m
//  ZQImageDownloader
//
//  Created by Angle on 16/10/21.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//



#import <XCTest/XCTest.h>
#import "ZQImageDownloadManager.h"
#import "ZQImageDownloadHeader.h"

@interface ZQTestDownloadManager : XCTestCase
@property (nonatomic, strong) ZQImageDownloadManager *manager;
@end

@implementation ZQTestDownloadManager

static NSString *httpStr = @"http://pic44.nipic.com/20140717/12432466_121957328000_2.jpg";
static NSString *httpsStr = @"https://images-cn.ssl-images-amazon.com/images/G/28/gno/sprites/global-sprite-32-v1._CB330175699_.png";
static NSString *slow = @"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage001.jpg";

- (void)setUp {
    [super setUp];
    self.manager = [ZQImageDownloadManager sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHTTP {
    [self testImageWithURL:httpStr];
}
- (void)testHTTPS {
    [self testImageWithURL:httpsStr];
}

- (void)testDifferentDownload {
    ZQDownloadToken *token1 = [self testImageWithURL:httpStr];
    ZQDownloadToken *token2 = [self testImageWithURL:httpsStr];
    NSLog(@"%@", token1);
    NSLog(@"%@", token2);
    XCTAssertNotEqual(token1.url, token2.url, @"url1 == url2 !");
    XCTAssertNotEqual(token1.downloadCancelToken, token2.downloadCancelToken, @"different urls with Same download Task!!!");
}

- (void)testSameTask {
    NSURL *url = [NSURL URLWithString:slow];
    ZQImageDownloadOperation *op1 = [self.manager operationWithURL:url progress:nil completion:^(UIImage *image, NSData *imageData, NSError *error) {

    }];
    ZQImageDownloadOperation *op2 = [self.manager operationWithURL:url progress:nil completion:^(UIImage *image, NSData *imageData, NSError *error) {

    }];
    NSLog(@"%@", op1);
    NSLog(@"%@", op2);
    XCTAssertEqual(op1, op2, @"op1 != op2");
}

- (void)testSameDownload {
    __block XCTestExpectation *expect1 = [self expectationWithDescription:@"Image 1 Download done!"];
    __block XCTestExpectation *expect2 = [self expectationWithDescription:@"Image 2 Download done!"];
    
    NSURL *url = [NSURL URLWithString:slow];
    ZQDownloadToken *token1 = [self.manager downloadImageWithURL:url progress:nil completion:^(UIImage *image, NSData *imageData, NSError *error) {
        XCTAssertNotNil(image, @"image is nil");
        XCTAssertNil(error, @"error!!!");
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        [expect1 fulfill];
    }];
    ZQDownloadToken *token2 = [self.manager downloadImageWithURL:url progress:nil completion:^(UIImage *image, NSData *imageData, NSError *error) {
        XCTAssertNotNil(image, @"image is nil");
        XCTAssertNil(error, @"error!!!");
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        [expect2 fulfill];
    }];
    NSLog(@"%@", token1);
    NSLog(@"%@", token2);
    XCTAssertEqual(token1.url, token2.url, @"url1 != url2, change url");
    XCTAssertNotEqual(token1.downloadCancelToken, token2.downloadCancelToken, @"same urls with Same handlers!!!");
    
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (ZQDownloadToken *)testImageWithURL:(NSString *)urlStr {
    __block XCTestExpectation *expects = [self expectationWithDescription:@"ImageDownload done!"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    ZQDownloadToken *token = [self.manager downloadImageWithURL:url progress:nil completion:^(UIImage *image, NSData *imageData, NSError *error) {
        XCTAssertNotNil(image, @"image is nil");
        XCTAssertNil(error, @"error!!!");
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        [expects fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
    return token;
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
