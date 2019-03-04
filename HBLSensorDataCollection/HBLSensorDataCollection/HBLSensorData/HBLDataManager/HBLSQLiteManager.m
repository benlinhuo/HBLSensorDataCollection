//
//  HBLSQLiteManager.m
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import "HBLSQLiteManager.h"
#import "HBLSensorDefine.h"
#import <sqlite3.h>


@interface HBLSQLiteManager  ()

@property (nonatomic, assign) sqlite3 *dataDB;

@end

@implementation HBLSQLiteManager // DataSensorStorage

- (void)dealloc {
    NSLog(@"HBLSQLiteManager dealloc");
}

+ (instancetype)shared {
    static HBLSQLiteManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HBLSQLiteManager new];
    });
    return manager;
}

- (BOOL)openDB {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"DataSensorStorage.sqlite"];
    sqlite3_shutdown();
    int err = sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    if (err != SQLITE_OK) {
        NSLog(@"setting sqlite thread safe mode to serialized failed!!! return code: %d", err);
        return NO;
    }
    NSLog(@"isThreadSafe %d", sqlite3_threadsafe());
    sqlite3_initialize();
    if (sqlite3_open_v2(dbPath.UTF8String, &_dataDB, SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX, NULL) != SQLITE_OK) {
        return NO;
    } else {
        NSString *createTbl = @"CREATE TABLE IF NOT EXISTS 'sensor_tbl' ('id' INTEGER PRIMARY KEY AUTOINCREMENT,'sensorName' TEXT,'sensorType' TEXT,'sensorValue' TEXT, 'timestamp' TEXT);";
        return [self execSQL:createTbl];
    }
}

- (BOOL)addInfoToDB:(NSDictionary *)info {
    NSString *sensorName = info[@"sensorName"] ? : @"";
    NSString *sensorType = info[@"sensorType"] ? : @"";
    NSString *sensorValue = info[@"sensorValue"] ? : @"";
    NSString *timestamp = info[@"timestamp"] ? : @"";
    
    NSString *addSql = [NSString stringWithFormat:@"INSERT INTO 'sensor_tbl' ('sensorName', 'sensorType', 'sensorValue', 'timestamp') values ('%@', '%@', '%@', '%@');", sensorName, sensorType, sensorValue, timestamp];
    return [self execSQL:addSql];
}

- (BOOL)addInfoListToDB:(NSArray *)dataList {
    NSString *addSql = @"INSERT INTO 'sensor_tbl' ('sensorName', 'sensorType', 'sensorValue', 'timestamp') values";
    for (int i = 0; i < dataList.count; i++) {
        NSDictionary *info = dataList[i];
        NSString *sensorName = info[@"sensorName"] ? : @"";
        NSString *sensorType = info[@"sensorType"] ? : @"";
        NSString *sensorValue = info[@"sensorValue"] ? : @"";
        NSString *timestamp = info[@"timestamp"] ? : @"";
        if (i > 0) {
            addSql = [NSString stringWithFormat:@"%@,", addSql];
        }
        addSql = [NSString stringWithFormat:@"%@ ('%@', '%@', '%@', '%@')", addSql, sensorName, sensorType, sensorValue, timestamp];
    }
    addSql = [NSString stringWithFormat:@"%@;", addSql];
    return [self execSQL:addSql];
}

- (BOOL)deleteDataWithDB {
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM 'sensor_tbl';"];
    return [self execSQL:deleteSql];
}

- (BOOL)deleteWithDataList:(NSArray *)dataList {
    NSString *sql = @"DELETE FROM 'sensor_tbl' where id in (";
    for (int i = 0; i < dataList.count; i++) {
        NSDictionary *info = dataList[i];
        NSString *idStr = info[@"id"];
        if (i > 0) {
            sql = [NSString stringWithFormat:@"%@,", sql];
        }
        sql = [NSString stringWithFormat:@"%@%@", sql, idStr];
    }
    sql = [NSString stringWithFormat:@"%@);", sql];
    return [self execSQL:sql];
}

- (NSArray *)queryDataLimit:(NSString *)count minID:(NSString *)minID {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'sensor_tbl' WHERE 'id' > %@ ORDER BY 'id' ASC LIMIT %@;", minID,count];
    return [self querySQL:sql];
}

- (NSArray *)queryDataLimit:(NSString *)count {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'sensor_tbl' ORDER BY 'id' ASC LIMIT %@;", count];
    return [self querySQL:sql];
}

- (NSArray *)queryAllData {
    NSString *sqlStr = @"SELECT * FROM 'sensor_tbl'";
    return [self querySQL:sqlStr];
}

- (NSArray *)querySQL:(NSString *)sqlStr {
    sqlite3_stmt *stmt = nil;
    if (sqlite3_prepare_v2(self.dataDB, sqlStr.UTF8String, -1, &stmt, nil) != SQLITE_OK) {
        NSLog(@"prepare query failed");
        return nil;
    }
    NSMutableArray *dictArr = [NSMutableArray array];
    [self sensorLog:@"HBLSQLiteManager querySQL thread: %@" data:[NSThread currentThread]];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int columnCount = sqlite3_column_count(stmt);
        NSMutableDictionary *dict = [NSMutableDictionary new];
        for (int i = 0; i < columnCount; i++) {
            const char *cKey = sqlite3_column_name(stmt, i);
            NSString *key = [NSString stringWithUTF8String:cKey];
            
            const char *cValue = (const char *)sqlite3_column_text(stmt, i);
            NSString *value = [NSString stringWithUTF8String:cValue];
            
            [dict setObject:value forKey:key];
        }
        [dictArr addObject:dict];
    }
    sqlite3_finalize(stmt);
    return dictArr;
}

- (BOOL)execSQL:(NSString *)sqlStr {
    char *error;
    @try {
        [self sensorLog:@"HBLSQLiteManager execSQL thread: %@" data:[NSThread currentThread]];
        if (sqlite3_exec(self.dataDB, sqlStr.UTF8String, nil, nil, &error) == SQLITE_OK) {
            return YES;
        } else {
            NSLog(@"执行SQL语句报错：%s", error);
            return NO;
        }
    } @catch (NSException *e) {
        return NO;
    }
    
}

- (void)sensorLog:(NSString *)formatStr data:(id)data {
    if (HBL_SENSORDATA_LOG_ENABLED) {
        NSLog(formatStr, data);
    }
}

@end

