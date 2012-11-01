//
//  ImageCacheLiteManagement.m
//  test
//
//  Created by HungChun on 12/11/1.
//  Copyright (c) 2012年 HungChun. All rights reserved.
//

#import "ImageCacheLiteManagement.h"

static ImageCacheLiteManagement *_mangement;
@implementation ImageCacheLiteManagement
{
  NSMutableDictionary *_cacheDict;
}

+ (ImageCacheLiteManagement *)shareInstance
{
  if (!_mangement)
  {
    _mangement = [[ImageCacheLiteManagement alloc]init];
    [_mangement initValue];
  }
  return _mangement;
}

- (void)initValue
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseMemory) name:UIApplicationDidEnterBackgroundNotification object:nil];
  _cacheDict = [[NSMutableDictionary alloc] init];
}

- (NSData *)loadDataFromMemory:(NSString *)key
{
  return [_cacheDict objectForKey:key];
}

- (void)cacheImageToMemory:(NSData *)data key:(NSString *)key
{
  if (data) 
    [_cacheDict setObject:data forKey:key];
}

- (void)releaseMemory
{
  NSLog(@"release memory");
  [_cacheDict removeAllObjects];
}

@end
