//
//  LoginViewCotroller.m
//  zhixiao
//
//  Created by 董书建 on 14/12/23.
//  Copyright (c) 2014年 Vean. All rights reserved.
//

#import "LoginViewCotroller.h"
#import "CONSTS.h"
#import "WeiboSDK.h"

@implementation LoginViewCotroller
@synthesize wbtoken;

- (void) viewDidLoad {
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    login.frame = CGRectMake(ScreenWidth/4, ScreenHeight/2 , 100, 100);
    [login setTitle:@"Login" forState:UIControlStateNormal];
    [login.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [login setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [login addTarget:self action:@selector(bindAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:login];
    
    UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
    logout.frame = CGRectMake(ScreenWidth/2 , ScreenHeight/2 , 100, 100);
    [logout setTitle:@"Log out" forState:UIControlStateNormal];
    [logout.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [logout setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [logout addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logout];
}

#pragma mark - Item actions
//授权登录微博
-(void)bindAction {
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];

}

//取消授权登录微博 圣诞
-(void)logoutAction {
    
    [WeiboSDK logOutWithToken:kAccessToken delegate:self withTag:@"logOut"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWbtoken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Weibo delegate
/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class]) {
        
    }
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
        NSString *title = @"发送结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode, response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    } else if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        NSString *title;
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\nresponse.expirationDate: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], [(WBAuthorizeResponse *)response expirationDate], response.userInfo, response.requestUserInfo];
        switch (response.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess:
                title = @"登录成功";
                //获取accessToken
                [self setWbtoken:[(WBAuthorizeResponse *)response accessToken]];
                //保存 accessToken 到本地
                [[NSUserDefaults standardUserDefaults] setObject:wbtoken forKey:kWbtoken];
                //同步 accessToken
                [[NSUserDefaults standardUserDefaults] synchronize];
                //加载数据
//                [_homeVC loadWeiboData];
                break;
            case WeiboSDKResponseStatusCodeAuthDeny:
                title = @"登录失败";
                break;
            case WeiboSDKResponseStatusCodeUserCancelInstall:
                title = @"取消安装";
                break;
            case WeiboSDKResponseStatusCodeUnsupport:
                title = @"不支持请求";
                break;
            default:
                title = @"未知操作";
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        //        NSLog(@"%@", message);
        [alert show];
    }
}

#pragma mark - logout Weibo Delegate

/**
 收到一个来自微博Http请求的网络返回
 @param result 请求返回结果
 */
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result {
    
    NSString *tag = request.tag;
    
    if( [tag isEqualToString:@"logOut"]) {
        NSString *title = nil;
        UIAlertView *alert = nil;
        
        title = @"退出登录";
        alert = [[UIAlertView alloc] initWithTitle:title
                                           message:[NSString stringWithFormat:@"您已退出登录！请重新登录"]
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    }
}

/**
 收到一个来自微博Http请求失败的响应
 
 @param error 错误信息
 */
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error {
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = @"请求异常";
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",error]
                                      delegate:nil
                             cancelButtonTitle:@"确定"
                             otherButtonTitles:nil];
    [alert show];
}

/**
 收到一个来自微博Http请求的响应
 
 @param response 具体的响应对象
 */
- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response {
    
}

/**
 收到一个来自微博Http请求的网络返回
 
 @param data 请求返回结果
 */
- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data {
    
}

@end
