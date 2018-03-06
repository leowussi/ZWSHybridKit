//
//  ZWSCacheURLProtocol.h
//  ZWSWebView
//
//  Created by zhaowensky on 2018/2/27.
//  Copyright © 2018年 QuerySky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWSCacheURLProtocol : NSURLProtocol

+(void)startNetMonitoring:(BOOL)isUIWebView;
+(void)stopNetMonitoring:(BOOL)isUIWebView;

+(void)setCacheSpaceTime:(double)spaceTime;

@end
