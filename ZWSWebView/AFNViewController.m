//
//  AFNViewController.m
//  ZWSWebView
//
//  Created by zhaowensky on 2018/3/6.
//  Copyright © 2018年 QuerySky. All rights reserved.
//

#import "AFNViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "ZWSCacheURLProtocol.h"

@interface AFNViewController ()

@end

@implementation AFNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *URL = [NSURL URLWithString:@"http://183.63.133.183:7010/health/cityArea/queryAllArea.do?cityCode=1&channel=1&provinceId=1&imei=7e547ee3d7a3ad4e6b3377a94f5c10e3705d0312&imsi=IOS_&appChannel=1&appType=1&networkType=wifi&verCode=1573"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //configuration.protocolClasses = @[[ZWSCacheURLProtocol class]];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {

    }];
    [dataTask resume];
    

    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *connectionError){
        NSLog(@"response = %@",response);
        NSLog(@"data = %@",data);
        NSLog(@"error = %@",connectionError);
    }];
    
    //The shared session uses the currently set global NSURLCache,
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"response = %@",response);
    }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
