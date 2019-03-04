//
//  HBLSensorDataCollector.m
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

@import AVFoundation;
#import "HBLSensorDataCollector.h"
#import "HBLBrightnessCollector.h"
#import "HBLSensorDefine.h"
#import "HBLDataStorage.h"
#import "HBLSensorLocationManager.h"
#import <CoreMotion/CMAltimeter.h>
#import <CoreMotion/CoreMotion.h>
#import <ImageIO/ImageIO.h>


@interface HBLSensorDataCollector()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMAltimeter *altimeter; // 气压计
@property (nonatomic, strong) HBLBrightnessCollector *brightnessCollector;
@property (nonatomic, strong) HBLSensorLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *brightTimer;
@property (nonatomic, strong) NSTimer *altimeterTimer;

@end

@implementation HBLSensorDataCollector

+ (instancetype)shared {
    static HBLSensorDataCollector *collector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        collector = [[HBLSensorDataCollector alloc] init];
    });
    return collector;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.operationQueue = [NSOperationQueue new];
        self.motionManager = [[CMMotionManager alloc] init];
        self.brightnessCollector = [HBLBrightnessCollector new];
        self.altimeter = [[CMAltimeter alloc]init];
        self.locationManager = [HBLSensorLocationManager new];
    }
    return self;
}

- (void)startCollectLocation {
    // GPS + 海拔
    [self.locationManager startForegroundLocationUpdate];
    [self storeSensorLocation];
}

- (void)storeSensorLocation {
    __weak typeof(self) weakSelf = self;
    self.locationManager.sensorLocationBlock = ^(CLLocation *location) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf storeLocationData:location];
    };
}

- (void)startBgContinueLocation {
    [self.locationManager startBackgroundLocationUpdate];
}

- (void)sensorLog:(NSString *)formatStr data:(NSString *)data {
    if (HBL_SENSORDATA_LOG_ENABLED) {
        NSLog(formatStr, data);
    }
}

- (void)collectAllInformationWithInterval:(NSTimeInterval)defaultInterval {
    [self collectTimerInfoFirst];
    // 加速度
    [self accelerometerData:defaultInterval result:^(double x, double y, double z) {
        NSString *value = [NSString stringWithFormat:@"%f,%f,%f", x, y, z];
        NSString *timeSp = [self currentTimestamp];
        NSDictionary *info = [self dataStructureWithName:HBL_ACCELEROMETER_NAME type:HBL_ACCELEROMETER value:value timestamp:timeSp];
        [[HBLDataStorage shared] storeData:info];
        [self sensorLog:@" accelerometer data : %@" data:value];
    }];
    // 重力加速度 + 线性加速度 + 旋转欧拉角
    [self deviceMotionData:defaultInterval result:^(CMAcceleration gravity, CMAcceleration userAcceleration, CMAttitude *attitude) {
        NSMutableArray *infoList = [NSMutableArray array];
        
        NSString *timeSp = [self currentTimestamp];
        NSString *gravityV = [NSString stringWithFormat:@"%f,%f,%f", gravity.x, gravity.y, gravity.z];
        NSDictionary *gravityInfo = [self dataStructureWithName:HBL_GRAVITY_NAME type:HBL_GRAVITY value:gravityV timestamp:timeSp];
        [infoList addObject:gravityInfo];
        [self sensorLog:@" gravity data : %@" data:gravityV];
        
        NSString *userAccelerationV = [NSString stringWithFormat:@"%f,%f,%f", userAcceleration.x, userAcceleration.y, userAcceleration.z];
        NSDictionary *userAccelerationInfo = [self dataStructureWithName:HBL_LINEAR_ACCELERATION_NAME type:HBL_LINEAR_ACCELERATION value:userAccelerationV timestamp:timeSp];
        [infoList addObject:userAccelerationInfo];
        [self sensorLog:@" userAcceleration data : %@" data:userAccelerationV];
        
        NSString *attitudeV = [NSString stringWithFormat:@"%f,%f,%f", attitude.yaw, attitude.pitch, attitude.roll];
        NSDictionary *attitudeInfo = [self dataStructureWithName:HBL_ORIENTATION_NAME type:HBL_ORIENTATION value:attitudeV timestamp:timeSp];
        [infoList addObject:attitudeInfo];
        [[HBLDataStorage shared] storeDataList:infoList];
        [self sensorLog:@" attitude data : %@" data:attitudeV];
    }];
    // 陀螺仪
    [self gyroData:defaultInterval result:^(double x, double y, double z) {
        NSString *timeSp = [self currentTimestamp];
        NSString *gyroV = [NSString stringWithFormat:@"%f,%f,%f", x, y, z];
        NSDictionary *gyroInfo = [self dataStructureWithName:HBL_GYROSCOPE_NAME type:HBL_GYROSCOPE value:gyroV timestamp:timeSp];
        [[HBLDataStorage shared] storeData:gyroInfo];
        [self sensorLog:@" gyro data : %@" data:gyroV];
    }];
    
    // 光线
    //    [self brightnessWithUpdateInterval:defaultInterval resultBlock:^(float brightness) {
    //        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    //        NSString *brightV = [NSString stringWithFormat:@"%f", brightness];
    //        NSDictionary *brightInfo = [self dataStructureWithName:HBL_LIGHT_NAME type:HBL_LIGHT value:brightV timestamp:timeSp];
    //        [self.storage storeData:brightInfo];
    //        NSLog(@" bright data : %@", brightV);
    //    }];
    
    // 气压计
    [self altimeterData:defaultInterval result:^(double altitudeData) {
        [self storeAltimeterData:altitudeData];
    }];
    // 磁场
    [self magnetometerData:defaultInterval result:^(double x, double y, double z) {
        NSString *timeSp = [self currentTimestamp];
        NSString *magnetometerV = [NSString stringWithFormat:@"%f,%f,%f", x, y, z];
        NSDictionary *magnetometerInfo = [self dataStructureWithName:HBL_MAGNETIC_FIELD_NAME type:HBL_MAGNETIC_FIELD value:magnetometerV timestamp:timeSp];
        [[HBLDataStorage shared] storeData:magnetometerInfo];
        [self sensorLog:@" magnetometer data : %@" data:magnetometerV];
    }];
}

