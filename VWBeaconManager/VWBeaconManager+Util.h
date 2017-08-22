//
//  VWBeaconManager+Util.h
//  TonyBenconDemo
//
//  Created by TonyChan on 2017/8/11.
//  Copyright © 2017年 TonyChan. All rights reserved.
//

#import "VWBeaconManager.h"

@interface VWBeaconManager (Util)
/**
 @param homeID 雨蛙的homeID
 @return beacon.major
 */
- (NSNumber *)majorNumberWithHomeID:(NSString *)homeID;
- (NSNumber *)majorNumberWithVMHomeID:(long long)homeID;
@end
