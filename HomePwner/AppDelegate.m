//
//  AppDelegate.m
//  HomePwner
//
//  Created by 郑克明 on 15/11/24.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemStore.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    NSLog(@"%@",NSStringFromCGSize([[UIScreen mainScreen] bounds].size));
    self.window.backgroundColor = [UIColor whiteColor];
    ItemsViewController *itemsViewController = [[ItemsViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itemsViewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
