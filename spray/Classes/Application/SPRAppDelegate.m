//
//  SPRAppDelegate.m
//  spray
//
//  Created by Mustapha Tarek BEN LECHHAB on 12/05/2014.
//  Copyright (c) 2014 Octiplex. All rights reserved.
//

#import "SPRAppDelegate.h"
#import "SPRHomeViewController.h"
#import "SPRUploadViewController.h"

@implementation SPRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SPRHomeViewController *homeViewController = [SPRHomeViewController new];
    SPRUploadViewController *uploadViewController = [SPRUploadViewController new];
    homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:[UIImage imageNamed:@"find_user"] tag:1001];
    uploadViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Upload" image:[UIImage imageNamed:@"external"] tag:1002];
    
    UITabBarController *rootViewController = [[UITabBarController alloc] init];
    rootViewController.viewControllers = @[homeViewController, uploadViewController];
    
    self.window.rootViewController = rootViewController ;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
