//
//  HBLSensorDefine.h
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#ifndef HBLSensorDefine_h
#define HBLSensorDefine_h

static NSString * const HBL_ACCELEROMETER = @"TYPE_ACCELEROMETER";
static NSString * const HBL_ACCELEROMETER_NAME = @"加速度传感器";

static NSString * const HBL_GRAVITY = @"TYPE_GRAVITY";
static NSString * const HBL_GRAVITY_NAME = @"重力传感器";

static NSString * const HBL_GYROSCOPE = @"TYPE_GYROSCOPE";
static NSString * const HBL_GYROSCOPE_NAME = @"陀螺仪传感器";

static NSString * const HBL_LINEAR_ACCELERATION = @"TYPE_LINEAR_ACCELERATION";
static NSString * const HBL_LINEAR_ACCELERATION_NAME = @"线性加速度传感器";

static NSString * const HBL_PRESSURE = @"TYPE_PRESSURE";
static NSString * const HBL_PRESSURE_NAME = @"压力传感器";

//static NSString * const HBL_LIGHT = @"TYPE_LIGHT";
//static NSString * const HBL_LIGHT_NAME = @"光线传感器";
//
//static NSString * const HBL_AMBIENT_TEMPERATURE = @"TYPE_AMBIENT_TEMPERATURE"; // 只可以是设备内部温度，无法获取空气温度
//static NSString * const HBL_AMBIENT_TEMPERATURE_NAME = @"设备内部温度";

static NSString * const HBL_MAGNETIC_FIELD = @"TYPE_MAGNETIC_FIELD";
static NSString * const HBL_MAGNETIC_FIELD_NAME = @"磁场传感器";

static NSString * const HBL_ORIENTATION = @"TYPE_ORIENTATION_Euler";
static NSString * const HBL_ORIENTATION_NAME = @"设备空间方位欧拉角";

static NSString * const HBL_GPS = @"TYPE_GPS";
static NSString * const HBL_GPS_NAME = @"GPS";

static NSString * const HBL_ALTITUDE = @"TYPE_ALTITUDE";
static NSString * const HBL_ALTITUDE_NAME = @"海拔";

static BOOL const HBL_BACKGROUND_LOCATION_ENABLE = NO;
static BOOL const HBL_SENSORDATA_LOG_ENABLED = NO; // sensor log 开关


#endif /* HBLSensorDefine_h */
