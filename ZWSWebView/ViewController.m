//
//  ViewController.m
//  ZWSWebView
//
//  Created by zhaowensky on 2018/2/22.
//  Copyright © 2018年 QuerySky. All rights reserved.
//

#import "ViewController.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import "ZWSWebView.h"
#import "ZWSCacheURLProtocol.h"

@interface ViewController ()<ZWSWebViewProgressDelegate,ZWSWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong,nonatomic) ZWSWebView *webView;
@property (strong,nonatomic) WebViewJavascriptBridge *bridge;
@property (weak,nonatomic) IBOutlet UITextField *txtMessage;

@end

@implementation ViewController

-(void)dealloc
{
//    [ZWSCacheURLProtocol stopNetMonitoring];
//    [JWCacheURLProtocol cancelListeningNetWorking];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[ZWSWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height) isUIWebView:NO messageHandler:nil];
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];
    _webView.progressDelegate = self;
    [self.view addSubview:_webView];
//
//    [WebViewJavascriptBridge enableLogging];
//    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView.currentWebView];
//    [_bridge setWebViewDelegate:self];
//    [_bridge registerHandler:@"yjk_navtive" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"testObjcCallback called: %@", data);
//        responseCallback(_txtMessage.text.length > 0 ? _txtMessage.text:_txtMessage.placeholder);
//    }];
//    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
//
    [self renderButtons:_webView];
    //[self loadPage:_webView];
    [self loadPage2:_webView];
}

-(void)loadPage:(ZWSWebView*)webView
{
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

-(void)loadPage2:(ZWSWebView*)webView
{
    NSString *whiteListStr = @"https://video.189jk.cn?form=app";
//    NSString *whiteListStr = @"https://t.tech.21cn.com/f6fUru";
//    NSString *whiteListStr = @"http://mp.weixin.qq.com/mp/homepage?__biz=MzIxNzAxNjE1NQ==&hid=2&sn=a7643e3598904aa0a805cc700f59f371#wechat_redirect";
    [webView loadURLString:whiteListStr];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)renderButtons:(ZWSWebView*)webView
{
    [self.view bringSubviewToFront:self.toolbar];
}

- (void)callHandler:(id)sender {
    id data = @{ @"greetingFromObjC":_txtMessage.text };
    [_bridge callHandler:@"yjk_navtive" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (IBAction)reloadAction:(id)sender {
    [_webView reload];
}

- (IBAction)callAction:(id)sender {
    [self callHandler:nil];
}

- (IBAction)backAction:(id)sender {
    [_webView goBack];
}

#pragma mark - ZWSWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    self.progressView.progress = progress;
}

#pragma mark - ZWSWebViewDelegate



@end




