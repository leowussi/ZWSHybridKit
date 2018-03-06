//
//  ZWSWebView.h
//  ZWSWebView
//
//  Created by zhaowensky on 2018/2/22.
//  Copyright © 2018年 QuerySky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NJKWebViewProgress/NJKWebViewProgress.h>


@class ZWSWebView;


#pragma mark - Delegate
@protocol ZWSWebViewDelegate<NSObject>

@optional
- (void)webViewDidStartLoad:(ZWSWebView *)webView;
- (void)webViewDidFinishLoad:(ZWSWebView *)webView;
- (void)webView:(ZWSWebView *)webView title:(NSString*)title;
- (void)webView:(ZWSWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(ZWSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
@end


@protocol ZWSWebViewProgressDelegate<NSObject>
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress;
@end



#pragma mark - WebView
@interface ZWSWebView : UIView

-(instancetype)initWithFrame:(CGRect)frame isUIWebView:(BOOL)isUIWebView messageHandler:(NSString *)messageHandler;

-(void)loadURLString:(NSString*)urlString;
-(void)loadRequest:(NSURLRequest*)request;
-(void)loadData:(NSData *)data request:(NSURLRequest*)request;
-(void)loadHTMLString:(NSString*)htmlString baseURL:(NSURL*)baseURL;

-(void)reload;
-(void)goBack;

@property (nonatomic,strong) id currentWebView;
@property (nonatomic,weak  ) id<ZWSWebViewDelegate> delegate;
@property (nonatomic,weak  ) id<ZWSWebViewProgressDelegate> progressDelegate;

@end




