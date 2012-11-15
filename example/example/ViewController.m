//
//  ViewController.m
//  example
//
//  Created by HungChun on 12/11/16.
//  Copyright (c) 2012年 HungChun. All rights reserved.
//  Email : hungchun713@gmail.com

#import "ViewController.h"
#import "UIImageView+ImageCache.h"
#import "UIImage+ImageCache.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
  [image loadImageWithURL:[NSURL URLWithString:@"http://www.grandeye.com.hk/old/image13/SunOrangeImage.jpg"]];
  [UIImage loadImageWithURL:[NSURL URLWithString:@"http://www.causingeffect.com/images/example/cow-sign.png"] success:^(BOOL haveData, UIImage *img) {
    [button setBackgroundImage:img forState:UIControlStateNormal];
  }];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
