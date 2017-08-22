//
//  VWBeaconManager+Util.m
//  TonyBenconDemo
//
//  Created by TonyChan on 2017/8/11.
//  Copyright © 2017年 TonyChan. All rights reserved.
//

#import "VWBeaconManager+Util.h"

@implementation VWBeaconManager (Util)

- (NSNumber *)majorNumberWithVMHomeID:(long long)homeID{
    long long subID = homeID & 0x0000FFFF;
    return @(subID);
}

- (NSNumber *)majorNumberWithHomeID:(NSString *)homeID{
    long long longID = [homeID longLongValue];
    return [self majorNumberWithVMHomeID:longID];
}

@end