- (void)collectTimerInfoFirst {
    [self collectAltimeterWithResultBlock:^(double altitude) {
        [self storeAltimeterData:altitude];
    }];
}

#pragma mark - store
- (void)storeAltimeterData:(double)altitudeData {
    NSString *timeSp = [self currentTimestamp];
    NSString *altimeterV = [NSString stringWithFormat:@"%f", altitudeData];
    NSDictionary *altimeterInfo = [self dataStructureWithName:HBL_PRESSURE_NAME type:HBL_PRESSURE value:altimeterV timestamp:timeSp];
    [[HBLDataStorage shared] storeData:altimeterInfo];
    [self sensorLog:@" altimeter data : %@" data:altimeterV];
}

- (void)storeLocationData:(CLLocation *)location {
    NSMutableArray *infoList = [NSMutableArray array];
    
    NSString *timeSp = [self currentTimestamp];
    NSString *locationV = [NSString stringWithFormat:@"%f,%f", location.coordinate.longitude, location.coordinate.latitude];
    NSDictionary *locationInfo = [self dataStructureWithName:HBL_GPS_NAME type:HBL_GPS value:locationV timestamp:timeSp];
    [infoList addObject:locationInfo];
    [self sensorLog:@" location data : %@" data:locationV];
    
    NSString *altitudeV = [NSString stringWithFormat:@"%f", location.altitude];
    NSDictionary *altitudeInfo = [self dataStructureWithName:HBL_ALTITUDE_NAME type:HBL_ALTITUDE value:altitudeV timestamp:timeSp];
    [infoList addObject:altitudeInfo];
    [[HBLDataStorage shared] storeDataList:infoList];
    [self sensorLog:@" altitude data : %@" data:altitudeV];
}

#pragma mark - NSTimer
- (void)brightnessWithUpdateInterval:(NSTimeInterval)updateInterval resultBlock:(void(^)(float brightness))resultBlock {
    [self stopBrightnessTimer];
    self.brightTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(collectBrightness:) userInfo:resultBlock repeats:YES];
}

- (void)altimeterData:(NSTimeInterval)interval result:(void(^)(double altitudeData))resultBlock {
    [self stopAltimeterTimer];
    self.altimeterTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(collectAltimeter:) userInfo:resultBlock repeats:YES];
}

