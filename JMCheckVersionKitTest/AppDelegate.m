//
//  AppDelegate.m
//  JMCheckVersionKitTest
//
//  Created by james on 15/2/10.
//  Copyright (c) 2015年 james. All rights reserved.
//

#import "AppDelegate.h"
#import <JMCheckVersionKit.h>
#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    ViewController *viewController = [[ViewController alloc] init];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    JMCheckVersion *tool = [JMCheckVersion sharedInstace];
    tool.appId = @"376771144";
    tool.updateURL = @"https://itunes.apple.com/us/app/itunes-connect/id376771144?mt=8";
    NSLog(@"%@",self.window.rootViewController);
    tool.presentingViewController = self.window.rootViewController;
//    tool.debugEnabled = YES;
//    tool.availableMessageTitle = @"您有新的更新";
//    tool.updatingButtonTitle = @"立即更新";
//    tool.nextTimeButtonTitle = @"下一次";
//    tool.skippingButtonTitle = @"跳过";
    tool.alertType = JMCheckVersionAlertTypeWithSkip;
    tool.debugEnabled = YES;
    tool.forceLanguageLocalization = Default;
    [tool checkVersion:JMCheckVersionTypeWithImmediately];
    
//    NSLog(@"%@",    [NSBundle allFrameworks]);
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
//    NSDate *testDate = [formatter dateFromString:@"2015-02-05 07:19:07"];
//    
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    
//    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:[NSDate date] toDate:testDate options:0];
//    NSLog(@"   %li",(long)components.day);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
