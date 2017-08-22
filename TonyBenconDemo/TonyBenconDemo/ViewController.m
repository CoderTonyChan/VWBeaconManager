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



@implementation NSString (YYAdd)
- (NSString *)stringByTrim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}
@end



@implementation NSNumber (YYAdd)

+ (NSNumber *)numberWithString:(NSString *)string {
    NSString *str = [[string stringByTrim] lowercaseString];
    if (!str || !str.length) {
        return nil;
    }
    
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{@"true" :   @(YES),
                @"yes" :    @(YES),
                @"false" :  @(NO),
                @"no" :     @(NO),
                @"nil" :    [NSNull null],
                @"null" :   [NSNull null],
                @"<null>" : [NSNull null]};
    });
    id num = dic[str];
    if (num) {
        if (num == [NSNull null]) return nil;
        return num;
    }
    
    // hex number
    int sign = 0;
    if ([str hasPrefix:@"0x"]) sign = 1;
    else if ([str hasPrefix:@"-0x"]) sign = -1;
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:str];
        unsigned num = -1;
        BOOL suc = [scan scanHexInt:&num];
        if (suc)
            return [NSNumber numberWithLong:((long)num * sign)];
        else
            return nil;
    }
    // normal number
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

@end


@implementation ViewController


NSTimer *timer2;
- (void)viewDidLoad {
    [super viewDidLoad];
    
#if 0
    __block int i =0;//这个值是用来测试后台用运行情况，
    timer2= [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnulltimer) {
        NSLog(@"%d",i ++);
        [[VWBeaconManager shareManager] scanForPeripherals];
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
    [timer2 fire];
    
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        NSLog(@"scheduledTimerWithTimeInterval -- %d",i ++);
    }];
#endif
    
    
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
#if 0
    //method0
    long long subID = longID & 0x0000FFFF;
    NSString *stringID = [NSString stringWithFormat:@"%lli",subID];
    
    /**
     2017-08-11 09:06:41.586588+0800 TonyBenconDemo[5127:3152735] NSScanner ======= 8965
     2017-08-11 09:06:41.586890+0800 TonyBenconDemo[5127:3152735] sscanf ======= 8965
     2017-08-11 09:06:41.587290+0800 TonyBenconDemo[5127:3152735] YYADD----------8965
     */
    //method1
    NSScanner *scanner = [NSScanner scannerWithString:subIDStr];
    unsigned int hexNum;
    [scanner scanHexInt:&hexNum];
    NSLog(@"NSScanner ======= %i",hexNum);
    
    //method2
    const char *hexChar = [subIDStr cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned int hexNumber;
    sscanf(hexChar, "%x", &hexNumber);
    NSLog(@"sscanf ======= %i",hexNumber);
    
    //method3
    NSString *hexStr = [@"0x" stringByAppendingString:subIDStr];
    NSNumber *hex = [NSNumber numberWithString:hexStr];
    NSLog(@"YYADD ======= %@",hex);
    
#endif
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
