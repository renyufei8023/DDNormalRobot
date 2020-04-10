//
//  AppDelegate.m
//  DDNormalRobot
//
//  Created by dudu on 2020/4/10.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "AppDelegate.h"
#import "DDChatViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    QMUINavigationController *nav = [[QMUINavigationController alloc] initWithRootViewController:[DDChatViewController new]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
