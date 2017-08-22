//
//  AppDelegate.m
//  TonyBenconDemo
//
//  Created by TonyChan on 2017/8/10.
//  Copyright © 2017年 TonyChan. All rights reserved.
//

#import "AppDelegate.h"
#import "VWBeaconManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

NSTimer *timer;
- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIDevice*device = [UIDevice currentDevice];
    
    BOOL backgroundSupported =NO;
    
    if([device respondsToSelector:@selector(isMultitaskingSupported)]) {
        backgroundSupported =YES;
    }
    
    __block UIBackgroundTaskIdentifier bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
        
        [application endBackgroundTask:bgTaskId];
        
        bgTaskId = UIBackgroundTaskInvalid;
        
    }];
    
    if(backgroundSupported) {
//        __block int i =0;//这个值是用来测试后台用运行情况，
//        
//        timer= [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnulltimer) {
//            NSLog(@"%d",i ++);
//            [[VWBeaconManager shareManager] scanForPeripherals];
//        }];
//        
//        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//        [timer fire];
        
        
        [[VWBeaconManager shareManager] applicationDidEnterBackground:application];
    }
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[VWBeaconManager shareManager] applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
