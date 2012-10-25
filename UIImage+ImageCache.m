//
//  UIImage+ImageCache.m
//  iCase
//
//  Created by HungChun on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIImage+ImageCache.h"
#import "NSString+MD5Addition.h"
@implementation UIImage (ImageCache)

+ (void)imageFromURL:(NSURL *)url success:(void (^)(BOOL, UIImage *))block {
    if ([[url absoluteString] hasSuffix:@".jpeg"] || [[url absoluteString] hasSuffix:@".png"] || [[url absoluteString] hasSuffix:@".jpg"]) {
        dispatch_queue_t imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(imageQueue, ^{
          UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];//[[UIImage alloc]initWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(img){
                    block(YES, img);
                }
                else {
                    block(NO, [UIImage imageNamed:@"photoitem.png"]);
                }
            });
        });
    }else{
        block(NO,[UIImage imageNamed:@"photoitem.png"]);
    }
}

+ (void)loadImageWithURL:(NSURL *)url success:(void (^)(BOOL haveData,UIImage *img))block{

  NSString *imgFileName = [[url absoluteString]stringFromMD5];
  
  NSData *data =  [self queryDiskCache:imgFileName];
  
  if (data) {
    if (![self checkImageCacheLifeCycle:[self getCatchPath:imgFileName]]) {
      [self CacheFile:url andFileNema:imgFileName success:^(BOOL haveData, NSData *aData) {
        block(YES,[UIImage imageWithData:aData]);
      }];
    }else {
      block(YES,[UIImage imageWithData:data]);
    }
  }else{
    [self CacheFile:url andFileNema:imgFileName success:^(BOOL haveData, NSData *aData) {
      block(YES,[UIImage imageWithData:aData]);
    }];
  }
}

+ (void)CacheFile:(NSURL *)url andFileNema:(NSString *)strFileName success:(void (^)(BOOL haveData,NSData *aData))block{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *imgData = [NSData dataWithContentsOfURL:url];
    [imgData writeToFile:[self getCatchPath:strFileName] atomically:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (imgData) {
        block(YES,imgData);
      }else {
        block(NO,nil);
      }
    });
    UIGraphicsEndImageContext();
  });
}

+ (NSData *)queryDiskCache:(NSString *)strFileName{
  NSString *diskPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
  if (![[NSFileManager defaultManager] fileExistsAtPath:diskPath]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:diskPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    return nil;
  }
  NSString *filePath = [self getCatchPath:strFileName];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    return [NSData dataWithContentsOfFile:filePath];
  }else 
    return nil;
}

//暫存時間兩天，超過兩天相同路徑檔案就更新
+ (BOOL)checkImageCacheLifeCycle:(NSString *)strPath{
  NSInteger cacheLifeCycle = 60*60*24*2;
  NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheLifeCycle];
  if ([[[[NSFileManager defaultManager] attributesOfItemAtPath:strPath error:nil] fileModificationDate] compare:expirationDate] == NSOrderedAscending) {
    [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
    return NO;
  }else {
    return YES;
  }
}

//取得檔案路徑
+ (NSString *)getCatchPath:(NSString *)strFileName{
  NSString* kDataCacheDirectory=@"ImageCache";
  return [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kDataCacheDirectory] stringByAppendingPathComponent:strFileName];
}

//清除檔案，超過五天就刪掉
+ (void)checkImageCacheLifeAndClean{
  NSInteger cacheLifeCycle = 60*60*24*5;
  NSString* kDataCacheDirectory=@"ImageCache";
  NSString *route = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kDataCacheDirectory];
  
  NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheLifeCycle];
  NSFileManager *manager = [NSFileManager defaultManager];
  NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:route];
  NSString *filename;
  while ((filename = [direnum nextObject] )) {
    NSString *filePath = [route stringByAppendingPathComponent:filename];
    if ([[[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileModificationDate] compare:expirationDate] == NSOrderedAscending) {
      [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
  }
}
@end
