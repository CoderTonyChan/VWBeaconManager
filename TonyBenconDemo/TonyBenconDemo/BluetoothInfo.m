//
//  BluetoothInfoDictionary.m
//  TonyBenconDemo
//
//  Created by TonyChan on 2017/8/11.
//  Copyright © 2017年 TonyChan. All rights reserved.
//

#import "BluetoothInfo.h"

@implementation BluetoothInfo

- (BOOL)isEqual:(BluetoothInfo *)object{
    if (![object isKindOfClass:[BluetoothInfo class]]) {
        return NO;
    }
    return [self.identifier isEqual:object.identifier];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"name : %@ === RSSI : %@",self.name,self.RSSI];
}

@end
