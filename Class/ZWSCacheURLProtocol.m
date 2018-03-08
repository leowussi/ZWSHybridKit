//
//  ZWSCacheURLProtocol.m
//  Base ON --> JWCacheURLProtocol
//
//  Created by zhaowensky on 2018/2/27.
//  Copyright © 2018年 QuerySky. All rights reserved.
//

#import "ZWSCacheURLProtocol.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSURLProtocol+WebKitSupport.h"


static inline NSString * ZWSMD5(NSString *input) {
    if(!input){return @"";}
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}


#pragma mark - config
@interface ZWSCacheURLProtocolConfig: NSObject
@property (nonatomic,assign) double                    cacheSpaceTime;
@property (nonatomic,strong) NSMutableDictionary       *cacheUrl;
@property (nonatomic,strong) NSURLSessionConfiguration *sessionConfig;
@property (nonatomic,strong) NSOperationQueue          *forgeroundNetQueue;
@property (nonatomic,strong) NSOperationQueue          *backgroundNetQueue;
@end

@implementation ZWSCacheURLProtocolConfig

+(instancetype)shared{
    static ZWSCacheURLProtocolConfig *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [class_createInstance([self class], 0) init];
    });
    return client;
}

-(instancetype)init{
    if(self = [super init]){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveMemoryWarningNoti) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(void)clearCache
{
    _cacheUrl = nil;
    //[[NSURLCache sharedURLCache]removeAllCachedResponses];
}

-(void)didReceiveMemoryWarningNoti
{
    [self clearCache];
}

#pragma mark -  getter
-(double)cacheSpaceTime{
    if(_cacheSpaceTime == 0){
        _cacheSpaceTime = 3600;
    }
    return _cacheSpaceTime;
}

-(NSMutableDictionary*)cacheUrl{
    if(!_cacheUrl){
        _cacheUrl = [[NSMutableDictionary alloc]init];
    }
    return _cacheUrl;
}

- (NSURLSessionConfiguration *)sessionConfig{
    if (!_sessionConfig) {
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return _sessionConfig;
}

-(NSOperationQueue*)backgroundNetQueue{
    if(!_backgroundNetQueue){
        _backgroundNetQueue = [[NSOperationQueue alloc]init];
        _backgroundNetQueue.maxConcurrentOperationCount = 6;
    }
    return _backgroundNetQueue;
}

- (NSOperationQueue *)forgeroundNetQueue{
    if (!_forgeroundNetQueue) {
        _forgeroundNetQueue = [[NSOperationQueue alloc] init];
        _forgeroundNetQueue.maxConcurrentOperationCount = 10;
    }
    return _forgeroundNetQueue;
}

+ (NSURLCache *)defaultURLCache {
    return [[NSURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                         diskCapacity:100 * 1024 * 1024
                                             diskPath:@"com.QuerySky.ZWS.CacheURLProtocol"];
}

@end



#pragma mark - ZWSCacheURLProtocol
static NSString * const kZWSURLProtocolHandled = @"ZWSURLProtocolHandled";
static NSString * const kZWSBackgroundUpdate = @"ZWSBackgroundUpdate";

@interface ZWSCacheURLProtocol()<NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession  *session;
@property (nonatomic, strong) NSMutableData *data;
@end

@implementation ZWSCacheURLProtocol

#pragma mark -
+(void)startNetMonitoring:(BOOL)isUIWebView
{
    if(!isUIWebView){
//        //防止苹果静态检查，将W*K*Browsing*Context*Controller拆分
//        NSArray *privateStrArr = @[@"Controller", @"Context", @"Browsing", @"K", @"W"];
//        NSString *className =  [[[privateStrArr reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
//        Class cls = NSClassFromString(className);
//        SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
//
//        if (cls && sel) {
//            if ([(id)cls respondsToSelector:sel]) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//                [(id)cls performSelector:sel withObject:@"http"];
//                [(id)cls performSelector:sel withObject:@"https"];
//#pragma clang diagnostic pop
//            }
//        }
        [NSURLProtocol wk_registerScheme:@"http"];
        [NSURLProtocol wk_registerScheme:@"https"];
    }
    [NSURLProtocol registerClass:[ZWSCacheURLProtocol class]];
}

+(void)stopNetMonitoring:(BOOL)isUIWebView
{
    if(!isUIWebView){
        [NSURLProtocol wk_unregisterScheme:@"http"];
        [NSURLProtocol wk_unregisterScheme:@"https"];
    }
    [NSURLProtocol unregisterClass:[ZWSCacheURLProtocol class]];
}

+(void)setCacheSpaceTime:(double)spaceTime
{
    [ZWSCacheURLProtocolConfig shared].cacheSpaceTime = spaceTime;
}

+(void)clearCacheUrl
{
    [[ZWSCacheURLProtocolConfig shared] clearCache];
}

+(BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //只允许GET方法通过
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return NO;
    }
    
    NSString *urlScheme = [[request URL] scheme];
    if ([urlScheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [urlScheme caseInsensitiveCompare:@"https"] == NSOrderedSame){
        //判断是否标记过使用缓存来处理，或者是否有标记后台更新
        if ([NSURLProtocol propertyForKey:kZWSURLProtocolHandled inRequest:request] ||
            [NSURLProtocol propertyForKey:kZWSBackgroundUpdate inRequest:request]) {
            return NO;
        }
        
        NSString *urlString = [request.URL absoluteString];
        if([urlString containsString:@".mp4"]){
            return NO;
        }
    }
    return YES;
}

+(NSURLRequest*)canonicalRequestForRequest:(NSURLRequest *)request{
    return request;
}

#pragma mark -
- (void)backgroundCheckUpdate
{
    __weak typeof(self) weakSelf = self;
    ZWSCacheURLProtocolConfig *config = [ZWSCacheURLProtocolConfig shared];
    [[config backgroundNetQueue] addOperationWithBlock:^{
        NSDate *updateDate = [config.cacheUrl objectForKey:ZWSMD5(weakSelf.request.URL.absoluteString)];
        if (updateDate) {
            //判读两次相同的url地址发出请求相隔的时间，如果相隔的时间小于给定的时间，不发出请求。否则发出网络请求
            NSDate *currentDate = [NSDate date];
            NSInteger interval = [currentDate timeIntervalSinceDate:updateDate];
            if (interval < config.cacheSpaceTime) {
                return;
            }
        }
        NSMutableURLRequest *mutableRequest = [[weakSelf request] mutableCopy];
        [NSURLProtocol setProperty:@YES forKey:kZWSBackgroundUpdate inRequest:mutableRequest];
        [weakSelf netRequestWithRequest:mutableRequest];
    }];
}

- (void)netRequestWithRequest:(NSURLRequest *)request
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = [ZWSCacheURLProtocolConfig defaultURLCache];
    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[ZWSCacheURLProtocolConfig shared].forgeroundNetQueue];
    NSURLSessionDataTask * sessionTask = [_session dataTaskWithRequest:request];
    [[ZWSCacheURLProtocolConfig shared].cacheUrl setValue:[NSDate date] forKey:ZWSMD5(request.URL.absoluteString)];
    [sessionTask resume];
}

-(void)startLoading
{
    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[self request]];
    if (urlResponse) {
        //如果缓存存在，则使用缓存。并且开启异步线程去更新缓存
        [self.client URLProtocol:self didReceiveResponse:urlResponse.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:urlResponse.data];
        [self.client URLProtocolDidFinishLoading:self];
        [self backgroundCheckUpdate];
        return;
    }
    NSMutableURLRequest *mutableRequest = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:kZWSURLProtocolHandled inRequest:mutableRequest];
    [self netRequestWithRequest:mutableRequest];
}

-(void)stopLoading
{
    if(_session) [_session invalidateAndCancel];
}

- (void)appendData:(NSData *)newData
{
    if ([self data] == nil) {
        [self setData:[newData mutableCopy]];
    }else {
        [[self data] appendData:newData];
    }
}

#pragma mark -NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.client URLProtocol:self didLoadData:data];
    [self appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    [self.client URLProtocol:self didReceiveResponse:dataTask.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"didComplete -- URLString >> %@",task.currentRequest.URL.absoluteString);
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
        if (!_data) {
            return;
        }
        NSCachedURLResponse *cacheUrlResponse = [[NSCachedURLResponse alloc] initWithResponse:task.response data:_data];
        [[NSURLCache sharedURLCache] storeCachedResponse:cacheUrlResponse forRequest:task.currentRequest];
        self.data = nil;
    }
}



@end




