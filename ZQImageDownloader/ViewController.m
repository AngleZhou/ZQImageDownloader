//
//  ViewController.m
//  ZQImageDownloader
//
//  Created by Zhou Qian on 16/10/16.
//  Copyright © 2016年 Zhou Qian. All rights reserved.
//

#import "ViewController.h"
#import "ZQImageCache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZQImageCache *cache = [ZQImageCache sharedInstance];
    [cache storeImage:[UIImage imageNamed:@"天气"] withKey:@"tianqi"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
