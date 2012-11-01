//
//  UIImage+ImageCache.h
//  iCase
//
//  Created by HungChun on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageCache)

+ (void)imageFromURL:(NSURL *)url success:(void (^)(BOOL haveData, UIImage *img))block;

+ (void)loadImageWithURL:(NSURL *)url success:(void (^)(BOOL haveData,UIImage *img))block;

+ (void)CacheFile:(NSURL *)url andFileNema:(NSString *)strFileName success:(void (^)(BOOL haveData,NSData *aData))block;

+ (NSData *)queryDiskCache:(NSString *)strFileName;

+ (BOOL)checkImageCacheLifeCycle:(NSString *)strPath;

+ (NSString *)getCatchPath:(NSString *)strFileName;

@end
