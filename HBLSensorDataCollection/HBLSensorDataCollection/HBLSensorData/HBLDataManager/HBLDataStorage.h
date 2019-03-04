//
//  HBLDataStorage.h
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const limitCount = @"150";

@interface HBLDataStorage : NSObject

+ (instancetype)shared;

- (void)openDB;

- (void)storeData:(NSDictionary *)info;

- (void)storeDataList:(NSArray *)dataList;

- (void)doneBlockDataFromDB:(void(^)(NSArray *cacheData))doneBlock;

- (void)doneBlockDataFromDB:(void(^)(NSArray *cacheData))doneBlock minID:(NSString *)minID;

- (void)deleteData:(NSArray *)data;


@end

