//
//  CONSTS.h
//  zhixiao
//
//  Created by 董书建 on 14/12/23.
//  Copyright (c) 2014年 Vean. All rights reserved.
//

#ifndef zhixiao_CONSTS_h
#define zhixiao_CONSTS_h

//weibo appKey
#define kAppKey         @"3275163745"
#define kWbtoken @"kWbtoken"              //微博token

//微博
#define kRedirectURI @"https://api.zhixiaoapp.com/v1/auth/weibo"

#define ScreenHeight [UIScreen mainScreen].bounds.size.height               //获取设备的物理高度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width             //获取设备的物理宽度
//微博本地的保存的token
#define kAccessToken  (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kWbtoken]

#endif
