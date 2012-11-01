//
//  ImageCacheLiteManagement.h
//  test
//
//  Created by HungChun on 12/11/1.
//  Copyright (c) 2012年 HungChun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCacheLiteManagement : NSObject

+ (ImageCacheLiteManagement *)shareInstance;

- (NSData *)loadDataFromMemory:(NSString *)key;

- (void)cacheImageToMemory:(NSData *)data key:(NSString *)key;
@end
