//
//  HBLSensorDataCollector.h
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//


#import "HBLBaseSingleton.h"

@interface HBLSensorDataCollector : HBLBaseSingleton

/**
 * 收集传感器数据
 */
- (void)collectAllInformationWithInterval:(NSTimeInterval)defaultInterval;

/**
 * GPS因为需要权限，所以和其他传感器数据分开时机采集
 */
- (void)startCollectLocation;

- (void)startBgContinueLocation;

/**
 * 存储GPS位置数据
 * @param  isActualTime  是否实时存储到文件（进程杀死之后，需要实时）
 */
- (void)storeSensorLocation;

@end

