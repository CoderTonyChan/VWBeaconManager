//
//  VWBeaconManager.m
//  TonyBenconDemo
//
//  Created by TonyChan on 2017/8/10.
//  Copyright © 2017年 TonyChan. All rights reserved.
//

#import "VWBeaconManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIApplication.h>

#import "BluetoothInfo.h"

@interface VWBeaconManager()<CBCentralManagerDelegate,CLLocationManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CLLocationManager *locationManager;

/** locationAuthorizationStatus */
@property (nonatomic, assign, readonly) BOOL bluetoothAuthorizationStatus;
@property (nonatomic, assign, readonly) BOOL locationAuthorizationStatus;

/** lastBeacon */
@property (nonatomic, strong) CLBeacon *lastBeacon;




/** ===== advertisementDatas BluetoothInfo ====== */
@property (nonatomic, strong) NSMutableSet<BluetoothInfo *> *bles;

/** sortedBLE : 由于蓝牙连接数有限制 所以可以用这个去限制 */
@property (nonatomic, strong) NSArray<BluetoothInfo *> *sortedBLE;

/** peripheralTimer */
@property (nonatomic, strong) NSTimer *peripheralTimer;

/** lastRoomID */
@property (nonatomic, assign) NSInteger lastRoomID;

@end


@implementation VWBeaconManager



#pragma mark - Public Method
+ (instancetype)shareManager{
    static VWBeaconManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


-(instancetype)init{
    if (self = [super init]) {
        // 权限
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        // 位置
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // 默认配置
        NSString *taruuid=@"CDA50893-8888-6FA5-AECC-A6EB0B137525";
        // Create a NSUUID with the same UUID as the broadcasting beacon
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:taruuid];
        // Setup a new region with that UUID and same identifier as the broadcasting beacon
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"HYXK"];
        
        self.autoStartLocate = YES;
        self.isScanNormalBLE = NO;
        self.minRSSI = - 85;
        
        self.bles = [NSMutableSet set];
        
        [self.locationManager requestWhenInUseAuthorization];
    }
    return self;
}



- (void)startRanging{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)stopRanging{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)requestBluetoothAuthorization{
    // 蓝牙
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // 位置
    
    if (!self.locationAuthorizationStatus) {
        NSLog(@"提示");
    }
    
}

- (BOOL)authorizationStatus{
    return self.bluetoothAuthorizationStatus && self.locationAuthorizationStatus;
}


-(void)scanForPeripherals{
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}


-(void)stopScan{
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        [self.centralManager stopScan];
    }
}


#pragma mark - Private Method
- (BOOL)bluetoothAuthorizationStatus{
    return self.centralManager.state == CBManagerStatePoweredOn;
}

- (BOOL)locationAuthorizationStatus{
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
    [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
}


#pragma mark - <CBPeripheralDelegate>
/**
 后台模式前用这个回调搜索
 */
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error{
    
    [self centralManager:_centralManager didDiscoverPeripheral:peripheral advertisementData:[NSDictionary dictionary] RSSI:RSSI];
    
    // TODO: 回调
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds",backgroundTimeRemaining);
    }
    
    CBPeripheral *sortedPeripheral = _sortedBLE.firstObject.peripheral;
    if (_sortedBLE.count>=2 && _sortedBLE.firstObject.RSSI.integerValue - _sortedBLE[1].RSSI.integerValue <=20) {
        return;
    }
    NSLog(@"%@",sortedPeripheral);
    
}


#pragma mark - <CBCentralManagerDelegate>
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (self.delegate && [self.delegate respondsToSelector:@selector(beaconManager:didUpdateState:)]) {
        [self.delegate beaconManager:self didUpdateState:self.authorizationStatus];
    }
    
    if (_autoStartLocate) {
        [self startRanging];
    }
    
    if (central.state == CBManagerStatePoweredOn && _isScanNormalBLE) {
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}


