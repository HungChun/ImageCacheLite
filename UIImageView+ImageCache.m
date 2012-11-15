//
//  UIImageView+ImageCache.m
//  ImageCache
//
//  Created by HungChun on 12/5/1.
//  Copyright (c) 2012年 HungChun. All rights reserved.
//  Email : hungchun713@gmail.com

#import "UIImageView+ImageCache.h"
#import "NSString+MD5Addition.h"
#import "ImageCacheLiteManagement.h"
@implementation UIImageView (ImageCache)
-(void)ShowActivityView{
  UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [act startAnimating];
  [act setFrame:CGRectMake((self.frame.size.width - 20) / 2, (self.frame.size.height - 20) / 2, 20, 20)];
  [self addSubview:act];
#if ! __has_feature(objc_arc)
  [act release];
#endif
  
}

-(void)HideActivityView{
  for (UIView *view in self.subviews) {
    [view removeFromSuperview];
  }
}

-(void)loadImageWithURL:(NSURL *)url{
  //背景圖設定
  //self.image = [UIImage imageNamed:@"photoitem.png"];
  dispatch_queue_t cachePhotoQueue = [[ImageCacheLiteManagement shareInstance] cacheQueue];
  NSString *imgFileName = [[url absoluteString]stringFromMD5];
  NSData *mData = [[ImageCacheLiteManagement shareInstance] loadDataFromMemory:imgFileName];
  if (mData) {
      self.image = [UIImage imageWithData:mData];
  }
  else
  {
    NSData *data =  [self queryDiskCache:imgFileName];
    if (data) {
      if (![self checkImageCacheLifeCycle:[self getCatchPath:imgFileName]]) {
        [self CacheFile:url andFileNema:imgFileName];
      }else {
        self.image = [UIImage imageWithData:data];
        dispatch_async(cachePhotoQueue, ^{
          [[ImageCacheLiteManagement shareInstance] cacheImageToMemory:data key:imgFileName];
        });
      }
    }else{
      [self CacheFile:url andFileNema:imgFileName];
    }
  }
}

-(void)CacheFile:(NSURL *)url andFileNema:(NSString *)strFileName{
  [self CacheFile:url andFileNema:strFileName andShowActivity:NO];
}

-(void)CacheFile:(NSURL *)url andFileNema:(NSString *)strFileName andShowActivity:(BOOL)isShowActivity{
  dispatch_queue_t cachePhotoQueue = [[ImageCacheLiteManagement shareInstance] cacheQueue];
  dispatch_queue_t downloadPhotoQueue = [[ImageCacheLiteManagement shareInstance] downloadQueue];
  if (isShowActivity) {
    [self ShowActivityView];
  }
  
  dispatch_async(downloadPhotoQueue, ^{
    NSData *imgData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imgData];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.image = image;
    });
    dispatch_async(cachePhotoQueue, ^{
      [imgData writeToFile:[self getCatchPath:strFileName] atomically:YES];
      [[ImageCacheLiteManagement shareInstance] cacheImageToMemory:imgData key:strFileName];
    });
    if (isShowActivity) {
      [self HideActivityView];
    }
  });
}

-(NSData *)queryDiskCache:(NSString *)strFileName{
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

//檢查檔案時間，超過兩天就刪掉更新
-(BOOL)checkImageCacheLifeCycle:(NSString *)strPath{
  //暫存時間一週
  NSInteger cacheLifeCycle = 60*60*24*2;
  NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheLifeCycle];
  if ([[[[NSFileManager defaultManager] attributesOfItemAtPath:strPath error:nil] fileModificationDate] compare:expirationDate] == NSOrderedAscending) {
    [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
    NSLog(@"刪除");
    return NO;
  }else {
    return YES;
  }
}


-(NSString *)getCatchPath:(NSString *)strFileName{
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
