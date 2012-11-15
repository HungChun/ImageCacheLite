//
//  ImageCacheLiteManagement.m
//  test
//
//  Created by HungChun on 12/11/1.
//  Copyright (c) 2012年 HungChun. All rights reserved.
//  Email : hungchun713@gmail.com

#import "ImageCacheLiteManagement.h"
#import "UIImage+ImageCache.h"
#import "UIImageView+ImageCache.h"

static ImageCacheLiteManagement *_mangement;
@implementation ImageCacheLiteManagement
{
  NSMutableDictionary *_cacheDict;
  dispatch_queue_t downloadPhotoQueue;
  dispatch_queue_t cachePhotoQueue;
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
  downloadPhotoQueue = dispatch_queue_create("DownloadImage", 0);
  cachePhotoQueue = dispatch_queue_create("CacheImage", 0);
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

- (dispatch_queue_t)downloadQueue
{
  return downloadPhotoQueue;
}

- (dispatch_queue_t)cacheQueue
{
  return cachePhotoQueue;
}


- (void)releaseMemory
{
  NSLog(@"release memory");
  [UIImage checkImageCacheLifeAndClean];
  [UIImageView checkImageCacheLifeAndClean];
  [_cacheDict removeAllObjects];
}

@end
