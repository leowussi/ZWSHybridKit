//
//  NextViewController.m
//  ZWSWebView
//
//  Created by zhaowensky on 2018/3/5.
//  Copyright © 2018年 QuerySky. All rights reserved.
//

#import "NextViewController.h"
#import "ZWSWebView.h"
#import "ZWSCacheURLProtocol.h"

@interface NextViewController ()<ZWSWebViewDelegate>
@property (strong,nonatomic) ZWSWebView *webView;
@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [ZWSCacheURLProtocol startNetMonitoring:NO];
    _webView = [[ZWSWebView alloc]initWithFrame:self.view.bounds isUIWebView:NO messageHandler:nil];
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];
    //_webView.progressDelegate = self;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    NSString *whiteListStr = @"https://video.189jk.cn?form=app";
//    NSString *whiteListStr = @"https://baidu.com";
    [_webView loadURLString:whiteListStr];
}

-(void)dealloc
{
//    [ZWSCacheURLProtocol stopNetMonitoring];
}

-(void)webView:(ZWSWebView *)webView title:(NSString *)title
{
    self.title = title;
}


@end



