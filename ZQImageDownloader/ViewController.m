//
//  ViewController.m
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import "ViewController.h"
#import "ZQImageManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *httpStr = @"http://pic44.nipic.com/20140717/12432466_121957328000_2.jpg";
//    NSString *testHttps = @"https://images-cn.ssl-images-amazon.com/images/G/28/gno/sprites/global-sprite-32-v1._CB330175699_.png";
//    
//    NSString *slow = @"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage001.jpg";
//    
//    
    [[ZQImageManager sharedInstance] downloadImageWithURLString:self.urlString1 progress:nil completion:^(UIImage *image, NSData *imageData, NSError *error) {
        self.imageView.image = image;
    }];
    
    [[ZQImageManager sharedInstance] downloadImageWithURLString:self.urlString2 progress:nil completion:^(UIImage *image, NSData *imageData, NSError *error) {
        self.imageView2.image = image;
    }];
}




@end
