//
//  ImageCacheLiteManagement.h
//  test
//
//  Created by HungChun on 12/11/1.
//  Copyright (c) 2012年 HungChun. All rights reserved.
//  Email : hungchun713@gmail.com
#import <Foundation/Foundation.h>

@interface ImageCacheLiteManagement : NSObject

+ (ImageCacheLiteManagement *)shareInstance;

- (NSData *)loadDataFromMemory:(NSString *)key;

- (void)cacheImageToMemory:(NSData *)data key:(NSString *)key;

- (dispatch_queue_t)downloadQueue;

- (dispatch_queue_t)cacheQueue;

@end
