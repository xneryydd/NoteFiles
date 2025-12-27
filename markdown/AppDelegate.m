//
//  AppDelegate.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/11.
//

#import "AppDelegate.h"
#import "./FileService/FileService.h"
#import "./FileViewController/FileViewController.h"
#import "./GlobalInfoManager/GlobalInfoManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - 创建文件夹
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 创建 text.txt 文件
    [FileService createTextFileIfNeeded:@"text.txt" withContent:@"Hello, 文件共享测试内容！" isRepeat:NO];
    
    // 检查并创建 Documents/assert/ 目录
    [self createAssertDirectoryIfNeeded];
    
    return YES;
}

- (void)createAssertDirectoryIfNeeded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 获取 Documents 目录路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    // 拼接 assert 文件夹路径
    NSString *assertPath = [documentsPath stringByAppendingPathComponent:@"assert"];
    
    BOOL isDir = NO;
    BOOL exists = [fileManager fileExistsAtPath:assertPath isDirectory:&isDir];
    
    if (!(exists && isDir)) {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:assertPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (success) {
            NSLog(@"✅ 成功创建目录: %@", assertPath);
        } else {
            NSLog(@"❌ 创建目录失败: %@", error.localizedDescription);
        }
    } else {
        NSLog(@"📂 目录已存在: %@", assertPath);
    }
}



#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}




@end
