//
//  HBLSensorLocationManager.m
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import "HBLSensorLocationManager.h"
#import "HBLSensorDefine.h"
#import <UIKit/UIKit.h>

@interface HBLSensorLocationManager() <CLLocationManagerDelegate>

@end

@implementation HBLSensorLocationManager

- (instancetype)init {
    if (self = [super init]) {
        self.delegate = self;
        self.distanceFilter = 5;
        self.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)startForegroundLocationUpdate {
    CGFloat version = [UIDevice currentDevice].systemVersion.floatValue;
    if (version >= 8.0) {
        [self requestAlwaysAuthorization];
    }
    [self startUpdatingLocation];
}

- (void)startBackgroundLocationUpdate {
    if (HBL_BACKGROUND_LOCATION_ENABLE) {
        CGFloat version = [UIDevice currentDevice].systemVersion.floatValue;
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (version >= 9.0 && status == kCLAuthorizationStatusAuthorizedAlways) {
            [self setAllowsBackgroundLocationUpdates:YES];
        }
        [self startUpdatingLocation];
        [self startMonitoringSignificantLocationChanges];
    }
}

- (void)changeBackgroundLocationUpdates {
    if (HBL_BACKGROUND_LOCATION_ENABLE) {
        if ([self respondsToSelector:@selector(allowsBackgroundLocationUpdates)] && !self.allowsBackgroundLocationUpdates) {
            [self startBackgroundLocationUpdate];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations[0];
    
    //    NSLog(@"%@",location);
    
    if (self.sensorLocationBlock) {
        self.sensorLocationBlock(location);
    }
    //    [self adjustDistanceFilter:location];
    [self changeBackgroundLocationUpdates];
}

@end
