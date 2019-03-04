//
//  HBLDataManager.h
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBLDataManager : NSObject

+ (instancetype)shared;

/**
 * 设置多个传感器数据的采集间隔，不包括GPS及海报
 */
- (void)setDataUploadTimeInterval:(NSTimeInterval)time;

/**
 * GPS采集频率：通过变动距离超过多少米（只包括前台以及切后台且活着情况）
 * 后期可以考虑根据当前速度等一些因素来及时变动采集频率
 */
- (void)startCollectLocation;

- (void)backgroundStoreLocation:(NSDictionary *)launchOptions;

@end