- (void)collectAltimeter:(id)sender {
    void(^resultBlock)(double altitude) = [sender userInfo];
    [self collectAltimeterWithResultBlock:resultBlock];
}

- (void)collectAltimeterWithResultBlock:(void(^)(double altitude))resultBlock {
    if ([CMAltimeter isRelativeAltitudeAvailable]) {
        [self.altimeter startRelativeAltitudeUpdatesToQueue:self.operationQueue withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
            [self.altimeter stopRelativeAltitudeUpdates];
            resultBlock(altitudeData.pressure.doubleValue); // kPa
        }];
    }
}

- (void)collectBrightness:(id)sender {
    void(^resultBlock)(float brightness) = [sender userInfo];
    [self.brightnessCollector startBrightnessRunning:YES brightnessResult:^(float brightness) {
        if (resultBlock) {
            resultBlock(brightness);
        }
        [self.brightnessCollector stopBrightnessRunning];
    }];
}

#pragma mark - get sensor data
// 加速计
- (BOOL)accelerometerData:(NSTimeInterval)updateInterval result:(void(^)(double x, double y, double z))resultBlock{
    if (self.motionManager.accelerometerAvailable) {
        self.motionManager.accelerometerUpdateInterval = updateInterval;
        [self.motionManager startAccelerometerUpdatesToQueue:self.operationQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            // 指定子线程中执行
            CMAcceleration acceleration = accelerometerData.acceleration;
            resultBlock(acceleration.x, acceleration.y, acceleration.z);
        }];
        return YES;
    } else {
        return NO;
    }
}

// 陀螺仪
- (BOOL)gyroData:(NSTimeInterval)updateInterval result:(void(^)(double x, double y, double z))resultBlock{
    if (self.motionManager.gyroAvailable) {
        self.motionManager.gyroUpdateInterval = updateInterval;
        [self.motionManager startGyroUpdatesToQueue:self.operationQueue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            CMRotationRate rate = gyroData.rotationRate;
            resultBlock(rate.x, rate.y, rate.z);
        }];
        return YES;
    } else {
        return NO;
    }
}

// deviceMotion:陀螺仪 计算出的数据
- (BOOL)deviceMotionData:(NSTimeInterval)interval result:(void(^)(CMAcceleration gravity, CMAcceleration userAcceleration, CMAttitude *attitude))resultBlock {
    if (self.motionManager.deviceMotionAvailable) {
        self.motionManager.deviceMotionUpdateInterval = interval;
        [self.motionManager startDeviceMotionUpdatesToQueue:self.operationQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            // deviceMotion.magneticField：该属性返回校准后的磁场信息
            // deviceMotion.rotationRate：该属性返回原始的陀螺仪信息，该属性值基本等同于前面介绍的陀螺仪数据
            CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
            resultBlock(deviceMotion.gravity, deviceMotion.userAcceleration, deviceMotion.attitude);
        }];
        return YES;
    } else {
        return NO;
    }
}

// 磁场
- (BOOL)magnetometerData:(NSTimeInterval)updateInterval result:(void(^)(double x, double y, double z))resultBlock{
    if (self.motionManager.magnetometerAvailable) {
        self.motionManager.magnetometerUpdateInterval = updateInterval;
        [self.motionManager startMagnetometerUpdatesToQueue:self.operationQueue withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
            CMMagneticField field = magnetometerData.magneticField;
            resultBlock(field.x, field.y, field.z);
        }];
        return YES;
    } else {
        return NO;
    }
}

- (void)stopBrightnessTimer {
    if (self.brightTimer) {
        [self.brightTimer invalidate];
        _brightTimer = nil;
    }
}

- (void)stopAltimeterTimer {
    if (self.altimeter) {
        [self.altimeterTimer invalidate];
        _altimeterTimer = nil;
    }
}

- (NSDictionary *)dataStructureWithName:(NSString *)name
                                   type:(NSString *)type
                                  value:(NSString *)value
                              timestamp:(NSString *)timestamp {
    return @{
             @"sensorName": name,
             @"sensorType": type,
             @"sensorValue": value,
             @"timestamp": timestamp
             };
}

- (NSString *)currentTimestamp {
    return [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
}

@end

