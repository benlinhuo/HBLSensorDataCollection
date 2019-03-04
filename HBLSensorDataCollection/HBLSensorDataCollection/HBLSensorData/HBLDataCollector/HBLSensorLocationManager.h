//
//  HBLSensorLocationManager.h
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface HBLSensorLocationManager : CLLocationManager

/**
 * 定位数据上传（传感器）
 */
@property (nonatomic, copy) void(^sensorLocationBlock)(CLLocation *location) ;

- (void)startForegroundLocationUpdate;

- (void)startBackgroundLocationUpdate;

@end