/**
 前台模式前用这个回调搜索(这个函数也负责更新维护数组)
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    // 这里可以制造规则 比如 HYXK-HomeID-RoomID
    NSLog(@"%@",peripheral.name);
    
    if (![peripheral.name hasPrefix:@"HYXK"]) return;
    
//    NSMutableDictionary *ble = [[NSMutableDictionary alloc] initWithDictionary:advertisementData];
//    ble[@"identifier"] = peripheral.identifier;
//    ble[@"name"] = peripheral.name;
//    NSLog(@"%@",_bles);
    
    BluetoothInfo *ble = [[BluetoothInfo alloc] init];
    ble.RSSI = RSSI;
    ble.identifier = peripheral.identifier;
    ble.name = peripheral.name;
    ble.peripheral = peripheral;
    
    if ([_bles containsObject:ble]) {
        [_bles removeObject:ble];
        [_bles addObject:ble];
    }else{
        [_bles addObject:ble];
    }
    
    NSArray *sortedBLE = [_bles sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"RSSI" ascending:NO]]];
    _sortedBLE = sortedBLE;
    NSLog(@"%@",sortedBLE);
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    NSLog(@"%@",dict);
}



#pragma mark - <CLLocationManagerDelegate>

/**
 第一次也会调用
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (self.delegate && [self.delegate respondsToSelector:@selector(beaconManager:didUpdateState:)]) {
        [self.delegate beaconManager:self didUpdateState:self.authorizationStatus];
    }
    
    if (_autoStartLocate) {
        [self startRanging];
    }
}


/**
 目测并不会调用
 */
- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"enter region");
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"exit region");
}
-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion*)region
{
//    NSLog(@"didRangeBeacons: %@", beacons);
//    if (![region.proximityUUID isEqual:_beaconRegion.proximityUUID]) return;
    
    NSArray<CLBeacon *> *filterArray = [[beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"rssi < 0"]] sortedArrayUsingComparator:^NSComparisonResult(CLBeacon *obj1, CLBeacon *obj2) {
        return NSOrderedAscending;
    }];
    
    if (filterArray.count == 0) return;
    CLBeacon *maxBeacon = [filterArray firstObject];
    if(maxBeacon.rssi< _minRSSI) return;
    if (filterArray.count>2 && filterArray[0].rssi - filterArray[1].rssi <=15) return;
    
    NSLog(@"%@",filterArray.firstObject);

//    NSLog(@"didRangeBeacons: %@", filterArray);
    
    if(!_lastBeacon){
        _lastBeacon = maxBeacon;
        if (self.delegate && [self.delegate respondsToSelector:@selector(beaconManager:didRangeBeacon:)]) {
            [self.delegate beaconManager:self didRangeBeacon:maxBeacon];
        }
    }else{
        if([maxBeacon.major isEqual:_lastBeacon.major]&&[maxBeacon.minor isEqual:_lastBeacon.minor]){
            return;
        }
        _lastBeacon = maxBeacon;
        if (self.delegate && [self.delegate respondsToSelector:@selector(beaconManager:didRangeBeacon:)]) {
            [self.delegate beaconManager:self didRangeBeacon:maxBeacon];
        }
    }

}
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

- (void)readRSSI{
    for (BluetoothInfo *info in self.sortedBLE) {
        CBPeripheral *peripheral = info.peripheral;
        [peripheral readRSSI];
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application{
    UIDevice *device = [UIDevice currentDevice];
    
    BOOL backgroundSupported = [device respondsToSelector:@selector(isMultitaskingSupported)];
    
    __block UIBackgroundTaskIdentifier bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTaskId];
        bgTaskId = UIBackgroundTaskInvalid;
    }];
    
    if(!backgroundSupported) {
        return;
    }
    
    // 连接BluetoothInfo
    for (BluetoothInfo *info in _sortedBLE) {
        CBPeripheral *peripheral = info.peripheral;
        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@(YES)}];
        peripheral.delegate = self;
    }
    
    NSTimer *peripheralTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(readRSSI) userInfo:nil repeats:YES];
    _peripheralTimer = peripheralTimer;
    [peripheralTimer fire];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    // Timer
    [_peripheralTimer invalidate];
    _peripheralTimer = nil;
    
    // 取消连接BluetoothInfo
    for (BluetoothInfo *info in _sortedBLE) {
        CBPeripheral *peripheral = info.peripheral;
        [self.centralManager cancelPeripheralConnection:peripheral];
        peripheral.delegate = nil;
    }
    
}
@end
