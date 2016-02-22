//
//  AppDelegate.m
//  HomePwner
//
//  Created by 郑克明 on 15/11/24.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemStore.h"

NSString * const BNRNextItemValuePrefsKey = @"NextItemValue";
NSString * const BNRNextItemNamePrefsKey = @"NextItemName";
@interface AppDelegate ()

@end

@implementation AppDelegate

//第一次实例化对象的时候被调用
+(void)initialize{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *factorySettings = @{BNRNextItemValuePrefsKey:@75, BNRNextItemNamePrefsKey:@"Coffee Cup"};
    [defaults registerDefaults:factorySettings];
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    NSLog(@"%@",NSStringFromCGSize([[UIScreen mainScreen] bounds].size));
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.frame = [[UIScreen mainScreen] bounds];
//    self.window.backgroundColor = [UIColor whiteColor];
    //应用没有触发状态恢复时,才新建视图控制器
    if (!self.window.rootViewController) {
        ItemsViewController *itemsViewController = [[ItemsViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itemsViewController];
        //将navController的类名设置为恢复标识,告知系统要保存或者恢复这个节点的状态
        //这里并没有设置恢复类,将由应用程序托管负责创建
        navController.restorationIdentifier = NSStringFromClass([navController class]);
        self.window.rootViewController = navController;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    //强制关闭也会触发...
    BOOL success = [[ItemStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"Saved all of the BNRItems");
    }else{
        NSLog(@"Could not save any of the BNRItems");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
    return YES;
}

//没有设置恢复类的对象,系统会自动调用应用程序委托(下面方法)创建该对象
- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    //参考 P462
    //如果是在列表里点击item打开一个新窗口显示detail,这个时候detail控制器里的viewControllerWithRestorationIdentifierPath方法中的path里面就是UINavigationController/DetailViewController
    
    //如果是在程序启动之后创建的UINavController并向其中圧入itemsViewController,这个时候itemsViewController里的viewControllerWithRestorationIdentifierPath方法中的path里面就是UINavigationController/ItemsViewController
    
    //如果是点击新增按钮弹出的detail,这个时候detail控制器里的viewControllerWithRestorationIdentifierPath方法中的path显示的就是UINavigationController/UINavigationController/DetailViewController
    
    //所以当前方法的path就等于detail里viewControllerWithRestorationIdentifierPath的path去掉最后一个节点
    
    UIViewController *vc = [[UINavigationController alloc] init];
    //路径里的最后一个就是相应的UINavigationController
    vc.restorationIdentifier = [identifierComponents lastObject];
    //通过path的数量可以确定是属于点击item查看详情显示detail控制器,还是点击新增item显示detail控制器
    if ([identifierComponents count] == 1) {
        self.window.rootViewController = vc;
    }
    return vc;
}

@end
