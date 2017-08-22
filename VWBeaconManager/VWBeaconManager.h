//
//  VWBeaconManager.h
//  TonyBenconDemo
//
//  Created by TonyChan on 2017/8/10.
//  Copyright © 2017年 TonyChan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLBeaconRegion.h>


@class VWBeaconManager,CLBeacon,UIApplication;

@protocol VWBeaconManagerDelegate <NSObject>

- (void)beaconManager:(VWBeaconManager *)manager didRangeBeacon:(CLBeacon *)beacon;

@optional
- (void)beaconManager:(VWBeaconManager *)manager didUpdateState:(BOOL)isOpen;
@end

@interface VWBeaconManager : NSObject
/** 单例 */
+ (instancetype)shareManager;

@property(nonatomic,strong) id<VWBeaconManagerDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL authorizationStatus;

/**
 autoStartLocate : 默认YES
 是否自动开始定位
 */
@property (nonatomic, assign) BOOL autoStartLocate;
/**
 isScanNormalBLE : 默认NO
 是否扫描普通蓝牙
 */
@property (nonatomic, assign) BOOL isScanNormalBLE;

/**
 最少RSSI
 minRSSI : 默认-65
 大于这个值才会认为有效
 */
@property (nonatomic, assign) NSInteger minRSSI;


-(void)requestBluetoothAuthorization;

-(void)startRanging;
-(void)stopRanging;

-(void)scanForPeripherals;
-(void)stopScan;


/**
 想用后台模式的话 请在AppDelegate的相应方法调用此方法
 */
- (void)applicationDidEnterBackground:(UIApplication *)application;

/**
 想用后台模式的话 请在AppDelegate的相应方法调用此方法
 */
- (void)applicationWillEnterForeground:(UIApplication *)application;

@end

#import "VWBeaconManager+Util.h"
