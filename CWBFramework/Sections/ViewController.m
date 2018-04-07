//
//  ViewController.m
//  CWBFramwork
//
//  Created by ciome on 16/7/30.
//  Copyright © 2016年 ciome. All rights reserved.
//

#import "ViewController.h"
#import "BaseModel.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BaseModel  *one = [[BaseModel alloc] init];
//    [one testOne];
    
    [self testPostHttp];
    
    LOGERR(@"测试中----");
    LOGWARN(@"警告");
    LOGNOTICE(@"登陆");
    LOGDEBUG(@"调试");
}

- (void)testHttp
{
    NSString * URLString = @"http://localhost:8080/login?name=admin&password=123456";
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:URL];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"error: %@",[error localizedDescription]);
    }else{
        NSLog(@"response : %@",response);
        NSLog(@"backData : %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    }

}


- (void)testPostHttp

{

    NSString * URLString = @"http://localhost:8080/accessRight/check";
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSString * postString = @"packageName=ab2c&appName=咪咕1&platform=IOS&certificate=com.migu.player";
    NSData * postData = [postString dataUsingEncoding:NSUTF8StringEncoding];  //将请求参数字符串转成NSData类型
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"post"]; //指定请求方式
    [request setURL:URL]; //设置请求的地址
    [request setHTTPBody:postData];  //设置请求的参数
    
    NSURLResponse * response;
    NSError * error;
    NSData * backData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"error : %@",[error localizedDescription]);
    }else{
        NSLog(@"response : %@",response);
        NSLog(@"backData : %@",[[NSString alloc]initWithData:backData encoding:NSUTF8StringEncoding]);
    }
}



#pragma mark - PressOnFuc

- (void)pressOnForTestBt:(id)sender
{
    LOGDEBUG(@"按钮调式");
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
  
}

@end
