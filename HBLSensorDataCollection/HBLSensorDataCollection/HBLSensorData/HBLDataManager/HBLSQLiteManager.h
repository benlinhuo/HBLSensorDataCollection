//
//  HBLSQLiteManager.h
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBLSQLiteManager : NSObject

+ (instancetype)shared;

- (BOOL)openDB;

- (BOOL)addInfoToDB:(NSDictionary *)info;

- (BOOL)addInfoListToDB:(NSArray *)dataList;

- (BOOL)deleteWithDataList:(NSArray *)dataList;

- (NSArray *)queryDataLimit:(NSString *)count;

- (NSArray *)queryDataLimit:(NSString *)count minID:(NSString *)minID;

@end

