//
//  HBLDataStorage.m
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import "HBLDataStorage.h"
#import "HBLSensorDefine.h"
#import "HBLSQLiteManager.h"


@interface HBLDataStorage ()

@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end

@implementation HBLDataStorage

+ (instancetype)shared {
    static HBLDataStorage *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HBLDataStorage alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _ioQueue = dispatch_queue_create("queue.com.hbl.sensorDataStorage", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - public method

- (void)openDB {
    dispatch_sync(self.ioQueue, ^{
        [[HBLSQLiteManager shared] openDB];
    });
}

- (void)storeDataList:(NSArray *)dataList {
    dispatch_async(self.ioQueue, ^{
        [[HBLSQLiteManager shared] addInfoListToDB:dataList];
        [self sensorLog:@"HBLDataStorage storeDataList thread: %@" data:[NSThread currentThread]];
    });
}

- (void)storeData:(NSDictionary *)info {
    dispatch_async(self.ioQueue, ^{
        [[HBLSQLiteManager shared] addInfoToDB:info];
        [self sensorLog:@"HBLDataStorage storeData thread: %@" data:[NSThread currentThread]];
    });
}

- (void)doneBlockDataFromDB:(void(^)(NSArray *cacheData))doneBlock minID:(NSString *)minID {
    dispatch_async(self.ioQueue, ^{
        NSArray *dataList = [[HBLSQLiteManager shared] queryDataLimit:limitCount minID:minID];
        if (doneBlock) {
            doneBlock(dataList);
        }
        [self sensorLog:@"HBLDataStorage doneBlockDataFromDB minID thread: %@" data:[NSThread currentThread]];
    });
}

- (void)doneBlockDataFromDB:(void(^)(NSArray *cacheData))doneBlock {
    dispatch_async(self.ioQueue, ^{
        NSArray *dataList = [[HBLSQLiteManager shared] queryDataLimit:limitCount];
        if (doneBlock) {
            doneBlock(dataList);
        }
        [self sensorLog:@"HBLDataStorage doneBlockDataFromDB thread: %@" data:[NSThread currentThread]];
    });
}

- (void)deleteData:(NSArray *)data {
    dispatch_async(self.ioQueue, ^{
        [[HBLSQLiteManager shared] deleteWithDataList:data];
        [self sensorLog:@"HBLDataStorage deleteData thread: %@" data:[NSThread currentThread]];
    });
}

- (void)sensorLog:(NSString *)formatStr data:(id)data {
    if (HBL_SENSORDATA_LOG_ENABLED) {
        NSLog(formatStr, data);
    }
}

@end

