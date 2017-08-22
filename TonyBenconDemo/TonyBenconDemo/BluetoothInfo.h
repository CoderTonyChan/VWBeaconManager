//
//  BluetoothInfoDictionary.h
//  TonyBenconDemo
//
//  Created by TonyChan on 2017/8/11.
//  Copyright © 2017年 TonyChan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBPeripheral;

@interface BluetoothInfo : NSObject

@property (nonatomic, strong) NSUUID *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSNumber *RSSI;
/** peripheral */
@property (nonatomic, strong) CBPeripheral *peripheral;


@end
