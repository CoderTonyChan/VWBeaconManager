//
//  ViewController.m
//  TonyBenconDemo
//
//  Created by TonyChan on 2017/8/10.
//  Copyright © 2017年 TonyChan. All rights reserved.
//

#import "ViewController.h"
#import "VWBeaconManager.h"

@interface ViewController ()<VWBeaconManagerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *bleSwitch;
@property (weak, nonatomic) IBOutlet UILabel *hudLabel;

@end

@implementation ViewController


NSTimer *timer2;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [VWBeaconManager shareManager].delegate = self;
    VWBeaconManager.shareManager.isScanNormalBLE = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)bleValueChanged:(UISwitch *)sender {
    [[VWBeaconManager shareManager] requestBluetoothAuthorization];
    sender.on = [VWBeaconManager shareManager].authorizationStatus;
    sender.enabled = ![VWBeaconManager shareManager].authorizationStatus;
}


#pragma mark - <VWBeaconManagerDelegate>
- (void)beaconManager:(VWBeaconManager *)manager didRangeBeacon:(CLBeacon *)beacon{
    NSString *homeID = @"1500884378373";
    if ([beacon.major isEqual:[manager majorNumberWithHomeID:homeID]]) {
        NSLog(@"major ======= %@",[manager majorNumberWithHomeID:homeID]);
    }
    _hudLabel.text = [NSString stringWithFormat:@"进入 HomeID :%@  RoomID :%@ 的房间",beacon.major,beacon.minor];
    NSLog(@"进入 HomeID :%@  RoomID :%@ 的房间",beacon.major,beacon.minor);
}

- (NSNumber *)majorNumberWithHomeID:(NSString *)homeID{
    long long longID = [homeID longLongValue];
    long long subID = longID & 0x0000FFFF;
    return @(subID);
}

- (void)beaconManager:(VWBeaconManager *)manager didUpdateState:(BOOL)isOpen{
    _bleSwitch.on = isOpen;
    _bleSwitch.enabled = !isOpen;
}

@end
