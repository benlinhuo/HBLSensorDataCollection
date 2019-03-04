//
//  HBLDataManager.m
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import "HBLDataManager.h"
#import "HBLDataStorage.h"
#import "HBLDataUpload.h"
#import "HBLSensorDataCollector.h"
#import "HBLSensorDefine.h"
#import <UIKit/UIKit.h>
//#import "HBLDeviceGeneralParameter.h"
//#import "HBLUrlForRequest.h"
//#import "HBLLoginConfigManager.h"

static NSTimeInterval const defaultUploadInterval = 1 * 60; // 1 minute
static NSTimeInterval const defaultCollectInterval = 5; // 1 second

@interface HBLDataManager ()

@property (nonatomic, assign) NSTimeInterval uploadTimeInterval;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) HBLDataUpload *uploadViewModel;
@property (nonatomic, strong) dispatch_queue_t requestQueue;
@property (nonatomic, assign) BOOL isContinue;

@end

@implementation HBLDataManager

+ (instancetype)shared {
    static HBLDataManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HBLDataManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self && [self isEnableCollector]) {
        self.isContinue = NO;
        _requestQueue = dispatch_queue_create("queue.com.hbl.sensorDataRequest", DISPATCH_QUEUE_SERIAL);
        [[HBLDataStorage shared] openDB];
        _uploadViewModel = [[HBLDataUpload alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminateApp) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActiveOperation) name:UIApplicationDidBecomeActiveNotification object:nil];
        NSTimeInterval timeInterval = self.uploadTimeInterval ? : defaultUploadInterval;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(uploadFileDataToServerTimer) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc {
    _timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDataUploadTimeInterval:(NSTimeInterval)time {
    self.uploadTimeInterval = time;
}

- (void)willTerminateApp {
    if (HBL_BACKGROUND_LOCATION_ENABLE) {
        [[HBLSensorDataCollector shared] startBgContinueLocation];
        //        [[HBLDataStorage shared] storeData:@{@"sensorName": @"willTerminateApp", @"sensorType": @"1111", @"timestamp": [self currentTimestamp]}]; // test
    }
}

- (void)didEnterBackground {
    if (HBL_BACKGROUND_LOCATION_ENABLE) {
        [[HBLSensorDataCollector shared] startBgContinueLocation];
    }
}

- (void)becomeActiveOperation {
    [[HBLSensorDataCollector shared] collectAllInformationWithInterval:defaultCollectInterval];
    [self uploadFileDataToServerTimer];
}

- (void)startCollectLocation {
    
    if ([self isEnableCollector]) {
        [[HBLSensorDataCollector shared] startCollectLocation];
    }
}

- (NSString *)currentTimestamp {
    return [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
}

/**
 * 后台定位被唤醒
 */
- (void)backgroundStoreLocation:(NSDictionary *)launchOptions {
    if (HBL_BACKGROUND_LOCATION_ENABLE && [self isEnableCollector]) {
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            [[HBLSensorDataCollector shared] storeSensorLocation];
            [[HBLSensorDataCollector shared] startBgContinueLocation];
            //            [[HBLDataStorage shared] storeData:@{@"sensorName":@"UIApplicationLaunchOptionsLocationKey",  @"timestamp": [self currentTimestamp]}]; // test
        }
    }
}

- (void)uploadFileDataToServerTimer {
    [self uploadFileDataToServer:YES minID:@"-1"];
}

// 分批上传
- (void)uploadFileDataToServer:(BOOL)isFirst minID:(NSString *)minID {
    if (isFirst && self.isContinue) { // 主动调用和递归调用，舍弃一个
        return;
    }
    [[HBLDataStorage shared] doneBlockDataFromDB:^(NSArray *cacheData) {
        if (cacheData.count > 0) {
            [self.uploadViewModel sendRequestWithData:cacheData CompletionBlock:^(BOOL isRequestSuccess) {
                if (isRequestSuccess) {
                    [[HBLDataStorage shared] deleteData:cacheData];
                    if (cacheData.count >= limitCount.integerValue) {
                        self.isContinue = YES;
                        NSDictionary *info = cacheData[cacheData.count - 1];
                        NSString *idStr = info[@"id"];
                        [self uploadFileDataToServer:NO minID:idStr];
                    } else {
                        self.isContinue = NO;
                    }
                }
            }];
        }
    } minID:minID];
}

- (BOOL)isEnableCollector {
    return YES; // 测试用
    
#if TARGET_IPHONE_SIMULATOR
    return NO;
#elif TARGET_OS_IPHONE
    if([HBLUrlForRequest defaultUrlType] != HBLUrlTypeProduct ||
       ![HBLLoginConfigManager sharedInstance].isShowWeiXinLogin) {
        return NO;
    }
    CGFloat version = [UIDevice currentDevice].systemVersion.floatValue;
    // iphone 6/6p 以下（包括），不做收集
    if (version < 9.0 || [self Low6And6P]) {
        return NO;
    }
    return YES;
#endif
}

// iphone 6/6p 以下（包括），不做收集
- (BOOL)Low6And6P { //
//    NSString *platform = [HBLDeviceGeneralParameter getDeviceVersion]; // iPhone7,1
//    //针对苹果审核的奇葩机型做特殊处理，例如device model = xxx
//    if(!platform || ![platform hasPrefix:@"iPhone"]){
//        return YES;
//    }
//    NSArray *list = [platform componentsSeparatedByString:@","];
//    NSString *numStr = @"";
//    NSString *phoneStr = @"iPhone";
//    if (list.count > 0) {
//        numStr = list[0];
//    }
//    NSString *num = [platform substringWithRange:NSMakeRange(phoneStr.length, numStr.length - phoneStr.length)];
//    if (num.floatValue < 8) {
//        return YES;
//    }
    return NO;
}

@end
