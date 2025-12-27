//
//  SceneDelegate.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/11.
//

#import "SceneDelegate.h"
#import "./GlobalInfoManager/GlobalInfoManager.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


#pragma mark - 其他接口
// 冷启动
- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
        options:(UISceneConnectionOptions *)connectionOptions {

    NSSet<UIOpenURLContext *> *URLContexts = connectionOptions.URLContexts;
    for (UIOpenURLContext *context in URLContexts) {
        NSURL *url = context.URL;

        // 更安全的方式：直接用 URL 读取
        NSError *error = nil;
        NSString *fileContent = [NSString stringWithContentsOfURL:url
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];

        if (error) {
            NSLog(@"读取失败: %@", error.localizedDescription);
            continue;
        }

        NSLog(@"文件内容:\n%@", fileContent);

        [GlobalInfoManager sharedManager].url = url;

    }
}


// 热启动
- (void)scene:(UIScene *)scene
openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    for (UIOpenURLContext *context in URLContexts) {
        NSURL *url = context.URL;

        // 更安全的方式：直接用 URL 读取
        NSError *error = nil;
        NSString *fileContent = [NSString stringWithContentsOfURL:url
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];

        if (error) {
            NSLog(@"读取失败: %@", error.localizedDescription);
            continue;
        }

        NSLog(@"文件内容:\n%@", fileContent);

        [GlobalInfoManager sharedManager].url = url;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenFileNotification"
                                                            object:nil
                                                          userInfo:@{@"fileURL": url}];
    }

}



@end
