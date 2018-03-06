//
//  ZWSWebView.m
//  ZWSWebView
//
//  Created by zhaowensky on 2018/2/22.
//  Copyright © 2018年 QuerySky. All rights reserved.
//

#import "ZWSWebView.h"
#import <WebKit/WebKit.h>

@interface ZWSWebView()<WKUIDelegate,WKNavigationDelegate,UIWebViewDelegate,NJKWebViewProgressDelegate>

@property (nonatomic,assign) BOOL               isWKWebView;
@property (nonatomic,copy  ) NSString           *messageHandler;
@property (nonatomic,strong) NJKWebViewProgress *njkWebViewProgress;

@end


@implementation ZWSWebView
@synthesize isWKWebView = _isWKWebView;

-(instancetype)initWithFrame:(CGRect)frame isUIWebView:(BOOL)isUIWebView messageHandler:(NSString *)messageHandler
{
    self = [super initWithFrame:frame];
    if(self){
        self.isWKWebView = !isUIWebView;
        self.messageHandler = messageHandler;
    }
    return self;
}

-(void)dealloc
{
    if(_currentWebView && [_currentWebView isKindOfClass:[WKWebView class]]){
        [_currentWebView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_currentWebView removeObserver:self forKeyPath:@"title"];
    }
}

-(void)loadURLString:(NSString *)urlString
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    if(self.isWKWebView){
        WKWebView *wkWebView = _currentWebView;
        [wkWebView loadRequest:request];
    }else{
        UIWebView *uiwebView = _currentWebView;
        [uiwebView loadRequest:request];
    }
}

-(void)loadRequest:(NSURLRequest *)request
{
    if(self.isWKWebView){
        WKWebView *wkWebView = _currentWebView;
        [wkWebView loadRequest:request];
    }else{
        UIWebView *uiwebView = _currentWebView;
        [uiwebView loadRequest:request];
    }
}

-(void)loadData:(NSData *)data request:(NSURLRequest*)request
{
    if(self.isWKWebView){
        WKWebView *wkWebView = _currentWebView;
        if (@available(iOS 9.0, *)) {
            [wkWebView loadData:data MIMEType:@"text/html" characterEncodingName:@"UTF-8" baseURL:request.URL];
        } else {
            [self loadRequest:request];
        }
    }else{
        UIWebView *uiwebView = _currentWebView;
        [uiwebView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:request.URL];
    }
}

-(void)loadHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseURL
{
    if(self.isWKWebView){
        WKWebView *wkWebView = _currentWebView;
        [wkWebView loadHTMLString:htmlString baseURL:baseURL];
    }else{
        UIWebView *uiwebView = _currentWebView;
        [uiwebView loadHTMLString:htmlString baseURL:baseURL];
    }
}

-(BOOL)isWKWebView{
    return NSClassFromString(@"WKWebView") && _isWKWebView;
}

#pragma mark -
-(void)reload
{
    if(self.isWKWebView){
        WKWebView *wkWebView = _currentWebView;
        [wkWebView reload];
    }else{
        UIWebView *uiwebView = _currentWebView;
        [uiwebView reload];
    }
}

-(void)goBack
{
    if(self.isWKWebView){
        WKWebView *wkWebView = _currentWebView;
        [wkWebView goBack];
    }else{
        UIWebView *uiwebView = _currentWebView;
        [uiwebView goBack];
    }
}

#pragma mark - webview
-(void)setIsWKWebView:(BOOL)isWKWebView{
    _isWKWebView = isWKWebView;
    if(self.isWKWebView){
        _currentWebView = [self loadWKWebView];
    }else{
        _currentWebView = [self loadUIWebView];
    }
    [self addSubview:_currentWebView];
}

-(WKWebView*)loadWKWebView {
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc]init];
    webViewConfig.allowsInlineMediaPlayback = YES;
    WKWebView *webView = [[WKWebView alloc]initWithFrame:self.bounds configuration:webViewConfig];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.backgroundColor = [UIColor clearColor];
    [webView setAutoresizesSubviews:YES];
    [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    [webView.scrollView setShowsVerticalScrollIndicator:NO];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin];
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    return webView;
}

-(UIWebView*)loadUIWebView {
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.bounds];
    webView.allowsInlineMediaPlayback = YES;
    [webView setAutoresizesSubviews:YES];
    [webView setScalesPageToFit:YES];
    [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin];
    webView.keyboardDisplayRequiresUserAction = NO;
    webView.backgroundColor = [UIColor clearColor];
    [webView.scrollView setShowsHorizontalScrollIndicator:NO];
    webView.delegate = self;
    
    self.njkWebViewProgress = [[NJKWebViewProgress alloc] init];
    webView.delegate = _njkWebViewProgress;
    _njkWebViewProgress.webViewProxyDelegate = self;
    _njkWebViewProgress.progressDelegate = self;
    
    return webView;
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"estimatedProgress"]){
        double progress = [change[NSKeyValueChangeNewKey] doubleValue];
        if(_progressDelegate && [_progressDelegate respondsToSelector:@selector(webViewProgress:updateProgress:)]){
            [_progressDelegate webViewProgress:nil updateProgress:progress];
        }
    }
    if([keyPath isEqualToString:@"title"]){
        NSString *title = [change objectForKey:NSKeyValueChangeNewKey];
        if([self.delegate respondsToSelector:@selector(webView:title:)]){
            [self.delegate webView:self title:title];
        }
    }
}

#pragma mark - UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]){
        [self.delegate webViewDidStartLoad:self];
    }
    return [self callback_webViewShouldStartLoadWithRequest:request navigationType:navigationType];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if([self.delegate respondsToSelector:@selector(webView:title:)]){
        [self.delegate webView:self title:title];
    }
    
    if([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]){
        [self.delegate webViewDidFinishLoad:self];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]){
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

#pragma mark - WKWebViewDelegate
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL result = [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    if(result){
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]){
        [self.delegate webViewDidStartLoad:self];
    }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]){
        [self.delegate webViewDidFinishLoad:self];
    }
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]){
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    if(_progressDelegate && [_progressDelegate respondsToSelector:@selector(webViewProgress:updateProgress:)]){
        [_progressDelegate webViewProgress:webViewProgress updateProgress:progress];
    }
}

#pragma mark - WebViewCallback
- (BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType {
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        if (navigationType == -1) {  navigationType = UIWebViewNavigationTypeOther; }
        result = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return result;
}


@end







